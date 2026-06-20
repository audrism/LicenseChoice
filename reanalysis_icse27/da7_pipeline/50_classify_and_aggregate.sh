#!/bin/bash
# Stage 3: per shard j, join cByc.$j with c2datFull.V2604.$j.s to get the
# commit author timestamp, classify each commit into one of three windows
# (FIRST = year after first license adoption, LAST = year after last license
# adoption, PRE = year before last license adoption), then join with
# c2fbbFull.V2604.$j.s to enumerate (file, blob_after) per commit, and
# aggregate per (project, window) within the shard.
#
# This is the heaviest stage. Keep PAR modest on da7 (8 by default).

set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
source "$HERE/00_config.sh"

cd "$SCRATCH"

log "Step 3: classify + c2fbb + per-shard aggregate (PAR=$PAR)"

# --- worker ---
process_shard() {
  local j=$1
  local agg="split/agg.$j.gz"
  [[ -s "$agg" ]] && return 0

  # 3a. Join with c2dat (keep commit + author_time). c2dat field 6 is author_time.
  LC_ALL=C join -t';' \
    <(zcat split/cByc.$j.gz | LC_ALL=C sort -T "$TMPDIR" -t';' -k1,1 -S "$SORTMEM") \
    <(zcat "$BASEMAPS/c2datFull.V2604.$j.s" \
        | awk -F';' 'BEGIN{OFS=";"} {print $1, $6}' \
        | LC_ALL=C sort -T "$TMPDIR" -t';' -k1,1 -S "$SORTMEM") \
    | awk -F';' -v Y="$YEAR_S" '
        BEGIN { OFS=";" }
        # fields: commit; project; firstT; lastT; ts
        {
          c=$1; pid=$2; ft=$3+0; lt=$4+0; ts=$5+0
          if      (ts >= ft       && ts < ft + Y) print c, pid, "FIRST", ts
          else if (ts >= lt       && ts < lt + Y) print c, pid, "LAST",  ts
          else if (ts >= lt - Y   && ts < lt)     print c, pid, "PRE",   ts
        }' \
    | gzip > split/cls.$j.gz.tmp \
    && mv split/cls.$j.gz.tmp split/cls.$j.gz

  # 3b. Join with c2fbb to fan out per file changed by each classified commit.
  # c2fbb format: commit; filepath; blob_after; blob_before
  LC_ALL=C join -t';' \
    <(zcat split/cls.$j.gz | LC_ALL=C sort -T "$TMPDIR" -t';' -k1,1 -S "$SORTMEM") \
    <(zcat "$BASEMAPS/c2fbbFull.V2604.$j.s" | LC_ALL=C sort -T "$TMPDIR" -t';' -k1,1 -S "$SORTMEM") \
    | awk -F';' 'BEGIN{OFS=";"}
        # fields from cls: c; pid; window; ts
        # appended from c2fbb: filepath; blob_after; blob_before
        { print $2, $3, $1, $4, $5, $6 }' \
    | gzip > split/cPfbb.$j.gz.tmp \
    && mv split/cPfbb.$j.gz.tmp split/cPfbb.$j.gz

  # 3c. Aggregate per (project, window): distinct commits, distinct files,
  # distinct blobs (blob_after), distinct active months (YYYY-MM derived from ts).
  # Single awk pass holds dedup sets per project×window using string keys.
  zcat split/cPfbb.$j.gz \
    | awk -F';' '
        BEGIN { OFS=";" }
        {
          pid=$1; w=$2; c=$3; ts=$4; f=$5; b=$6
          ckey = pid SUBSEP w SUBSEP c
          fkey = pid SUBSEP w SUBSEP f
          bkey = pid SUBSEP w SUBSEP b
          mon  = strftime("%Y-%m", ts)
          mkey = pid SUBSEP w SUBSEP mon
          if (!(ckey in seen_c)) { seen_c[ckey]=1; cnt_c[pid SUBSEP w]++ }
          if (!(fkey in seen_f)) { seen_f[fkey]=1; cnt_f[pid SUBSEP w]++ }
          if (!(bkey in seen_b)) { seen_b[bkey]=1; cnt_b[pid SUBSEP w]++ }
          if (!(mkey in seen_m)) { seen_m[mkey]=1; cnt_m[pid SUBSEP w]++ }
        }
        END {
          for (k in cnt_c) {
            split(k, a, SUBSEP)
            print a[1], a[2], cnt_c[k]+0, cnt_f[k]+0, cnt_b[k]+0, cnt_m[k]+0
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
ls -lh split/agg.*.gz | head -3
echo "..."
