#!/bin/bash
# Stage 1: for each shard i, join P2change.$i with p2cFull.V2604.$i.s to
# enumerate every commit belonging to a change project, carrying along the
# project's first/last license epochs.

set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
source "$HERE/00_config.sh"

cd "$SCRATCH"

log "Step 1: shard-local join with p2cFull.V2604 (PAR=$PAR)"

join_one() {
  local i=$1
  local out="split/cPc.$i.gz"
  [[ -s "$out" ]] && return 0
  # P2change shard format (8 cols, project first): newP;firstLic;firstAdop;lastLic;lastAdop;dist;firstT;lastT;oldP
  # p2c shard format: project;commit_sha
  # Both files are NOT necessarily sorted by project. Sort on the fly.
  LC_ALL=C join -t';' \
    <(zcat split/P2change.$i.gz | LC_ALL=C sort -t';' -k1,1 -S "$SORTMEM") \
    <(zcat "$BASEMAPS/p2cFull.V2604.$i.s" | LC_ALL=C sort -t';' -k1,1 -S "$SORTMEM") \
  | gzip > "$out".tmp \
  && mv "$out".tmp "$out"
}

for i in {0..127}; do
  (join_one "$i" 2> "$LOGS/cPc.$i.log") &
  throttle
done
wait

log "Step 1 done. Output sizes:"
ls -lh split/cPc.*.gz | head -3
echo "..."
log "Total commits emitted:"
zcat split/cPc.*.gz | wc -l
