# ICSE 2027 Reanalysis

This folder contains code and intermediate data for the robustness analyses
added to the ICSE 2027 revision in response to ICSE 2026 reviewer feedback.

## Contents

- `compute_pre_window.py` — Python script (run on da5 over the WoC mongo
  aggregates) that computes per-project commit, author, and active-month
  counts for the year *before* and the year *after* the final license
  adoption. Output: `data/choice/cP2pre_post.1y` (committed).
- `icse27_prepost.R` — R script that fits the year-before/year-after
  comparison model and compares with the original design.
- `icse27_reanalysis.R` — R script that adds the popularity covariates
  (`lFirstDownP`, `lFirstUpP`) to the original model and fits sub-cohort
  models (`Delay>=12`, `Distance>=24`) and the 2-year-window variant.
- `data/choice/cP2pre_post.1y` — pre/post-final-switch aggregates (the
  only large data file committed; the rest comes from the original Zenodo
  package at https://zenodo.org/records/15031139).

## How to reproduce

1. Download the original replication package from
   <https://zenodo.org/records/15031139> and place
   `cP2all.1y.gz`, `cP2all.2y.gz`, `L2TL.gz` and `proportions.csv`
   under `data/` and `data/choice/`. (See the original README for format.)
2. Decompress: `zcat L2TL.gz > data/L2TL.s`, etc.
3. Run `Rscript icse27_reanalysis.R` (popularity + sub-cohort robustness).
4. Run `Rscript icse27_prepost.R` (year-before/year-after design).

## Re-generating `cP2pre_post.1y`

This requires access to the WoC mongo aggregate file
`/home/mjahansh/repos/lcs/data/choice/cP2mongo.gz` on the WoC cluster
(da5). The Python script `compute_pre_window.py` produces it.
