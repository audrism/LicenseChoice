#!/bin/bash
# Pt2PtbFullV pass on da8.  Operates on V-canonical project IDs (from
# P2change.s) and produces per-project per-window upstream/downstream
# project counts.  V2604-canonical IDs are obtained by translating the
# V-canonical output via Pold2Pnew.modal.s afterwards.

# --- Paths (da8 / hostname=da8) ---
# /da8_data on da5 is /mnt/ordos/data/data on da8.
export SCRATCH=/mnt/ordos/data/data/play/audris/lcs_icse27/updown
export BASEMAPS=/mnt/ordos/data/data/basemaps/gz
export P2CHANGE_V=da5:/home/mjahansh/repos/lcs/data/choice/P2change.s

# WoC helpers (NFS-shared via /home -> da8 mountpoint differs but ~ works)
export LSORT=$HOME/lookup/lsort

# --- Parallelism / memory ---
# da8 currently has only ~140 GB free RAM; keep PAR low so we don't compete
# with whatever else is running.
export PAR=${PAR:-4}
export LSMEM=${LSMEM:-1G}
export SORTMEM=${SORTMEM:-1G}

# --- Year window in seconds ---
export YEAR_S=31536000

export LOGS=$SCRATCH/logs
mkdir -p "$SCRATCH"/{staging,split,out,logs}

log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }

throttle() {
  while (( $(jobs -p | wc -l) >= PAR )); do
    wait -n
  done
}
