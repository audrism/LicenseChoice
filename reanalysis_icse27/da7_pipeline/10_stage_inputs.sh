#!/bin/bash
# Stage 0: bring in P2change.s from da5.  The Pold->Pnew translation lives in
# /home/audris/lcs_icse27_v2604/translation/Pold2Pnew.modal.s on da5 and is
# fetched by 20_translate_p2change.sh on demand.
#
# Idempotent -- safe to re-run.

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

log "Sanity check: line counts"
n=$(zcat staging/P2change.s | wc -l)
log "  P2change.s lines: $n"

log "Done."
