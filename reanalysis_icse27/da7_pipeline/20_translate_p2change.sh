#!/bin/bash
# Stage 0b: translate P2change.s from V-canonical to V2604-canonical project
# IDs via Pold2Pnew.modal.s (built by 15_build_Pold2Pnew.sh, run separately on
# da5).  Append firstT/lastT epoch columns and shard by FNV-1a-32 hash so the
# result aligns with p2cFull.V2604.{0..127} shards.
#
# When two Pold's resolve to the same Pnew, the consolidation policy is:
#   - earliest firstAdoption       (the row that licensed first)
#   - latest   lastAdoption        (the row whose final license is most recent)
#   - distance recomputed from those two
#   - firstLicense / lastLicense   taken from the consolidating rows respectively
#   - if the *types* of the consolidating firsts (or lasts) differ, mark a flag
#     in a diagnostics file so we can drop or hand-inspect the case.

set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
source "$HERE/00_config.sh"

cd "$SCRATCH"

POLD2PNEW_SRC=da5:/home/audris/lcs_icse27_v2604/translation/Pold2Pnew.modal.s
POLD2PNEW_LOCAL=staging/Pold2Pnew.modal.s

log "Staging Pold2Pnew.modal.s from da5"
if [[ ! -s "$POLD2PNEW_LOCAL" ]]; then
  scp "$POLD2PNEW_SRC" "$POLD2PNEW_LOCAL"
else
  log "  already present, skipping"
fi

log "Sort P2change.s by Pold"
if [[ ! -s staging/P2change.sortedByPold.gz ]]; then
  zcat staging/P2change.s | "$LSORT" 4G -t';' -k1,1 | gzip > staging/P2change.sortedByPold.gz
fi

log "Sort Pold2Pnew.modal.s by Pold"
if [[ ! -s staging/Pold2Pnew.sorted.gz ]]; then
  LC_ALL=C sort -t';' -k1,1 "$POLD2PNEW_LOCAL" | gzip > staging/Pold2Pnew.sorted.gz
fi

log "Step A: translate Pold -> Pnew; emit one row per Pold's P2change entry"
LC_ALL=C join -t';' \
  <(zcat staging/P2change.sortedByPold.gz) \
  <(zcat staging/Pold2Pnew.sorted.gz) \
  | awk -F';' 'BEGIN{OFS=";"} {
      # input cols 1..6 from P2change, col 7 = Pnew (from Pold2Pnew)
      Pold=$1; firstLic=$2; firstAdop=$3; lastLic=$4; lastAdop=$5; dist=$6; Pnew=$7
      print Pnew, firstLic, firstAdop, lastLic, lastAdop, dist, Pold
    }' \
  | LC_ALL=C sort -t';' -k1,1 -k3,3 -k5,5 \
  | gzip > staging/P2change.tagged.gz

n_orig=$(zcat staging/P2change.s | wc -l)
n_xlated=$(zcat staging/P2change.tagged.gz | wc -l)
log "  Pold rows translated: $n_xlated  (original: $n_orig)"
n_lost=$((n_orig - n_xlated))
if (( n_lost > 0 )); then
  log "  $n_lost Pold rows had no V2604 mapping; logging to diagnostics"
  LC_ALL=C join -t';' -v 1 \
    <(zcat staging/P2change.sortedByPold.gz) \
    <(zcat staging/Pold2Pnew.sorted.gz) \
    > staging/P2change.unmapped.txt
fi

log "Step B: consolidate Pnews that come from multiple Pold's"
# For each group of rows sharing the same Pnew, pick:
#   - earliest firstAdoption (min YYYY-MM)
#   - latest   lastAdoption  (max YYYY-MM)
#   - matching firstLic / lastLic from those rows
#   - flag if the two contributing rows disagree on firstLic *type*
zcat staging/P2change.tagged.gz \
  | awk -F';' '
      function flush(    ymdMin, ymdMax) {
        if (curP == "") return
        ymdMin = bestFAdop; ymdMax = bestLAdop
        # distance = months between earliest first and latest last
        split(ymdMin, a, "-"); split(ymdMax, b, "-")
        dist = (b[1]-a[1])*12 + (b[2]-a[2])
        flag = ""
        if (firstLicVariants > 1) flag = flag "FL"
        if (lastLicVariants  > 1) flag = flag (flag==""?"":"+") "LL"
        if (rows > 1)             flag = flag (flag==""?"":"+") "MERGE" rows
        print curP";"bestFLic";"bestFAdop";"bestLLic";"bestLAdop";"dist";"oldList";"(flag==""?"-":flag)
      }
      BEGIN { OFS=";" }
      $1 != curP {
        flush()
        curP=$1; bestFLic=$2; bestFAdop=$3; bestLLic=$4; bestLAdop=$5; oldList=$7
        rows=1
        delete fLicSet; fLicSet[$2]=1; firstLicVariants=1
        delete lLicSet; lLicSet[$4]=1; lastLicVariants=1
        next
      }
      {
        rows++
        oldList = oldList "," $7
        if ($3 < bestFAdop) { bestFAdop=$3; bestFLic=$2 }
        if ($5 > bestLAdop) { bestLAdop=$5; bestLLic=$4 }
        if (!($2 in fLicSet)) { fLicSet[$2]=1; firstLicVariants++ }
        if (!($4 in lLicSet)) { lLicSet[$4]=1; lastLicVariants++ }
      }
      END { flush() }' \
  | gzip > input/P2change.V2604.merged.gz

n_pnew=$(zcat input/P2change.V2604.merged.gz | wc -l)
log "  unique Pnew rows after consolidation: $n_pnew  (=$((n_xlated - n_pnew)) merged)"

log "Diagnostic flag distribution:"
zcat input/P2change.V2604.merged.gz | awk -F';' '{c[$8]++} END {
  for (k in c) printf "  %-12s %d\n", k, c[k]
}'

log "Step C: rebuild P2change.V2604.s in the original schema (10 cols incl. firstT/lastT)"
if [[ ! -s input/P2change.V2604.s ]]; then
  # GNU awk mktime: 1000x faster than subprocessing date(1) per row.
  # TZ=UTC forces mktime to interpret the broken-down time as UTC;
  # without it the trailing "UTC" string is ignored.
  TZ=UTC zcat input/P2change.V2604.merged.gz \
    | TZ=UTC awk -F';' 'BEGIN{OFS=";"} {
        Pnew=$1; firstLic=$2; firstAdop=$3; lastLic=$4; lastAdop=$5; dist=$6
        split(firstAdop, a, "-")
        split(lastAdop,  b, "-")
        ft = mktime(a[1] " " a[2] " 15 00 00 00")
        lt = mktime(b[1] " " b[2] " 15 00 00 00")
        # Schema: Pnew; firstLic; firstAdop; lastLic; lastAdop; dist; ft; lt; oldList; flag
        print Pnew, firstLic, firstAdop, lastLic, lastAdop, dist, ft, lt, $7, $8
      }' \
    | gzip > input/P2change.V2604.s.tmp \
    && mv input/P2change.V2604.s.tmp input/P2change.V2604.s
else
  log "  cached, skipping"
fi

log "Shard by FNV-1a-32 across 128 buckets (aligns with p2c shards)"
if (( $(ls split/P2change.*.gz 2>/dev/null | wc -l) != 128 )); then
  rm -f split/P2change.*.gz
  zcat input/P2change.V2604.s | "$SPLITSECCH" split/P2change. 128
else
  log "  128 shards already exist, skipping"
fi

log "Done."
ls -lh input/P2change.V2604.s
n=$(ls split/P2change.*.gz | wc -l); echo "  shards: $n"
