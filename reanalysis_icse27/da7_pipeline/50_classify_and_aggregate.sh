#!/bin/bash
# Stage 3: per shard j, join cByc.$j with c2aAcCtFull.V2604.$j.s to get the
# commit author timestamp + aliased author A + raw author a, classify each
# commit into one of three windows (FIRST = year after first license
# adoption, LAST = year after last license adoption, PRE = year before
# last license adoption), then join with c2fbbFull.V2604.$j.s to enumerate
# (file, blob_after) per commit, and aggregate per (project, window) within
# the shard.
#
# c2aAcCt schema (6 fields): commit; a (raw author); A (resolved aliased
# author); c (raw committer); C (resolved aliased committer); t (author time).
# We keep the resolved A as the canonical identity for distinct-author
# counts, but use the raw a to apply bot/bad-author filtering against the
# blocklists in BLOCKLIST_DIR (badEmailS and bad_authors_woc.txt).  Rows
# matching the filter are dropped before aggregation, so a project's distinct
# author count never includes a bot.
#
# Heaviest stage of the pipeline. Keep PAR modest on da7 (4 by default).

set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
source "$HERE/00_config.sh"

cd "$SCRATCH"

# Official V2604 bad-author blocklist from /data/play/forks/badV2604.ids on da5
# (155 MB, 3,206,105 entries: 2,652,369 "generic" homonyms + 553,736 "bot").
# Format: <raw author>;<category>  where category is "generic" or "bot".
# Both categories are blocklist: drop the raw author either way.
# This is the production V2604 list used by the alias-map build; vastly more
# comprehensive than the findHomonyms/woc.pm extracts.
BLOCKLIST_DIR="$SCRATCH/blocklists"
BAD_IDS="$BLOCKLIST_DIR/badV2604.ids"
if [[ ! -s "$BAD_IDS" ]]; then
  log "ERROR: $BAD_IDS not present; copy from da5:/data/play/forks/badV2604.ids" >&2
  exit 1
fi
log "Blocklist: $(wc -l < "$BAD_IDS") bad raw-author entries (from badV2604.ids)"

log "Step 3: classify + c2fbb + per-shard aggregate (PAR=$PAR)"
log "  using c2aAcCtFull.V2604 for aliased author A (field 3) and atime (field 6)"

# --- worker ---
process_shard() {
  local j=$1
  local agg="split/agg.$j.gz"
  [[ -s "$agg" ]] && return 0

  # 3a. Join with c2aAcCt and classify into FIRST/LAST/PRE windows.
  # c2aAcCt schema (sorted by commit): commit;a;A;c;C;t
  # We pull commit (1), A (3), a (2), t (6).  Filter:
  #   * drop if raw a (field 2) is in bad_authors_woc.txt (exact match)
  #   * drop if email extracted from a matches a line in badEmailS
  #   * drop if a matches bot patterns:
  #       \[bot\]
  #       @users\.noreply\.github\.com
  #       @users\.github\.com
  #       ^Bot |^bot
  LC_ALL=C join -t';' \
    <(zcat split/cByc.$j.gz | LC_ALL=C sort -T "$TMPDIR" -t';' -k1,1 -S "$SORTMEM") \
    <(zcat "$BASEMAPS/c2aAcCtFull.V2604.$j.s" \
        | awk -F';' 'BEGIN{OFS=";"} {print $1, $6, $3, $2}') \
    | awk -F';' \
          -v Y="$YEAR_S" \
          -v BAD="$BAD_IDS" '
        BEGIN {
          OFS = ";"
          # Load the official V2604 bad-author list.  File format is
          # <raw_author>;<category> where category is "generic" or "bot".
          # We treat both as blocklist entries.  Some raw_author strings
          # contain semicolons; rebuild the key by stripping the trailing
          # ";generic" or ";bot".
          while ((getline line < BAD) > 0) {
            if (line == "") continue
            if (sub(/;generic$/, "", line) || sub(/;bot$/, "", line)) {
              badA[line] = 1
            }
          }
          close(BAD)
        }
        # input fields after the join:
        #   1=commit  2=project  3=firstT  4=lastT  5=atime  6=A  7=a
        # Drop iff the raw author a is in the official V2604 bad-id list.
        function is_bot(a) {
          return (a in badA)
        }
        {
          c=$1; pid=$2; ft=$3+0; lt=$4+0; ts=$5+0; A=$6; a=$7
          if (is_bot(a)) next
          if      (ts >= ft       && ts < ft + Y) print c, pid, "FIRST", ts, A
          else if (ts >= lt       && ts < lt + Y) print c, pid, "LAST",  ts, A
          else if (ts >= lt - Y   && ts < lt)     print c, pid, "PRE",   ts, A
        }' \
    | gzip > split/cls.$j.gz.tmp \
    && mv split/cls.$j.gz.tmp split/cls.$j.gz

  # 3b. Join with c2fbb to fan out per file changed by each classified commit.
  # c2fbb format: commit; filepath; blob_after; blob_before
  # cls format from 3a: commit; pid; window; ts; A
  # Sort cls because window-classification doesn't preserve commit order;
  # c2fbbFull.V2604.*.s is already sorted by commit SHA.
  LC_ALL=C join -t';' \
    <(zcat split/cls.$j.gz | LC_ALL=C sort -T "$TMPDIR" -t';' -k1,1 -S "$SORTMEM") \
    <(zcat "$BASEMAPS/c2fbbFull.V2604.$j.s") \
    | awk -F';' 'BEGIN{OFS=";"}
        # fields from cls: 1=c; 2=pid; 3=window; 4=ts; 5=A
        # appended from c2fbb: 6=filepath; 7=blob_after; 8=blob_before
        { print $2, $3, $1, $4, $5, $6, $7 }' \
    | gzip > split/cPfbb.$j.gz.tmp \
    && mv split/cPfbb.$j.gz.tmp split/cPfbb.$j.gz

  # 3c. Aggregate per (project, window): distinct commits, distinct files,
  # distinct blobs (blob_after), distinct active months, and distinct
  # aliased authors A.  Single awk pass holds dedup sets per project x window
  # using string keys.
  zcat split/cPfbb.$j.gz \
    | awk -F';' '
        BEGIN { OFS = ";" }
        {
          # fields: 1=pid; 2=window; 3=commit; 4=ts; 5=A; 6=file; 7=blob_after
          pid = $1; w = $2; c = $3; ts = $4; A = $5; f = $6; b = $7
          pw   = pid SUBSEP w
          ckey = pw SUBSEP c
          fkey = pw SUBSEP f
          bkey = pw SUBSEP b
          mon  = strftime("%Y-%m", ts)
          mkey = pw SUBSEP mon
          akey = pw SUBSEP A
          if (!(ckey in seen_c)) { seen_c[ckey] = 1; cnt_c[pw]++ }
          if (!(fkey in seen_f)) { seen_f[fkey] = 1; cnt_f[pw]++ }
          if (!(bkey in seen_b)) { seen_b[bkey] = 1; cnt_b[pw]++ }
          if (!(mkey in seen_m)) { seen_m[mkey] = 1; cnt_m[pw]++ }
          if (A != "" && !(akey in seen_a)) { seen_a[akey] = 1; cnt_a[pw]++ }
        }
        END {
          for (k in cnt_c) {
            split(k, a, SUBSEP)
            # output: pid; window; ncmt; nfiles; nblobs; nmonths; nauthors
            print a[1], a[2], cnt_c[k]+0, cnt_f[k]+0, cnt_b[k]+0, cnt_m[k]+0, cnt_a[k]+0
          }
        }' \
    | gzip > "$agg".tmp \
    && mv "$agg".tmp "$agg"
}

for j in {0..127}; do
  (process_shard "$j" 2> "$LOGS/shard.$j.log") &
  throttle
done
wait

log "Step 3 done. Per-shard agg sizes:"
ls -lh split/agg.*.gz 2>/dev/null | head -3 || true
echo "..."
