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
  # P2change shard format (10 cols, project first):
  #   Pnew; firstLic; firstAdop; lastLic; lastAdop; dist; firstT; lastT; oldList; flag
  # p2c shard format: Pnew; commit_sha
  # Output: cPc.$i.gz has 11 columns -- the 10 P2change cols followed by commit_sha.
  #
  # p2cFull.V2604.*.s is already sorted by project (verified by full scan of
  # shard 0 = 1.45 G rows).  Only the small P2change shard needs sorting.
  # This avoids the ~30 min spill-to-disk sort of a 13 GB file per shard.
  LC_ALL=C join -t';' \
    <(zcat split/P2change.$i.gz | LC_ALL=C sort -T "$TMPDIR" -t';' -k1,1 -S "$SORTMEM") \
    <(zcat "$BASEMAPS/p2cFull.V2604.$i.s") \
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
