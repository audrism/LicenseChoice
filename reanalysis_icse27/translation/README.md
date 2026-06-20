# V → V2604 project ID translation

Computed by `da7_pipeline/15_build_Pold2Pnew.sh` on da5 using:

- `/da5_data/basemaps/gz/p2PV.s`         (3.3 GB, 209M rows; V-era raw p → P)
- `/da5_data/basemaps/gz/p2PFull.V2604.s` (V2604-era raw p → P, lowercased)

## Recipe

For each unique `P_old` in `P2change.s`:

1. Find every raw `p` whose V-era `p2P` is `P_old` (inverse scan of `p2PV.s`).
2. Lowercase each raw `p` (V2510+ normalization).
3. Look up each lowercased `p` in V2604's `p2P` → set of candidate `P_new`.
4. Pick the **modal** `P_new` per `P_old`.

## Diagnostics

- Input: 148,465 unique V-canonical project IDs.
- Mapped: **148,462** (3 lost: no surviving raw p in V2604).
- 1→many (V cluster split in V2604): **45 Pold** (~0.03%).
- many→1 (V2604 merged ≥2 V projects): **80 Pnew** (~0.05%).

Fanout distribution (`Pold2Pnew.with_counts.s` col 3 = # distinct Pnew per Pold):
```
148417  1     (single target, clean)
    29  2
     7  3
     5  4
     1 10
     1 12
     1 31
     1 101   (heavily-forked outlier; modal vote still resolves)
```

## Files

| File | Purpose |
|---|---|
| `Pold2Pnew.modal.s` | final P_old;P_new mapping used by stage 20 of the V2604 pipeline |
| `Pold2Pnew.with_counts.s` | P_old;P_new;fanout;modalCount — for the supplement / sanity checks |
| `Pold2Pnew.diagnostics.log` | summary counters |
