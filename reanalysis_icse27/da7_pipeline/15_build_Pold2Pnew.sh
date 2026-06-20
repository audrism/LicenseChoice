#!/bin/bash
# Build Pold2Pnew.V2604.s on da5 using the four-step recipe:
#   Pold (V-canonical) -> raw p list  via inverse of p2PV.s
#   raw p -> lowercase                (V2510+ normalization)
#   lowercased p -> Pnew              via p2PFull.V2604.s
#   compose -> per-Pold modal Pnew    with fanout diagnostics
#
# Runs on da5. Outputs land in /home/audris/lcs_icse27_v2604/translation/.
# Logs unusual situations (1->many Pold splits, many->1 Pold merges) so we can
# eyeball them in the supplement.

set -euo pipefail

WORK=/home/audris/lcs_icse27_v2604/translation
mkdir -p "$WORK"
cd "$WORK"

P2CHANGE=/home/mjahansh/repos/lcs/data/choice/P2change.s
P2P_V=/da5_data/basemaps/gz/p2PV.s            # 209M rows  (p ; P  at V)
P2P_V2604=/da5_data/basemaps/gz/p2PFull.V2604.s

log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }

# ---- 1. Unique V-canonical project IDs that appear in P2change.s ----
log "Step 1: extract unique Pold IDs from P2change.s"
zcat "$P2CHANGE" | cut -d';' -f1 | LC_ALL=C sort -u > Pold.list
log "  Pold count: $(wc -l < Pold.list)"

# ---- 2. Inverse map P_old -> raw p, by streaming p2PV.s once ----
# p2PV.s is keyed by raw p; value is P. We want the rows where the V-canonical P
# is one of our Pold's. Load Pold.list into awk hash (~148k entries, tiny memory),
# stream the 3.3 GB gz file once.
log "Step 2: streaming p2PV.s, filter to rows whose P is in Pold.list"
zcat "$P2P_V" \
  | awk -F';' 'NR==FNR { keep[$1]=1; next } $2 in keep { print $1";"$2 }' \
        Pold.list - \
  | gzip > Pold2p.flat.gz
log "  raw-p hops kept: $(zcat Pold2p.flat.gz | wc -l)"

# ---- 3. Lowercase the raw p column ----
log "Step 3: lowercase raw p"
zcat Pold2p.flat.gz \
  | awk -F';' 'BEGIN{OFS=";"} {print tolower($1), $2}' \
  | LC_ALL=C sort -u -t';' -k1,1 \
  | gzip > Pold2pLow.flat.gz
log "  unique (pLow, Pold) pairs: $(zcat Pold2pLow.flat.gz | wc -l)"

# ---- 4. Lookup each lowercased p in V2604 p2P ----
# p2PFull.V2604.s is keyed by lowercased p (single file).  Sort it by p (key) and
# join.
log "Step 4: join with p2PFull.V2604.s by p"
LC_ALL=C join -t';' -1 1 -2 1 \
  <(zcat Pold2pLow.flat.gz) \
  <(zcat "$P2P_V2604" | LC_ALL=C sort -t';' -k1,1) \
  | awk -F';' 'BEGIN{OFS=";"} {
      # input columns: pLow ; Pold ; Pnew(from V2604 p2P)
      print $2, $3
    }' \
  | LC_ALL=C sort -u \
  | gzip > Pold_Pnew.pairs.gz
log "  (Pold, Pnew) pairs after V2604 lookup: $(zcat Pold_Pnew.pairs.gz | wc -l)"

# ---- 5. Modal Pnew per Pold + fanout diagnostics ----
log "Step 5: pick modal Pnew per Pold; log unusual situations"
zcat Pold_Pnew.pairs.gz \
  | LC_ALL=C sort -t';' -k1,1 \
  | awk -F';' '
      function flush(   k, n) {
        if (cur == "") return
        n = 0; for (k in cnt) n++
        print cur";"best > "/dev/stdout"
        print cur";"best";"n";"bestc >> "Pold2Pnew.with_counts.s"
        if (n > 1) n_split++
      }
      $1 != cur {
        flush(); cur=$1; best=$2; bestc=1; delete cnt; cnt[$2]=1; next
      }
      {
        cnt[$2]++
        if (cnt[$2] > bestc) { best=$2; bestc=cnt[$2] }
      }
      END {
        flush()
        printf "1->many Pold splits: %d\n", n_split > "/dev/stderr"
      }' \
  > Pold2Pnew.modal.s 2> Pold2Pnew.diagnostics.log

# many-to-one diagnostic (multiple Polds resolving to same Pnew)
LC_ALL=C sort -t';' -k2,2 Pold2Pnew.modal.s \
  | awk -F';' '
      $2 != cur { if (n>1) m++; cur=$2; n=1; next }
      { n++ }
      END {
        if (n>1) m++
        printf "many->1 Pnew merges: %d\n", m
      }' >> Pold2Pnew.diagnostics.log

log "Pold2Pnew.modal.s rows: $(wc -l < Pold2Pnew.modal.s)"
log "Diagnostics:"
cat Pold2Pnew.diagnostics.log

log "Done. Final artifact: $WORK/Pold2Pnew.modal.s"
ls -lh Pold2Pnew.modal.s Pold2Pnew.with_counts.s
