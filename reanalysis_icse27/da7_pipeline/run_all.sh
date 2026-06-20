#!/bin/bash
# Master driver. Runs the full V2604 reanalysis pipeline on da7.
# Each stage is idempotent and skips work already done -- safe to re-run
# after a failure.
#
# Usage:
#   tmux new -s lcs_v2604
#   bash run_all.sh   2>&1 | tee run_all.log

set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
source "$HERE/00_config.sh"

date
log "Starting V2604 pre/first/last window pipeline"
log "Scratch dir : $SCRATCH"
log "Base maps   : $BASEMAPS"
log "Parallelism : PAR=$PAR  LSMEM=$LSMEM  SORTMEM=$SORTMEM"
echo

bash "$HERE/10_stage_inputs.sh"
bash "$HERE/20_translate_p2change.sh"
bash "$HERE/30_join_p2c.sh"
bash "$HERE/40_reshard_by_commit.sh"
bash "$HERE/50_classify_and_aggregate.sh"
bash "$HERE/60_merge_and_assemble.sh"

log "All done."
log "Final output: $SCRATCH/out/cP2all.V2604.1y"
ls -lh "$SCRATCH/out/cP2all.V2604.1y"
