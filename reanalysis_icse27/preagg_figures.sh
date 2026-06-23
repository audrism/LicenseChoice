#!/bin/bash
# Pre-aggregate the 470 MB project2licnese_map.csv.gz down to small
# summary files that R can plot from. Avoids loading 75 M rows into R.
set -euo pipefail
cd "$(dirname "$0")"

P2L=project2licnese_map.csv.gz
L2TL=data/L2TL.s

echo "==> top-20 licenses (ever held)"
zcat "$P2L" | awk -F';' '$3 != "latest" {
  k = $1 ";" $2
  if (!(k in seen)) { seen[k] = 1; n[$2]++ }
} END {
  for (l in n) print l ";" n[l]
}' | sort -t';' -k2,2 -nr | head -50 > fig_top_licenses.csv
wc -l fig_top_licenses.csv

echo "==> latest license per project"
zcat "$P2L" | awk -F';' '$3 == "latest" { print $1 ";" $2 }' | sort -u > fig_latest_per_project.csv
wc -l fig_latest_per_project.csv

echo "==> license-type per project (using L2TL map)"
# Build l2tl as awk hash, then for each (project, license) ever held,
# emit (project, type) deduped per project x type.
awk -F';' 'NR==FNR { tl[$1]=$2; next }
  $3 != "latest" {
    t = ($2 in tl) ? tl[$2] : "other"
    k = $1 ";" t
    if (!(seen[k]++)) print $1 ";" t
  }' "$L2TL" <(zcat "$P2L") > fig_per_project_types_ever.csv
wc -l fig_per_project_types_ever.csv

awk -F';' 'NR==FNR { tl[$1]=$2; next }
  $3 == "latest" {
    t = ($2 in tl) ? tl[$2] : "other"
    k = $1 ";" t
    if (!(seen[k]++)) print $1 ";" t
  }' "$L2TL" <(zcat "$P2L") > fig_per_project_types_latest.csv
wc -l fig_per_project_types_latest.csv

echo "==> n_types per project (ever)"
sort -t';' -k1,1 fig_per_project_types_ever.csv | \
  awk -F';' 'BEGIN { OFS=";" } {
    if ($1 != cur) { if (cur != "") print cur, n; cur = $1; n = 1 }
    else n++
  } END { if (cur != "") print cur, n }' > fig_ntypes_per_project.csv
wc -l fig_ntypes_per_project.csv

echo "==> license-type counts ever / latest (for dis3)"
awk -F';' '{ c[$2]++ } END { for (k in c) print k ";" c[k] }' \
  fig_per_project_types_ever.csv > fig_type_counts_ever.csv
awk -F';' '{ c[$2]++ } END { for (k in c) print k ";" c[k] }' \
  fig_per_project_types_latest.csv > fig_type_counts_latest.csv

# Top-20 license latest counts (for dis1 retention)
awk -F';' '{ c[$2]++ } END { for (k in c) print k ";" c[k] }' \
  fig_latest_per_project.csv | sort -t';' -k2,2 -nr | head -50 > fig_top_licenses_latest.csv
wc -l fig_top_licenses_latest.csv

echo "Done."
ls -lh fig_*.csv
