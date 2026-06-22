#!/bin/bash
# Quick single-shard test of the bot-filtered stage 50.
# Runs shard 0 with the new c2aAcCt-based pipeline and reports diagnostics
# (rows in / rows kept / commits dropped by bot filter / author counts).
#
# Use this to sanity-check before kicking off the full 128-shard re-run.

set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
source "$HERE/00_config.sh"

cd "$SCRATCH"

j=${1:-0}     # shard index
mkdir -p split_test
mkdir -p blocklists
if [[ ! -s blocklists/badV2604.ids ]]; then
  echo "ERROR: blocklists/badV2604.ids missing; scp from da5:/data/play/forks/badV2604.ids" >&2
  exit 1
fi

log "Test shard $j  (using c2aAcCtFull.V2604.$j.s)"

# raw count of (commit, A, a, t) rows the cByc shard joins to in c2aAcCt
n_in=$(LC_ALL=C join -t';' \
  <(zcat split/cByc.$j.gz | LC_ALL=C sort -T "$TMPDIR" -t';' -k1,1 -S "$SORTMEM") \
  <(zcat "$BASEMAPS/c2aAcCtFull.V2604.$j.s" \
      | awk -F';' 'BEGIN{OFS=";"} {print $1, $6, $3, $2}') \
  | wc -l)
log "  raw join rows: $n_in"

# count dropped by bot filter
n_bot=$(LC_ALL=C join -t';' \
  <(zcat split/cByc.$j.gz | LC_ALL=C sort -T "$TMPDIR" -t';' -k1,1 -S "$SORTMEM") \
  <(zcat "$BASEMAPS/c2aAcCtFull.V2604.$j.s" \
      | awk -F';' 'BEGIN{OFS=";"} {print $1, $6, $3, $2}') \
  | awk -F';' -v BAD=blocklists/badV2604.ids '
      BEGIN {
        while ((getline line < BAD) > 0) {
          if (line == "") continue
          if (sub(/;generic$/, "", line)) { badA[line] = "g"; ng++ }
          else if (sub(/;bot$/, "", line)) { badA[line] = "b"; nb++ }
        }
        close(BAD)
        printf "loaded %d generic + %d bot = %d total\n", ng, nb, ng+nb > "/dev/stderr"
      }
      {
        a = $7
        if (a in badA) {
          if (badA[a] == "g") drop_g++; else drop_b++
        } else { kept++ }
      }
      END { print drop_g + drop_b }')
log "  dropped by bot filter: $n_bot  ($(awk "BEGIN{printf \"%.2f\", 100*$n_bot/$n_in}")%)"

log "Run worker (full stage 50 on shard $j) into split_test/"
agg="split_test/agg.$j.gz"
rm -f "$agg" split_test/cls.$j.gz split_test/cPfbb.$j.gz
SCRATCH="$SCRATCH" BASEMAPS="$BASEMAPS" TMPDIR="$TMPDIR" \
  bash -c '
    j='"$j"'
    BLOCKLIST_DIR="$SCRATCH/blocklists"
    LC_ALL=C join -t";" \
      <(zcat split/cByc.$j.gz | LC_ALL=C sort -T "$TMPDIR" -t";" -k1,1 -S "8G") \
      <(zcat "$BASEMAPS/c2aAcCtFull.V2604.$j.s" \
          | awk -F";" "BEGIN{OFS=\";\"} {print \$1, \$6, \$3, \$2}") \
      | awk -F";" -v Y=31536000 -v BAD="$BLOCKLIST_DIR/badV2604.ids" '"'"'
          BEGIN {
            OFS = ";"
            while ((getline line < BAD) > 0) {
              if (line == "") continue
              if (sub(/;generic$/, "", line) || sub(/;bot$/, "", line)) badA[line] = 1
            }
            close(BAD)
          }
          function is_bot(a) { return (a in badA) }
          {
            c=$1; pid=$2; ft=$3+0; lt=$4+0; ts=$5+0; A=$6; a=$7
            if (is_bot(a)) next
            if      (ts >= ft     && ts < ft + Y) print c, pid, "FIRST", ts, A
            else if (ts >= lt     && ts < lt + Y) print c, pid, "LAST",  ts, A
            else if (ts >= lt - Y && ts < lt)     print c, pid, "PRE",   ts, A
          }'"'"' | gzip > split_test/cls.$j.gz

    LC_ALL=C join -t";" \
      <(zcat split_test/cls.$j.gz | LC_ALL=C sort -T "$TMPDIR" -t";" -k1,1 -S "8G") \
      <(zcat "$BASEMAPS/c2fbbFull.V2604.$j.s") \
      | awk -F";" "BEGIN{OFS=\";\"} {print \$2, \$3, \$1, \$4, \$5, \$6, \$7}" \
      | gzip > split_test/cPfbb.$j.gz

    zcat split_test/cPfbb.$j.gz \
      | awk -F";" '"'"'
          BEGIN { OFS = ";" }
          {
            pid=$1; w=$2; c=$3; ts=$4; A=$5; f=$6; b=$7
            pw=pid SUBSEP w
            if (!(pw SUBSEP c in sc)) {sc[pw SUBSEP c]=1; nc[pw]++}
            if (!(pw SUBSEP f in sf)) {sf[pw SUBSEP f]=1; nf[pw]++}
            if (!(pw SUBSEP b in sb)) {sb[pw SUBSEP b]=1; nb[pw]++}
            mon=strftime("%Y-%m", ts); if (!(pw SUBSEP mon in sm)) {sm[pw SUBSEP mon]=1; nm[pw]++}
            if (A != "" && !(pw SUBSEP A in sa)) {sa[pw SUBSEP A]=1; na[pw]++}
          }
          END {
            for (k in nc) { split(k, a, SUBSEP); print a[1], a[2], nc[k]+0, nf[k]+0, nb[k]+0, nm[k]+0, na[k]+0 }
          }'"'"' \
      | gzip > split_test/agg.$j.gz
  '

log "Output sizes:"
ls -lh split_test/cls.$j.gz split_test/cPfbb.$j.gz split_test/agg.$j.gz 2>/dev/null

log "agg row distribution (window x metric):"
zcat split_test/agg.$j.gz | head -5
echo
zcat split_test/agg.$j.gz | awk -F';' '
  {n[$2]++; tcmt[$2]+=$3; tfile[$2]+=$4; tblob[$2]+=$5; tmon[$2]+=$6; tauth[$2]+=$7}
  END {
    printf "  %-6s %8s %8s %8s %8s %8s %8s\n", "win", "rows", "cmt", "file", "blob", "mon", "auth"
    for (k in n) printf "  %-6s %8d %8d %8d %8d %8d %8d\n",
                   k, n[k], tcmt[k], tfile[k], tblob[k], tmon[k], tauth[k]
  }'
log "Done."
