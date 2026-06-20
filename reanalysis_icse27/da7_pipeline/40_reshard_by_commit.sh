#!/bin/bash
# Stage 2: pull commit hash to the front and re-shard by FNV-1a-32 so the
# next join can be done shard-locally against c2datFull.V2604.{0..127} and
# c2fbbFull.V2604.{0..127}.

set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
source "$HERE/00_config.sh"

cd "$SCRATCH"

log "Step 2: re-shard by commit (single-pass)"

# cPc shard format from step 1 (9 cols):
#   newP; firstLic; firstAdop; lastLic; lastAdop; dist; firstT; lastT; commit
# Reshape to: commit; newP; firstT; lastT
# (We drop everything else; we don't need it for the date/file/blob join.)

zcat split/cPc.*.gz \
  | awk -F';' 'BEGIN { OFS=";" } { print $9, $1, $7, $8 }' \
  | "$SPLITSEC" split/cByc. 128

log "Step 2 done. Per-shard sizes:"
ls -lh split/cByc.*.gz | head -3
echo "..."
log "Total (project, commit) rows:"
zcat split/cByc.*.gz | wc -l
