#!/bin/bash
# Per shard 0..31, stream Pt2PtbFullV$i.s, filter to rows whose from_P or
# to_P is one of our change projects, classify the relevant time into
# FIRST/LAST/PRE window, and emit deduplicated edges
#   subject_P ; window ; U|D ; counterpart_P
#
# Memory: P2change.epochs.s (148k rows ~ 6 MB) is loaded into an awk hash.
# Per-shard streaming pass is single-threaded I/O.  PAR=4 by default.

set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
source "$HERE/00_config.sh"

cd "$SCRATCH"

log "Step 20: per-shard streaming filter + classify (PAR=$PAR)"

process_shard() {
  local i=$1
  local out="split/UpDown.$i.gz"
  [[ -s "$out" ]] && return 0

  zcat "$BASEMAPS/Pt2PtbFullV$i.s" \
    | awk -F';' -v Y="$YEAR_S" -v EP="staging/P2change.epochs.s" '
        BEGIN {
          OFS=";"
          while ((getline line < EP) > 0) {
            n = split(line, c, ";")
            chFt[c[1]] = c[2] + 0
            chLt[c[1]] = c[3] + 0
          }
          close(EP)
        }
        {
          fP=$1; fT=$2+0; tP=$3; tT=$4+0
          # downstream edges (subject = fP, counterpart = tP)
          if (fP in chFt) {
            ft = chFt[fP]; lt = chLt[fP]
            w = ""
            if      (fT >= ft       && fT < ft + Y) w = "FIRST"
            else if (fT >= lt       && fT < lt + Y) w = "LAST"
            else if (fT >= lt - Y   && fT < lt)     w = "PRE"
            if (w != "" && fP != tP) print fP, w, "D", tP
          }
          # upstream edges (subject = tP, counterpart = fP)
          if (tP in chFt) {
            ft = chFt[tP]; lt = chLt[tP]
            w = ""
            if      (tT >= ft       && tT < ft + Y) w = "FIRST"
            else if (tT >= lt       && tT < lt + Y) w = "LAST"
            else if (tT >= lt - Y   && tT < lt)     w = "PRE"
            if (w != "" && fP != tP) print tP, w, "U", fP
          }
        }' \
    | LC_ALL=C sort -t';' -k1,1 -k2,2 -k3,3 -k4,4 -u -S "$SORTMEM" \
    | gzip > "$out".tmp \
    && mv "$out".tmp "$out"
}

for i in {0..31}; do
  (process_shard "$i" 2> "$LOGS/shard.$i.log") &
  throttle
done
wait

log "Step 20 done. Per-shard sizes:"
ls -lh split/UpDown.*.gz | head -3
echo "..."
log "Total edge rows (pre-merge):"
zcat split/UpDown.*.gz | wc -l
