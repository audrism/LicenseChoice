#!/bin/bash
# Bring P2change.s in from da5 and produce an awk-loadable map:
#   P_old (V-canonical) -> firstT;lastT
# We use V-canonical IDs because Pt2PtbFullV* is on V; translation to V2604
# happens after aggregation.

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

log "Build P2change.epochs.s : Pold ; firstT ; lastT"
if [[ ! -s staging/P2change.epochs.s ]]; then
  zcat staging/P2change.s | awk -F';' '{
      split($3, a, "-"); split($5, b, "-")
      cmd1 = "date -ud \"" a[1] "-" a[2] "-15 UTC\" +%s"
      cmd2 = "date -ud \"" b[1] "-" b[2] "-15 UTC\" +%s"
      cmd1 | getline ft; close(cmd1)
      cmd2 | getline lt; close(cmd2)
      print $1 ";" ft ";" lt
    }' > staging/P2change.epochs.s
fi
log "  Pold count: $(wc -l < staging/P2change.epochs.s)"
log "Done."
