# V2604 reanalysis pipeline (da7 / ishia)

Aligned to WoC V2604, this pipeline computes year-window aggregates around the
**first** and **last** license adoptions of each license-change project, plus a
new **pre-last** window (year before the final license switch) for a clean
year-before / year-after comparison.

Output: `cP2all.V2604.1y` (semicolon-separated flat file) with one row per
project containing license metadata followed by 3 × (Ncmt, Nfiles, Nblobs,
ActMon) triples for FIRST, LAST, and PRE windows.

## Pre-flight assumptions (verified before writing)

- `/corrino/play/audris/lcs_icse27/` exists and is writable (36 TB free).
- V2604 maps present at `/corrino/basemaps/gz/`:
  `p2cFull.V2604.{0..127}.s`, `c2datFull.V2604.{0..127}.s`,
  `c2fbbFull.V2604.{0..127}.s` (128 shards each).
- `pOld2pNew.V2604.s` is **not** on da7; it will be `scp`'d from
  `da5:/da5_data/basemaps/gz/pOld2pNew.V2604.s` (~5.9 GB).
- WoC helpers `~/lookup/{lsort, splitSec.perl, splitSecCh.perl}` are NFS-shared
  from da8 and work the same on da7.

## Memory profile

Tuned for da7 (32 cores, 376 GB RAM, vs. da5's 80 cores / 1.2 TB):

- `PAR=8`: up to 8 shard jobs concurrent.
- `LSMEM=1G`, `SORTMEM=1G`: each in-job sort caps at ~1 GB.
- Peak in the heaviest stage (50): 8 × 3 concurrent sorts/joins × 1 GB ≈ 24 GB.
  Leaves plenty for OS cache, which dominates I/O for this workload.

Bump `PAR=16` (or higher) if da7 is otherwise idle:
`PAR=16 bash run_all.sh`

## Running

```bash
# On da7
ssh da7
tmux new -s lcs_v2604
cd /home/audris/lcs_icse27_v2604/scripts     # wherever you put these
bash run_all.sh 2>&1 | tee /corrino/play/audris/lcs_icse27/logs/run_all.log
```

Each stage is **idempotent**: it skips work for shards whose output already
exists. After a partial failure, just re-run `run_all.sh`.

## Stage map

| # | Script | What it does | Wall-clock estimate (PAR=8) |
|---|---|---|---|
| 1 | `10_stage_inputs.sh` | scp P2change.s + pOld2pNew.V2604.s from da5; cardinality probe | 5--10 min |
| 2 | `20_translate_p2change.sh` | translate V→V2604 project IDs; add firstT/lastT epochs; shard by FNV-1a | 15 min |
| 3 | `30_join_p2c.sh` | for each shard i, join P2change with p2cFull.V2604.i → all change-project commits | 30--45 min |
| 4 | `40_reshard_by_commit.sh` | repartition (project,commit) rows by commit hash | 15 min |
| 5 | `50_classify_and_aggregate.sh` | per shard: join with c2dat (classify FIRST/LAST/PRE), join with c2fbb (file,blob), aggregate per project×window | 1.5--2.5 h |
| 6 | `60_merge_and_assemble.sh` | merge per-shard aggregates, pivot to wide cP2all.V2604.1y | 30 min |

**Total**: ~3--4 hours wall-clock with `PAR=8`. Heavier `PAR` shortens stage 5
roughly proportionally up to disk-I/O limits.

## Output schema (`out/cP2all.V2604.1y`)

```
project; firstLic; firstAdop; lastLic; lastAdop; distance; firstT; lastT;
  firstNcmt; firstNfiles; firstNblobs; firstActMon;
  lastNcmt;  lastNfiles;  lastNblobs;  lastActMon;
  preNcmt;   preNfiles;   preNblobs;   preActMon
```

The `project` column is the V2604 canonical ID; the original V canonical is
also tracked through the pipeline (in `input/P2change.V2604.s` column 9) for
join-back to the prior analysis.

## What this does NOT compute

- **Upstream / downstream project counts** at V2604 — `Ptb2Pt` has no V2604
  build yet. They will need a separate pass with the V `Ptb2PtFullV*.s`
  shards once that round is in scope. The R analysis can use the original
  V `firstUpP` / `firstDownP` as covariates in the meantime.
- **Authors per window** — `c2dat` field 4/5 give the author identity but the
  pipeline currently only counts months and commits. Adding a 5th aggregate
  field (`nauth`) is a one-line tweak to stage 5; left out for now to keep
  the heaviest stage as lean as possible. If you want it, add to the awk
  END block:
  ```awk
  akey = pid SUBSEP w SUBSEP $author_field
  ...
  cnt_a[pid SUBSEP w] = number of distinct akeys
  ```
  using `$N` for the author field after the c2dat join.

## Sanity checks built in

- Stage 1 prints `1->many old keys` count from `pOld2pNew.V2604.s`. If this is
  > 0 in non-trivial numbers, the V→V2604 mapping is not a function and we
  should pick a tiebreaker (currently: `lsort -u` keeps one).
- Stage 5 leaves per-shard logs in `logs/shard.$j.log`; failures will leave the
  output file absent and re-running picks them up automatically.
- Stage 6 reports FIRST/LAST/PRE non-zero counts so we can tell at a glance
  whether the pre-window is actually populated for most projects.

## After the pipeline finishes

Copy `out/cP2all.V2604.1y` back to the analysis host and feed it to a new
`icse27_prepost_V2604.R` script (analogous to the existing `icse27_prepost.R`)
that consumes the FIRST/LAST/PRE columns directly. Compare the V2604 PRE-vs-LAST
estimate to the existing V Pre/Post estimate for a final consistency check.
