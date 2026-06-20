#!/bin/bash
# Merge per-shard edges and count distinct counterparts per (subject, window,
# direction). A counterpart counterpart_P may appear under multiple subjects in
# multiple shards; per-shard dedup already removed within-shard duplicates,
# but a subject's distinct-counterpart list may span shards (because subject's
# rows live wherever (fP,fT) or (tP,tT) hashes), so we re-dedup globally then
# count.

set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
source "$HERE/00_config.sh"

cd "$SCRATCH"

log "Step 30: merge and count distinct counterparts"

zcat split/UpDown.*.gz \
  | "$LSORT" 8G -t';' -k1,1 -k2,2 -k3,3 -k4,4 -u \
  | awk -F';' 'BEGIN { OFS=";" }
      function flush() {
        if (cur != "") print cur, n
      }
      {
        key = $1 ";" $2 ";" $3
        if (key != cur) { flush(); cur = key; n = 0 }
        n++
      }
      END { flush() }' \
  | gzip > out/cP2UpDown.V.s

log "Output rows (Pold ; window ; U|D ; count):"
zcat out/cP2UpDown.V.s | wc -l
log "Sample:"
zcat out/cP2UpDown.V.s | head -5
log "Per-window per-direction row count:"
zcat out/cP2UpDown.V.s | awk -F';' '{c[$2";"$3]++} END {for(k in c) printf "  %-12s %d\n", k, c[k]}'

log "Done. Final artifact: $SCRATCH/out/cP2UpDown.V.s"
ls -lh out/cP2UpDown.V.s
