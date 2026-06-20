#!/bin/bash
# Common configuration sourced by all stage scripts.
# Tuned for da7 (ishia): 32 cores, 376 GB RAM, 36 TB scratch on /corrino.

# --- Paths ---
export SCRATCH=/corrino/play/audris/lcs_icse27
export BASEMAPS=/corrino/basemaps/gz
export POLD2PNEW_LOCAL=$SCRATCH/staging/pOld2pNew.V2604.s   # staged from da5
export POLD2PNEW_REMOTE=da5:/da5_data/basemaps/gz/pOld2pNew.V2604.s
export P2CHANGE_V=da5:/home/mjahansh/repos/lcs/data/choice/P2change.s

# WoC helpers (NFS-shared from da8 via /home)
export LSORT=$HOME/lookup/lsort
# Note: da7 lacks the TokyoCabinet Perl module, so the perl splitters fail.
# We use self-contained Python equivalents (same FNV-1a-32 hash function).
# The python scripts have a shebang and are exec'd directly.
HERE_PIPELINE=${HERE_PIPELINE:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}
export SPLITSEC=$HERE_PIPELINE/splitSec.py
export SPLITSECCH=$HERE_PIPELINE/splitSecCh.py

# --- Parallelism / memory ---
# Be polite to other da7 users. 8 concurrent shards × 1 GB lsort/sort = ~24 GB
# peak in the per-shard joins. Bump PAR up if da7 is idle.
export PAR=${PAR:-8}
export LSMEM=${LSMEM:-1G}   # lsort buffer per task
export SORTMEM=${SORTMEM:-1G}

# --- Logging ---
export LOGS=$SCRATCH/logs
export TMPDIR=$SCRATCH/tmp           # /tmp on da7 is small; /corrino is 36 TB
mkdir -p "$SCRATCH"/{staging,input,split,out,logs,tmp}

# --- Time anchors (must match: year window in seconds) ---
export YEAR_S=31536000

# --- Convenience ---
shopt -s nullglob

log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }
err() { printf '[%s] ERROR: %s\n' "$(date +%H:%M:%S)" "$*" >&2; }

throttle() {
  # Wait until at most PAR jobs remain in background.
  while (( $(jobs -p | wc -l) >= PAR )); do
    wait -n
  done
}
