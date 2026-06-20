#!/bin/bash
# Driver for the V-era Pt2Ptb upstream/downstream pass on da8.
# Each stage is idempotent.

set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
source "$HERE/00_config.sh"

date
log "Pt2PtbFullV upstream/downstream pass on da8"
log "Scratch dir : $SCRATCH"
log "Base maps   : $BASEMAPS"
log "Parallelism : PAR=$PAR  LSMEM=$LSMEM  SORTMEM=$SORTMEM"
echo

bash "$HERE/10_stage_input.sh"
bash "$HERE/20_filter_classify.sh"
bash "$HERE/30_aggregate.sh"

log "All done."
ls -lh "$SCRATCH/out/cP2UpDown.V.s"
