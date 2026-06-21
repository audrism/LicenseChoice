#!/bin/bash
# Stage 4: merge per-shard aggregates into per-project per-window totals
# and pivot to a cP2all-style flat table.
#
# A commit / file / blob lives on exactly one of the 128 shards (commit hash
# determines the shard, so deduplication across shards is automatic for
# c-, f-, b-keyed entities -- the shard's own awk already deduplicated by
# blob_after / filepath / commit / month). We just sum the per-shard counts.

set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
source "$HERE/00_config.sh"

cd "$SCRATCH"

log "Step 4: merge per-shard aggregates"

# Per shard format (6 cols): pid; window; ncmt; nfiles; nblobs; nmonths
zcat split/agg.*.gz \
  | "$LSORT" 32G -t';' -k1,1 -k2,2 \
  | awk -F';' '
      BEGIN { OFS=";" }
      function flush(   k) {
        if (curkey != "") print curkey, ncmt, nfiles, nblobs, nmonths
      }
      {
        key = $1 ";" $2
        if (key != curkey) {
          flush()
          curkey = key
          ncmt = 0; nfiles = 0; nblobs = 0; nmonths = 0
        }
        ncmt    += $3
        nfiles  += $4
        nblobs  += $5
        nmonths += $6
      }
      END { flush() }' \
  | gzip > out/cP2windows.V2604.gz

log "Step 4a done. Rows in cP2windows.V2604.gz:"
zcat out/cP2windows.V2604.gz | wc -l

log "Step 4b: pivot into cP2all.V2604.1y (one row per project, 3 windows)"
python3 "$HERE/build_cP2all_V2604.py" \
  --windows out/cP2windows.V2604.gz \
  --p2change input/P2change.V2604.s \
  --out out/cP2all.V2604.1y

log "Final cP2all.V2604.1y:"
ls -lh out/cP2all.V2604.1y
{ zcat out/cP2all.V2604.1y 2>/dev/null || cat out/cP2all.V2604.1y; } | head -2 || true
log "Done."
