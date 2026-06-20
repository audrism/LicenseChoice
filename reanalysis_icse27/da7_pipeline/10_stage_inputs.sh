#!/bin/bash
# Stage 0: bring in P2change.s and pOld2pNew.V2604.s from da5.
# Idempotent — safe to re-run.

set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
source "$HERE/00_config.sh"

cd "$SCRATCH"

log "Staging P2change.s from da5"
if [[ ! -s staging/P2change.s ]]; then
  scp "$P2CHANGE_V" staging/P2change.s
else
  log "  already present, skipping"
fi

log "Staging pOld2pNew.V2604.s from da5 (5.9 GB — a few minutes)"
if [[ ! -s "$POLD2PNEW_LOCAL" ]]; then
  scp "$POLD2PNEW_REMOTE" "$POLD2PNEW_LOCAL"
else
  log "  already present, skipping"
fi

log "Sanity check: line counts"
zcat staging/P2change.s | wc -l   | xargs -I{} log "P2change.s lines: {}"
zcat "$POLD2PNEW_LOCAL" | wc -l   | xargs -I{} log "pOld2pNew lines: {}"

log "Cardinality probe: count old-side IDs that map to >1 new-side ID"
zcat "$POLD2PNEW_LOCAL" | awk -F';' '{c[$1]++} END {
  n_dup=0; n_max=0
  for (k in c) { if (c[k] > 1) { n_dup++; if (c[k] > n_max) n_max = c[k] } }
  printf "  1->many old keys: %d  (max fanout: %d)\n", n_dup, n_max
}'

log "Done."
