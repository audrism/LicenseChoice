# License Choice, Prevalence, and Impact in Open Software Projects

This repository hosts two LaTeX builds of the same paper:

| Build | Master file | Class | Page budget | Where it goes |
|---|---|---|---|---|
| **arXiv / manuscript** | `0_main.tex` | `acmart` manuscript (single column) | unlimited | arXiv (frozen as of commit `904d3a8`) |
| **ICSE'27 technical track** | `icse27_main.tex` | `IEEEtran` 10pt conference (two column) | 10 pages body + unlimited refs | active submission target |

Both files include the same shared content fragments:

```
1_introduction.tex
2_background.tex
3_methodology.tex
4_results.tex
5_limitations.tex
7_conclusions.tex
8_appendix.tex          % only included by 0_main.tex
```

Use the `\icsetrim{...}` macro around any paragraphs that should appear in
the arXiv build but be omitted from the ICSE'27 build for space:

```latex
\icsetrim{This paragraph is in the arXiv version only.}
```

The macro is the identity in `0_main.tex` (arXiv) and a no-op in
`icse27_main.tex` (ICSE'27), so the same source compiles into both.

## Building

```sh
# arXiv
pdflatex 0_main && bibtex 0_main && pdflatex 0_main && pdflatex 0_main

# ICSE'27
pdflatex icse27_main && bibtex icse27_main && pdflatex icse27_main && pdflatex icse27_main
```

## Reanalysis / replication

`reanalysis_icse27/` holds the post-ICSE'26 robustness reanalysis
artifacts (popularity controls, V2604 alignment, bot-filtered author
counts, V-era Pt2Ptb upstream/downstream).  See
[`reanalysis_icse27/README.md`](reanalysis_icse27/README.md) for the
pipeline overview and
[`reanalysis_icse27/TRACEABILITY.md`](reanalysis_icse27/TRACEABILITY.md)
for the line-by-line mapping from each paper-cited number to the CSV row
that produced it.

## Submission history

| Round | Venue | Decision | Reviewer comments |
|---|---|---|---|
| 1 | FSE'25 | reject | `submissions/01_fse25/` |
| 2 | ICSE'26 | reject | `submissions/02_icse26/` |
| 3 | MSR'26 | reject | `submissions/03_msr2026/` |
| 4 | ICSE'27 | in preparation | -- |
