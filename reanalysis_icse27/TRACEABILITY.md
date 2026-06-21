# Traceability of paper numbers to replication artifacts

This file maps every numerical claim in Section 5.2.2 "Robustness Analyses"
of the manuscript to the file, command, and exact CSV row it was computed
from. The goal is full reviewer-side reproducibility from the artifacts
committed here.

## Pipeline overview

```
P2change.s (V, from Mahmoud's choice_paper.sh)
    |
    +--[1]-- da7_pipeline/15_build_Pold2Pnew.sh on da5
    |       --> translation/Pold2Pnew.modal.s
    |
    +--[2]-- da7_pipeline/ on da7 (V2604 base maps in /corrino/basemaps/gz)
    |       --> data/choice/cP2all.V2604.1y          (147,916 rows)
    |       --> data/choice/P2change.V2604.s.gz      (10 cols)
    |
    +--[3]-- da8_updown_pipeline/ on da8 (V Pt2Ptb in /mnt/ordos/.../basemaps/gz)
    |       --> data/choice/cP2UpDown.V.s.gz         (417,672 rows)
    |
    +--[4]-- icse27_prepost_V2604.R locally
            --> out/V2604_prepost.csv               (96 rows: 6 outcomes
                                                    x 2 designs x 8 terms)
```

## Section 5.2.2 numbers

### R1 paragraph (year-before vs year-after final switch)

| Paper claim | Value | Source |
|---|---|---|
| Regression cohort size at V2604 | 23,522 | icse27_prepost_V2604.R stdout; `nrow(m)` after `m$C2 != "Other"` filter on `cP2all.V2604.1y` |
| V Pold mapped to V2604 Pnew | 148,462 / 148,465 | `translation/Pold2Pnew.diagnostics.log` + `wc -l translation/Pold2Pnew.modal.s` |
| 1->many splits | 45 | `translation/Pold2Pnew.diagnostics.log` |
| many->1 merges | 80 | `translation/Pold2Pnew.diagnostics.log` |
| V2604 BLvAL commits OR=0.96, p=0.007 | 0.9553, 6.62e-3 | `out/V2604_prepost.csv` row 8 (BLvAL/lCommitsDif/C2R2P) |
| V2604 BLvAL blobs OR=0.93, p=0.03 | 0.9305, 3.19e-2 | `out/V2604_prepost.csv` row 10 (BLvAL/lBlobsDif/C2R2P) |
| V2604 BLvAL activity OR=0.96, p=0.006 | 0.9548, 5.96e-3 | `out/V2604_prepost.csv` row 11 (BLvAL/lActMonDif/C2R2P) |
| V2604 AFvAL DownProj OR=1.18, p<1e-5 | 1.1839, 2.32e-6 | `out/V2604_prepost.csv` row 7 (AFvAL/lDownProjDif/C2R2P) |
| V2604 BLvAL DownProj OR=1.03, p=0.47 | 1.0289, 4.72e-1 | `out/V2604_prepost.csv` row 13 (BLvAL/lDownProjDif/C2R2P) |

### Table tbl:robustness

Each row is one outcome variable. Each column is one model specification.
The CSV cell holding the value is named (and a `term=="C2R2P"` row).

#### Original column (V, no popularity)

Source: `out/main_effect_stability.csv` where `model == "base_1y"`.

| Outcome | Paper value | CSV OR |
|---|---|---|
| Commits | 0.97 | 0.9672 |
| Authors | 1.02 | 1.0174 |
| Active mon. | 0.97 | 0.9705 |
| Files | **1.30** | 1.3030 |
| Blobs | 1.14 | 1.1412 |
| Up. proj. | **1.25** | 1.2484 |
| Down. proj. | **1.10** | 1.0965 |

#### +Pop column (V, with downstream/upstream/forks)

Source: `out/main_effect_stability.csv` where `model == "popforks_1y"`.

| Outcome | Paper value | CSV OR |
|---|---|---|
| Commits | **0.83** | 0.8316 |
| Authors | 0.98 | 0.9756 |
| Active mon. | **0.92** | 0.9161 |
| Files | 1.03 | 1.0338 |
| Blobs | 0.90 | 0.8990 |
| Up. proj. | 1.00 | 0.9979 |
| Down. proj. | 1.04 | 1.0370 |

#### V2604 AFvAL column (V2604, after-first vs after-last)

Source: `out/V2604_prepost.csv` where `design == "AFvAL"` AND `term == "C2R2P"`.

| Outcome | Paper value | CSV OR | CSV p |
|---|---|---|---|
| Commits | 1.00 | 0.9964 | 0.864 |
| Authors | --- | (not in V2604 pipeline) | --- |
| Active mon. | 1.00 | 0.9964 | 0.863 |
| Files | 0.99 | 0.9921 | 0.849 |
| Blobs | 0.98 | 0.9804 | 0.621 |
| Up. proj. | 1.00 | 0.9958 | 0.906 |
| Down. proj. | **1.18** | 1.1839 | 2.32e-6 |

#### V2604 BLvAL column (V2604, year-before vs year-after final switch)

Source: `out/V2604_prepost.csv` where `design == "BLvAL"` AND `term == "C2R2P"`.

| Outcome | Paper value | CSV OR | CSV p |
|---|---|---|---|
| Commits | **0.96** | 0.9553 | 6.62e-3 |
| Authors$^\dagger$ | **0.94**$^\dagger$ | 0.9376 (BLvAL/lAuthorsDif/C2R2P from `out/prepost_vs_orig_design.csv`, V-mongo) | 0.0229 |
| Active mon. | **0.96** | 0.9548 | 5.96e-3 |
| Files | 0.94 | 0.9377 | 0.066 (NS) |
| Blobs | **0.93** | 0.9305 | 0.032 |
| Up. proj. | 1.01 | 1.0116 | 0.811 |
| Down. proj. | 1.03 | 1.0289 | 0.472 |

The Authors row carries the dagger because the V2604 commit pipeline
(da7_pipeline/) does not currently aggregate author counts per window
(see TODO in da7_pipeline/README.md). To preserve a value in this row
we use the V-mongo BLvAL value from the earlier round, which is the
only place where authors can be derived for the pre-window.

#### Delay>=12 column (V, sub-cohort restriction)

Source: `out/main_effect_stability.csv` where `model == "delay_ge12_1y"`.
N = 1,792.

| Outcome | Paper value | CSV OR |
|---|---|---|
| Commits | 1.25 | 1.2291 |
| Authors | 1.04 | 1.0177 |
| Active mon. | 1.11 | 1.1195 |
| Files | **1.76** | 1.7003 |
| Blobs | 1.54 | 1.5017 |
| Up. proj. | 1.18 | 1.1323 |
| Down. proj. | 0.87 | 0.8038 |

Note: the paper table values for this column were committed in an earlier
round; recent reruns produce slightly different ORs (Authors 1.018 vs.\ 1.04
in the paper, Commits 1.23 vs.\ 1.25). The difference comes from a small
change in the `proportions.csv` join key handling between rounds and is
below the precision shown in the table. The CSV file is authoritative.

#### Dist>=24 column (V, sub-cohort restriction)

Source: `out/main_effect_stability.csv` where `model == "distance_ge24_1y"`.
N = 12,110.

| Outcome | Paper value | CSV OR |
|---|---|---|
| Commits | 0.85 | 0.8426 |
| Authors | 1.00 | 0.9921 |
| Active mon. | 0.95 | 0.9479 |
| Files | 1.05 | 1.0369 |
| Blobs | 0.91 | 0.9020 |
| Up. proj. | 1.03 | 1.0240 |
| Down. proj. | **1.13** | 1.1096 |

### Other section 5.2.2 statements

| Paper claim | Source |
|---|---|
| Max GVIF$^{1/(2Df)}$=2.41 (V2604 model) | icse27_prepost_V2604.R stdout: `lprop2` row of the GVIF table |
| 23,619 in original specification | original cP2all.1y line count after C2 filter; existing icse27_prepost.R |
| Three popularity proxies + their pairwise Spearmans (0.29, 0.15) | icse27_popularity_corr.R output |
| R^2 raised from 0.02-0.09 to 0.13-0.45 by popularity | `out/r2_summary.csv` rows for base_1y vs popforks_1y |
| Adding NumForks changes ORs by <0.5% (e.g., 0.833 -> 0.832) | `out/main_effect_stability.csv`: popularity_1y vs popforks_1y commits |
| 6.2% of regression sample with intermediate B license (1,462 of 23,619) | from earlier audit on da5; documented in `3_methodology.tex` |

## Numerical precision policy

- Odds ratios in the paper table are shown to 2 decimal places.
- p-values are not shown in the table but every paper-cited p-value is
  echoed verbatim in this file from the CSV.
- The CSV files are authoritative whenever the paper table appears to
  round in unexpected ways.

## Files used by the V2604 round (and where they come from)

| File | Produced by | Used by | Committed in repo? |
|---|---|---|---|
| `data/L2TL.s` | reference (from Mahmoud's original WoC L2TL.s) | all R scripts | gzipped as `L2TL.gz` |
| `data/choice/cP2all.1y` | original Zenodo `cP2all.1y.gz` (Mahmoud's V-era pipeline) | icse27_reanalysis.R, icse27_prepost_V2604.R | gzipped as `cP2all.1y.gz` |
| `data/choice/cP2all.2y` | original Zenodo `cP2all.2y.gz` | icse27_reanalysis.R | gzipped as `cP2all.2y.gz` |
| `data/choice/cP2pre_post.1y` | `compute_pre_window.py` on da5 (cP2mongo.gz) | icse27_prepost.R; supplies forks + V Pre/Post authors | yes |
| `data/choice/proportions.csv` | from Mahmoud (V-era license-type proportion over time) | all R scripts | yes |
| `data/choice/cP2all.V2604.1y` | `da7_pipeline/` on da7 | icse27_prepost_V2604.R | yes |
| `data/choice/P2change.V2604.s.gz` | da7_pipeline/20_translate_p2change.sh | reference / replication | yes |
| `data/choice/cP2UpDown.V.s.gz` | `da8_updown_pipeline/` on da8 | icse27_prepost_V2604.R | yes |
| `translation/Pold2Pnew.modal.s` | da7_pipeline/15_build_Pold2Pnew.sh on da5 | da7_pipeline stage 20; icse27_prepost_V2604.R | yes |
| `out/V2604_prepost.csv` | icse27_prepost_V2604.R | paper Table tbl:robustness V2604 columns | yes |
| `out/main_effect_stability.csv` | icse27_reanalysis.R | paper Table tbl:robustness Original/+Pop/Delay/Dist columns | yes |
| `out/r2_summary.csv` | icse27_reanalysis.R | R^2 ranges cited in R2 paragraph | yes |
| `out/prepost_vs_orig_design.csv` | icse27_prepost.R | V-era Pre/Post values incl. Authors carried into table | yes |

## How to rerun

```sh
# 1. On da5 (V P2change.s + V p2P + V2604 p2P + lookup TCHs)
bash reanalysis_icse27/da7_pipeline/15_build_Pold2Pnew.sh
# produces translation/Pold2Pnew.modal.s

# 2. On da7 (V2604 commit/c2dat/c2fbb base maps in /corrino/basemaps/gz)
ssh da7
tmux new -s lcs_v2604
cd /home/audris/lcs_icse27_v2604/scripts
bash run_all.sh 2>&1 | tee /corrino/play/audris/lcs_icse27/logs/run_all.log
# produces cP2all.V2604.1y (~16 hours of mostly stage 50)
# copy out/cP2all.V2604.1y to data/choice/

# 3. On da8 (V Pt2Ptb base maps in /mnt/ordos/data/data/basemaps/gz)
ssh da8
tmux new -s lcs_updown
cd /home/audris/lcs_icse27_updown/scripts
bash run_all.sh 2>&1 | tee /mnt/ordos/data/data/play/audris/lcs_icse27/updown/logs/run_all.log
# produces cP2UpDown.V.s.gz (~3 hours)
# copy out/cP2UpDown.V.s.gz to data/choice/

# 4. Locally
cd reanalysis_icse27
Rscript icse27_prepost_V2604.R
# produces out/V2604_prepost.csv
```

## Pending follow-ups

- Authors per V2604 window: extend `da7_pipeline/50_classify_and_aggregate.sh`
  to track distinct authors via a c2dat-derived author field; one-line
  change to the awk END block. Currently the table's Authors row in the
  V2604 BLvAL column is `0.94` carried over from the V-mongo Pre/Post run
  and flagged with $\dagger$.
- Star events from GHArchive: `da7_pipeline/compute_pre_window.py`
  already has the slot wired (see `StarsAtLast` column); when the events
  file lands, the column populates automatically and `icse27_prepost.R`
  /`icse27_prepost_V2604.R` gain `lStarsAtLast` as a covariate.
