#!/bin/bash
# Stage 0b: translate P2change.s project IDs from V to V2604 canonical via
# pOld2pNew.V2604.s, append firstT/lastT epoch columns, and pre-shard by
# FNV-1a-32 hash so the result aligns with p2cFull.V2604.{0..127} shards.

set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
source "$HERE/00_config.sh"

cd "$SCRATCH"

log "Sort pOld2pNew by old-side key (cached)"
if [[ ! -s staging/pOld2pNew.sorted.gz ]]; then
  "$LSORT" 8G -t';' -k1,1 < "$POLD2PNEW_LOCAL" | gzip > staging/pOld2pNew.sorted.gz
fi

log "Sort P2change by project (old V canonical)"
if [[ ! -s staging/P2change.sorted.gz ]]; then
  zcat staging/P2change.s | "$LSORT" 4G -t';' -k1,1 | gzip > staging/P2change.sorted.gz
fi

log "Join P2change with pOld2pNew (V -> V2604) and append epochs"
# pOld2pNew format: oldP;newP
# P2change format: project;firstLicense;firstAdoption(YYYY-MM);lastLicense;lastAdoption(YYYY-MM);distance
LC_ALL=C join -t';' \
  <(zcat staging/P2change.sorted.gz) \
  <(zcat staging/pOld2pNew.sorted.gz) \
| awk -F';' 'BEGIN { OFS=";" }
  {
    # Fields 1..6 = P2change cols; field 7 = V2604 canonical (from pOld2pNew $2)
    new_p = $7
    # firstAdoption is field 3, lastAdoption is field 5 (YYYY-MM)
    split($3, a, "-")
    split($5, b, "-")
    cmd1 = "date -ud \"" a[1] "-" a[2] "-15 UTC\" +%s"
    cmd2 = "date -ud \"" b[1] "-" b[2] "-15 UTC\" +%s"
    cmd1 | getline ft; close(cmd1)
    cmd2 | getline lt; close(cmd2)
    # output: newP; firstLic; firstAdop; lastLic; lastAdop; distance; firstT; lastT; oldP
    print new_p, $2, $3, $4, $5, $6, ft, lt, $1
  }' \
| "$LSORT" 4G -t';' -k1,1 -u \
| gzip > input/P2change.V2604.s

n_in=$(zcat staging/P2change.s        | wc -l)
n_out=$(zcat input/P2change.V2604.s   | wc -l)
log "translated: in=$n_in out=$n_out  (loss = $((n_in - n_out)) projects unmapped)"

log "Shard by FNV-1a-32 across 128 buckets (aligns with p2c shards)"
zcat input/P2change.V2604.s | "$SPLITSECCH" split/P2change. 128

log "Done.  Per-shard sizes:"
ls -lh split/P2change.*.gz | head -5
echo "..."
ls split/P2change.*.gz | wc -l | xargs -I{} echo "  total shards: {}"
