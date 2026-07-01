# Changes since submitted PDF

Baseline: `icse2027-paper1789.pdf` (commit `3029a0b`, 30 Jun 2026, 12 pages).
Current: commit `c0b0b55` (12 pages, matching budget).

Net diff: 6 files, +237 / −155 lines.

## Correctness

- **Table III BLvAL numbers verified against coauthor's model.** Sourced
  from `github.com/woc-hack/lcs/blob/main/analysis/tosem_license_change.ipynb`
  (BLvAL model uses the *same* $N$=23{,}619 sample and the *same*
  predictors as AFvAL). Numbers are unchanged from the submitted table
  (0.98 / 0.88 / **0.84** / 0.99 / **0.92** / 1.03 / 0.99), and are now
  each accompanied by a 95% CI computed from the notebook's β and SE.
- **Table III AFvAL now has 95% CIs** for the seven Global R2P outcomes,
  sourced from the `popularity_1y` model in
  `reanalysis_icse27/out/odds_ratios_all_models.csv`.
- **Table III caption** now says explicitly "same $N$=23{,}619 sample
  with the same predictors" so readers do not wonder whether AFvAL and
  BLvAL come from different fits.
- **Intro BLvAL numbers** now reference the correct BLvAL values (0.84
  commits, 0.92 active months) rather than the previously
  AFvAL-misattributed 0.83 / 0.92.
- **§V-B Robustness** now states that the two designs' point estimates
  agree within their CIs and that the Files divergence (1.04 AFvAL vs.
  0.99 BLvAL) is not significant in either design.

## Clarifications / flow

- **"Preliminary theory" reframed as "conceptual framework"** throughout
  intro, background, and results (contribution list (a), (c); §II title;
  Table IV title and caption; the "operationalize license choice" clause
  in §I). Addresses the prior reviewer critique that the paper
  overclaimed a theory rather than delivering a literature synthesis.
- **Colloquial "significant" → "substantial"** at four sites where no
  statistical test was attached (intro L14/L16; §II Comparisons-to-Prior-Work;
  Key Findings item 1).
- **"Key" → "the" / "project outcomes"** at two sites (§I framework's
  predicted effect; §III-A metrics computation).
- **§III-A** points readers to the replication package for the manually
  classified top-50 SPDX list rather than promising an in-paper listing
  we do not actually include.
- **§III-C** shortened redundant A→B→C example (6 lines → 2).
- **§III-C regression preamble** consolidated the textbook-ish
  description of multivariate multiple regression into one clause.
- **§V-A Table I caption** clarifies that the *No License* column is a
  fraction of *all* projects in each study while the five license-type
  columns are shares of the licensed subset (rows sum to 100% within
  licensed).
- **§V-B (Findings)** dropped the content-free summary sentence "These
  quantified magnitudes, along with their directions, clearly demonstrate
  ..." — "clearly demonstrate" editorializes.
- **§V-B Implications** adds one flagged-speculative sentence on the
  C/C++ vs. Python community-composition mechanism (Python leans
  permissive per Lerner & Tirole 2005, so moving toward permissive
  aligns with the ambient norm; C/C++ that adopts copyleft attracts
  copyleft-motivated contributors, and relaxing that may erode the
  pool).
- **§VI (Limitations)** now covers three additional threats that were
  either missing or under-treated in the submitted version:
  - Regression-cohort selection: the 22.3M → 23{,}619 filter chain and
    the ~17% licensed / ~0.02% of ecosystem framing in one paragraph
    (formerly two overlapping paragraphs on "regression-cohort scope"
    and "switcher-cohort selection").
  - Popularity proxies: explicitly notes that the same pre-treatment
    upstream/downstream measure is used in both the AFvAL and BLvAL
    designs (and that fork/star counts are deferred).
  - Construct validity of activity metrics: commit-graph proxies (a
    commit is not a unit of "health"; blob/file growth mixes substantive
    additions with generated code; active-months treat one maintenance
    commit the same as a productive burst).
- **§I intro** dropped the trailing sentence that restated the prior
  point on unlicensed repositories' contribution to larger projects
  (redundant with the immediately-preceding sentence citing the same
  Jahanshahi paper).

## References

- **DOI coverage** raised from 4/47 → **41/47** used citations.
- **13 recent ICSE-adjacent DOIs added** (first pass): WoC papers, the
  Jahanshahi series, `wu2024large`, `cui2023empirical`, `wolter2023open`,
  `xu2023lidetector`, `feng2019open`, `fry2020dataset`,
  `chowdhury2021untriviality`, `mockus2020complete`, `ma2019world`,
  `ma2021world`.
- **24 older-references DOIs added** (second pass, delegated + Crossref-verified):
  `bird2009putting`, `borges2018s`, `capiluppi2003characteristics`,
  `colazo2009impact`, `dahlander2008firms`, `fershtman2007open`,
  `fitzgerald2006transformation`, `gamalielsson2017licensing`,
  `kapitsaki2019modeling`, `kapitsaki2022help`, `kechagia2010open`,
  `koch2002effort`, `lamba2020heard`, `lerner2005economics`,
  `mockus2007large`, `sen2008determinants`, `shah06`,
  `shoroye2015exploring`, `socialcoding`, `stewart2006impacts`,
  `tsay2014influence`, `von2012carrots`, `xu2024first`, `zhou2016inflow`.
- **6 remaining without DOI** are deliberate — DOI is not registered at
  any resolver for these: `d2007copyleft`, `de2009creative`,
  `kaminski2007open`, `laurent2012free`, `wagstrom2010impact` (Academy
  of Management meeting), `yu2023codeipprompt` (PMLR — no Crossref DOI).

## Figures

No net change vs. submitted. Figures 1–4 (dis1, dis3, proportion, pie)
were briefly swapped to older-vintage `.pdf` versions in commit `80082ea`
and reverted back to the submitted `.png` versions in commit `d65cb50`
after the coauthor comment; the current `\includegraphics` paths point
to the same `.png` files that the submitted PDF references (byte-identical
MD5s: `6ba7fab / fdb8fdc / 71b7b16 / e2d18d1`).

## Housekeeping

- `reanalysis_icse27/icse27_prepost.R`: `fit_uni` calls now pass
  `with_forks=FALSE` so the written CSV output matches the paper's
  stated primary spec (popularity controls, no forks). The intermediate
  BLvAL-only-3-outcome CSV that motivated the incorrect n/a change has
  since been superseded by the coauthor's authoritative 7-outcome model.

## Page budget

Submitted: 10 body + 2 refs = 12 pages.
Current: 10 body + 2 refs = 12 pages.

Content added (CIs, threats, mechanism speculation, framing fixes,
Files-divergence sentence) was offset by prose tightening plus the
coauthor's margin adjustments to Table I, Table II, and Fig 4.
