# ICSE 2027 Reanalysis

Robustness and reanalysis artifacts for the ICSE 2027 revision of
*"License Choice, Prevalence, and Impact in Open Software Projects."*

For a line-by-line audit of every number cited in Section 5.2.2 of the
paper, see [`TRACEABILITY.md`](./TRACEABILITY.md).

## Overview of the V2604 round (primary new contribution)

Aligned reanalysis on WoC V2604 base maps. Three pipelines produce the
inputs to one R analysis:

| Pipeline | Where it ran | What it produced |
|---|---|---|
| `da7_pipeline/15_build_Pold2Pnew.sh` | da5 | `translation/Pold2Pnew.modal.s` (V$\to$V2604 project-ID map, 148,462 rows) |
| `da7_pipeline/` (10–60) | da7 (`/corrino/`) | `data/choice/cP2all.V2604.1y` (147,916 rows, FIRST/LAST/PRE windows for commits, files, blobs, active months) |
| `da8_updown_pipeline/` | da8 (`/mnt/ordos/`) | `data/choice/cP2UpDown.V.s.gz` (417,672 rows, FIRST/LAST/PRE windows for upstream and downstream projects) |
| `icse27_prepost_V2604.R` | local | `out/V2604_prepost.csv` (96 rows: 6 outcomes x 2 designs x 8 terms) |

Total wall-time: ~16 hours for da7 stage 50, ~3 h for da8, ~5 s for R.

## Earlier (V-era) artifacts still relevant

| Artifact | Purpose | Produced by |
|---|---|---|
| `out/V2604_prepost.csv` | V2604 BLvAL + AFvAL main effects and interactions | `icse27_prepost_V2604.R` |
| `out/main_effect_stability.csv` | V-era Original / +Pop / +Pop+Forks / Delay / Distance main effects | `icse27_reanalysis.R` |
| `out/r2_summary.csv` | R^2 ranges per model spec at V | `icse27_reanalysis.R` |
| `out/odds_ratios_all_models.csv` | full OR matrix per model at V | `icse27_reanalysis.R` |
| `out/prepost_vs_orig_design.csv` | V-mongo Pre/Post (used by the Authors row in the table) | `icse27_prepost.R` |
| `out/merged_prepost.csv` | merged V cP2all + V mongo aggregates | `icse27_prepost.R` |

## How to reproduce (full)

See the "How to rerun" section at the bottom of `TRACEABILITY.md` for the
exact commands. Short version:

```
# 1. Translation (da5, ~7 min)
bash da7_pipeline/15_build_Pold2Pnew.sh

# 2. V2604 commit pipeline (da7, ~16 h)
ssh da7; tmux new -s lcs_v2604
cd /home/audris/lcs_icse27_v2604/scripts
bash run_all.sh 2>&1 | tee /corrino/play/audris/lcs_icse27/logs/run_all.log

# 3. V Pt2Ptb pipeline (da8, ~3 h)
ssh da8; tmux new -s lcs_updown
cd /home/audris/lcs_icse27_updown/scripts
bash run_all.sh 2>&1 | tee /mnt/ordos/data/data/play/audris/lcs_icse27/updown/logs/run_all.log

# 4. R analysis (local, ~5 s)
Rscript icse27_prepost_V2604.R
```

## Inventory

```
.
+- README.md                     this file
+- TRACEABILITY.md               every paper number -> CSV row mapping
+- .gitignore                    excludes /tmp, /out partials
+- L2TL.gz                       license -> license-type map (V-era)
+- cP2all.1y.gz                  original Zenodo replication (V-era 1y windows)
+- cP2all.2y.gz                  original Zenodo replication (V-era 2y windows)
+- compute_pre_window.py         derives V-era Pre/Post via cP2mongo (da5)
+- data_curation.sh              original Mahmoud choice_paper.sh stages 1-4
+- regression_model.ipynb        original V-era regression
+- icse27_reanalysis.R           V-era reanalysis (Original/+Pop/Forks/Delay/Distance)
+- icse27_popularity_corr.R      popularity proxy correlation/VIF check
+- icse27_prepost.R              V-era BLvAL design (commits/authors/activeMon only)
+- icse27_prepost_V2604.R        V2604-aligned BLvAL+AFvAL (all 6 outcomes)
+- da7_pipeline/                 V2604 commit window pipeline (da7)
+- da8_updown_pipeline/          V Pt2Ptb upstream/downstream pipeline (da8)
+- translation/                  V -> V2604 project-ID translation + diagnostics
+- data/
|   +- L2TL.s
|   +- choice/
|       +- cP2all.1y             V-era (uncompressed for R speed)
|       +- cP2all.2y
|       +- cP2all.V2604.1y       V2604 (this round's principal artifact)
|       +- cP2pre_post.1y        V-era Pre/Post aggregates
|       +- cP2UpDown.V.s.gz      V-era Pt2Ptb windows (this round)
|       +- P2change.V2604.s.gz   V2604-canonical change projects
|       +- proportions.csv       license-type proportions over time (V-era)
+- out/
    +- V2604_prepost.csv         V2604 round results
    +- main_effect_stability.csv V-era main effects across specs
    +- r2_summary.csv
    +- odds_ratios_all_models.csv
    +- prepost_vs_orig_design.csv
    +- merged_prepost.csv
```

## Pending follow-ups (not blockers)

1. **Pt2Ptb has no V2604 build.** Upstream/downstream windows are computed
   at V and translated to V2604 IDs via `Pold2Pnew.modal.s`. The V$\to$V2604
   churn is <0.1%, so the V-canonical edge data is effectively V2604-aligned
   after translation.
2. **Stars are not yet incorporated.** The GHArchive star map is being
   ingested separately; `compute_pre_window.py` already has the column
   slot wired (`StarsAtLast`, `StarsTotal`), so plugging the events file
   in re-populates the column without further code changes.
