* License Choice, Prevalence, and Impact in Open Software Projects

Score: 2. Weak Reject

Reviewer Expertise: I am knowledgeable on this topic

** Summary

Large-scale empirical study of OSS licensing on World of Code (WoC).
Two arcs: (i) descriptive characterization across 131M projects, with
the headline that 83% lack a formal license (four-fold prior reports
that filtered on stars/maturity); (ii) multivariate multiple regression
on 23,619 projects that switched between permissive and restrictive
licenses, modeling eight project metrics with language interactions.

This is the ICSE'27 revision of a paper rejected at ICSE'26 and MSR'26.
The new Section 5.2.2 adds: R1 a year-before vs. year-after design
("V2604 BLvAL"); R2 popularity covariates (downstream, upstream,
lifetime forks); R3 sub-cohort restrictions on adoption-delay and
inter-switch distance; R4 exclusion of the intermediate-license edge
case. The V2604 reanalysis adds bot/homonym-filtered distinct
aliased-author counts. The new headline is more qualified:
language-specific patterns (C/C++ negative, Python positive) are
robust, while global R2P effects on files (1.30 -> 1.04), upstream
(1.25 -> 1.00), and downstream (1.10 -> 1.04) attenuate to NS once
popularity is controlled; commits (0.97 -> 0.83) and active months
(0.97 -> 0.92) become newly significant.

The revision substantially addresses the popularity-control and
window-asymmetry concerns from prior cycles. The *integration* of
the new analyses is incomplete: abstract, intro, and Section 5.2.1
still lead with the original (now-confounded) numbers; hypotheses
remain unevenly mapped to results; presentation issues flagged in
two prior cycles persist.

** Novelty

RQ1's 131M-project coverage and the resulting four-fold revision of
the no-license rate is a real delta over [Wu 2024] (3.47M, 5 package
managers, 21%) and [Cui 2023] (>=1000-star, 10.51%). Table 2 makes
this comparison clear. The within-project regression (RQ2) is less
novel by itself but the combination of language interactions with
popularity controls in the revision is useful. The "preliminary
theory" framing remains overstated: Section 2 is a literature
synthesis that yields hypotheses, not a formal theory construction.
MSR'26's reviewer flagged this and it is not addressed.

** Soundness

*Abstract/Section 1/Section 5.2.1 inconsistent with robustness
analyses.* Most consequential problem. Abstract (lines 18-19), intro
(105-108), and per-metric narrative in Section 5.2.1 (pp.15-16) all
report original ORs (files 1.30, upstream 1.25, downstream 1.10).
Table 5 shows that under +Pop these collapse to 1.04 (NS), 1.00 (NS),
1.04 (NS). The "more nuanced story" paragraph (p.18, lines 919-924)
endorses the +Pop result. A reader who stops at the abstract or the
original Key Findings on p.12 gets the wrong message.

*Specifications disagree; paper does not adjudicate.* Table 5 Files
row: 1.30 (Orig, sig), 1.03 (+Pop, NS), 1.03 (V2604 AFvAL, NS), 0.95
(V2604 BLvAL, NS), 1.76 (Delay>=12, sig), 1.05 (Dist>=24, NS). The
Delay>=12 cell flips sign and is significant only in an N=1,792
sub-cohort, yet is shown alongside full-cohort columns as comparable.
The paper should commit to a primary specification.

*BLvAL silent on upstream/downstream.* The p.18 text frames downstream
attenuation under BLvAL (OR=1.03, p=0.47) as "longer time horizon."
In reverse: BLvAL cannot adjudicate upstream/downstream because
pre-window Pt2Ptb counts do not exist in V2604. Key Findings item 8
acknowledges this only as a side note. The design prior reviewers
asked for is silent on the two outcomes most attenuated by +Pop;
this should be stated as a major limitation, not buried.

*Hypothesis-to-result mapping remains weak.* Third cycle this has
been raised. Key Findings tags items with "cf. H2b" / "cf. H2c"
without saying supported / partially / unsupported. H1a is
confusingly mapped: C/C++ R2P OR=0.95 is labeled "partially confirms
H1a"; Go R2P OR=1.08 *disconfirms* H1a but is not labeled. No
consolidated H-by-H verdict table.

*Residual causal/prescriptive language.* Methodology line 393 has
softened, but Implications slips: "permissive licensing tends to
lower commit frequency," "permissive licenses *boost* burst-like
activity," "Python projects *benefit*." With observational data, a
2.4% sample, and several ORs that flip across specifications, this
overstates what the design supports.

*Sample selection not transparent in front matter.* The regression
cohort is 23,619 projects: the *middle* slice with multiple license
types in lifetime but one at end (2.4% of licensed, ~0.4% of 131M).
Both ICSE'26 and MSR'26 reviewers asked that this be stated in the
abstract and intro. Still missing.

*Author-count filter underspecified.* Table 5 caption (lines 887-890)
describes the bot/homonym blocklist but does not state (a) the
fraction of projects affected, (b) per-project median impact, (c)
whether filtering is symmetric across pre- and post-windows. The
OR=0.96 author effect cannot be assessed without (c).

*Multiple comparisons.* 7 outcomes x 6 specifications = 42 ORs;
several borderline (0.83-0.96) effects are flagged significant. No
adjustment mentioned. Bonferroni or BH would meaningfully change the
count of surviving effects, especially the 4% BLvAL attenuations.

** Significance

The RQ1 contribution (83% no-license, sampling-sensitivity) is
field-meaningful. The language-stratified regression, *if* the
C/C++-negative / Python-positive interaction is the headline (it
should be), has implications for licensing recommenders. But the
Implications section is too long and too prescriptive given the
modest R^2 (0.13-0.45 with popularity) and the attenuation of global
effects. It reads as if drafted before the robustness analyses and
not rewritten after.

** Verifiability

Replication package is concrete and split between the original Zenodo
record and the new robustness supplement. The V to V2604 ID translation
recipe (p.17) and bot blocklist provenance (p.18) are good practice.

** Presentation

Multiple issues flagged in both prior cycles remain:

- Figures 1, 2, 3 use tiny, pixelated PNG fonts (flagged ICSE'26 C);
  should be PDF with legible fonts.
- Figure 1 connects categorical retention points with a line, which
  implies meaningless ordering (flagged ICSE'26).
- Section 4.1 still bundles "Public Domain" and "Unlicensed" into one
  category (flagged ICSE'26 B and MSR'26 B). The paper elsewhere
  treats no-license and CC0/Unlicense as conceptually distinct.
- "[?]" reference errors on p.5 (lines 242, 245, 250, 255) in the
  H3a-H3d derivation paragraphs. Not minor: they sit in the
  hypothesis-justification logic.
- Abstract is dense and comma-deficient (flagged ICSE'26 and MSR'26);
  still is. Does not state the 2.4% sample restriction.
- Section 7 "Future Work" is an empty heading (p.20, line 1018).
  Unacceptable for a third-cycle submission.
- Section 4.1 says 50 of 597 licenses were classified; Appendix A
  lists noticeably fewer than 50 SPDX IDs. Reconcile.
- Section 5.2.2 ends with a new Key Findings box that contradicts
  the older Key Findings box on p.12 (post-Section 5.1) and the
  narrative numbers in Section 5.2.1. The reader is given two
  conflicting takeaway boxes within one paper.
- The Limitations section (p.20) is shallow: no mention of the
  2.4% sample selection, the BLvAL upstream/downstream gap,
  multiple comparisons, or the Implications-vs-evidence mismatch.

** Strengths

- Genuine descriptive contribution: 131M-project no-license rate is
  a useful field correction; sampling-sensitivity framing is right.
- Robustness analyses (R1-R4) are the right response to prior reviewer
  concerns and meaningfully change the conclusions.
- V2604 bot/homonym filter on author counts is a methodological
  improvement.
- Popularity controls with GVIF reporting and the R^2 jump from
  0.02-0.09 to 0.13-0.45 is a substantive answer to ICSE'26 A.
- Honest reporting that headline effects collapse under +Pop is good
  practice; it should be foregrounded, not buried.

** Weaknesses

- Abstract, intro, and Section 5.2.1 still lead with original
  (now-confounded) odds ratios; two contradictory takeaways in one
  paper.
- BLvAL specification (the one prior reviewers asked for) is silent
  on upstream/downstream because pre-window Pt2Ptb data are
  unavailable in V2604; not flagged as a major limitation.
- Hypothesis-to-result mapping remains scattered; no consolidated
  H-by-H verdict.
- Delay>=12 sub-cohort (N=1,792) Files OR=1.76 contradicts every
  other specification and is presented without discussion.
- Empty Section 7 (Future Work).
- Shallow Limitations: no 2.4%-sample caveat, no multiple-comparisons
  discussion, no acknowledgment of the BLvAL gap.
- "[?]" reference errors on p.5 in H3a-H3d hypothesis derivations.
- Pixelated figures and conflated "Public Domain/Unlicensed" label
  remain after two cycles of being flagged.

** Questions

1. Why do the abstract, intro, and Section 5.2.1 still report the
   Original (pre-popularity) ORs (files 1.30, upstream 1.25,
   downstream 1.10) rather than the +Pop / V2604 numbers that
   Section 5.2.2 endorses? Which specification is the *primary*
   headline of the paper?

2. The Delay>=12 sub-cohort gives Files OR=1.76 (significant),
   contradicting +Pop (1.03 NS) and V2604 BLvAL (0.95 NS). What
   explains this, and which estimate should the reader trust?

3. Why are upstream/downstream counts unavailable in the V2604
   pre-window? Can a one-window forward-projected V-era estimate
   serve as a sensitivity check for BLvAL on those outcomes?

4. Provide a hypothesis-by-hypothesis verdict table: H1a, H1b, H2a,
   H2b, H2c, H3a, H3b, H3c, H3d, each with operationalization, OR
   and CI from the primary specification, and a clear
   supported/partial/unsupported label.

5. For the V2604 distinct-aliased-author count: what fraction of
   commits/authors were dropped by the bot/homonym blocklist in the
   pre- and post-windows respectively? Is filtering symmetric across
   the two windows of each project?

6. Were multiple-comparison corrections applied across the 7
   outcomes and several language interactions? Do the borderline
   ORs (0.83-0.96) survive Bonferroni or BH?

7. Resolve the "[?]" reference errors on p.5 in the H3a-H3d
   derivation paragraphs.

8. Section 7 (Future Work) is empty. Oversight or intended?

9. Reconcile the "top 50 licenses classified" claim (Section 4.1)
   with Appendix A, which lists fewer than 50 SPDX IDs.
