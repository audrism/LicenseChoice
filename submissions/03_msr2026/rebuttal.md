# **Rebuttal for Paper \#344**

We would like to sincerely thank the reviewers for their constructive feedback. Below, we address the concerns raised by the reviewers.

# **Reviewer A**

**Q1: Why only two license groups were used for license-change analysis?**  
The paper classifies licenses into five descriptive categories (permissive, copyleft, weak-copyleft, conditional-open, public-domain/unlicensed) for informational and contextual understanding. However, these categories are *not legally cleanly separable*, nor mutually exclusive in all real-world licensing contexts. Many licenses have variants with subtle differences, and modeling them as five strict, disjoint classes would introduce artificial distinctions that do not correspond to actual behavioral differences in adoption or switching behavior.  
For the purpose of analyzing *license changes*, we model only the **direction** of change, toward more restrictive or more permissive licensing, because:

1. it aligns directly with the underlying theory, which concerns restrictiveness rather than fine-grained legal distinctions;  
2. it avoids imposing legally artificial category boundaries;  
3. license-change events are rare, and subdividing them into five groups would reduce statistical power and produce unreliable estimates;  
4. using a binary direction-of-change model provides the most empirically robust and interpretable analysis while remaining faithful to the data.

**Q2: Were educational/testing/toy projects included, and could they bias results?**  
Yes. The study intentionally includes all projects indexed in WoC to avoid the sampling biases of prior work, because licensing is primarily concerned with provenance and provenance is profoundly affected by any copying from any public repository independent of the number of stars or forks. Hence much of existing work on licence prevalence is misguided by excluding a significant portion of potential sources of copied code, since prior work (e.g., Jahanshahi et al.) demonstrated that small (zero activity/star/fork) projects account for \~18% of reused artifacts in highly active and popular software projects. The paper’s explicit motivation is to characterize the *actual* ecosystem, including small projects that meaningfully contribute reused code. Once we establish this provenance baseline, our analysis concerns licence changes, hence the activity (“engineered projects”) is assured (see the next point on bias).   
Regarding bias: inspection of model-variable distributions (project age, number of commits, burstiness, upstream/downstream links, etc.) shows no concentration of extremely small or trivial projects sufficient to distort regression estimates. The multivariate model also includes numerous controls (age, adopt delay, activity histories, language, etc.), making it unlikely for “toy” projects to meaningfully influence effect sizes even if they play an outsize role in terms of provenance. 

**Other Clarifications**

1. **Theory development methodology.**  
   The paper does not claim to produce a finalized theory. It explicitly presents a *preliminary*, operationalizable theory, constructed from prior research streams, designed to generate testable hypotheses at ecosystem scale. The methodology aligns with established practice for early-stage theory building when large-scale observables are required.  
2. **Hypotheses *are* linked with results.**  
   Each results subsection refers back to specific hypotheses (e.g., H1b retention, H2a popularity decline, H3b complexity, H3a activity). We will make these linkages more explicit in the camera-ready version.  
3. **Novelty beyond dataset reuse.**  
   While WoC–derived license maps are used, the contribution lies in (a) comprehensive ecosystem-wide license identification; (b) quantifying prevalence with minimal filtering; and (c) performing the first large-scale study of *license switching* and its impact.  
4. **Unclear title.**  
   The title reflects the two main contributions: prevalence and impact. The theory development motivates the impact analysis, but the main operational results correspond directly to the title.

**Reviewer B**

**Q1: Why compare the year after the first license vs. the year after the final license, instead of year-before vs. year-after the switch?**  
The choice to compare the year after the first license with the year after the final license was a deliberate design decision intended to measure project behavior under two stable license regimes, rather than treating the transition moment as a causal baseline. Because license changes are deliberate decisions that typically reflect a project’s strategic intent rather than incidental noise, a before-after comparison around the switch would not provide a clean or meaningful estimate of the license’s effect. The comparison windows were chosen to ensure:

1. **Symmetric, noise-reduced one-year intervals** beginning immediately after each adoption point, avoiding transitional instability immediately preceding a change.  
2. **Avoidance of pre-switch distortions:** the “year before the switch” is not comparable across projects: many projects experience long inactivity before relicensing, while others undergo bursts leading up to a switch. This would skew comparisons dramatically.  
3. **Control through model variables:** adoption delay, project age (EarliestCommit), inactivity (LatestCommit), and time between first and last adoptions address temporal asymmetries directly.  
   This design yields the most comparable, unbiased windows across millions of projects with highly heterogeneous life cycles.  
4. **Scarcity**: because license changes themselves are rare events, using symmetric post-adoption intervals maximizes comparability while preserving sufficient sample size for stable multivariate estimation.

**Q2: Practical implications of regression analysis.**  
The regression results show that license effects are **ecosystem-dependent** rather than universal. Consequently:

* maintainers should not assume that shifting to a permissive license uniformly increases participation;  
* C/C++ projects show reduced activity after shifts to permissive licenses, while Python shows the opposite;  
* relicensing decisions should incorporate language-ecosystem expectations rather than relying on generic intuition;  
* organizations evaluating relicensing can use these directional estimates as risk indicators for expected activity changes.

**Other Clarifications**

1. **Hypotheses and causality.**  
   The hypotheses concern *associations* predicted by the preliminary theory. The regression analysis is explicitly presented as associative, not causal; the paper does not claim causal identification. We will clarify phrasing to avoid any implication of causal inference.  
2. **Extent of license-change dataset.**  
   We appreciate the reviewer’s calculation that \~2.4% of licensed projects fall into the analyzable category. While the paper does not state this number explicitly, it is consistent with the filtering described in Section 5.2. We can make this clearer in the final version.  
3. **Public domain vs. unlicensed.**  
   The classification section describes categories for analytical grouping, not legal equivalence. The text will be clarified to avoid confusion between “unlicensed” and “public domain”, which the paper elsewhere clearly distinguishes.  
4. **Comparison to prior works.**  
   The paper includes a dedicated comparison section and Table 1/2 but we accept the suggestion to expand discussion of additional historical studies.  
5. C**larification regarding previously promised additions**  
   The reviewer is correct that our ICSE response stated that additional discussion about the challenges of comparing pre-switch intervals would be incorporated into the manuscript. The submitted MSR version did not include this clarification as explicitly as intended. We will revise the manuscript to clearly articulate (a) why the pre-switch interval is not an appropriate baseline due to heterogeneous inactivity and burst patterns, and (b) how the adopted controls (EarliestCommit, LatestCommit, AdoptDelay, Distance) mitigate the associated risks of temporal asymmetry. This addition will ensure the rationale is fully transparent in the final version.

**Reviewer C**

**Q1: What groups or characteristics do unlicensed projects belong to?**  
The paper’s data shows that unlicensed projects are predominantly small or less mature. However, they *still* contribute meaningfully to reuse patterns: prior work (Jahanshahi et al.) shows that small/low-activity projects account for \~18% of copy-based reuse. Thus, unlicensed repositories are not merely trivial noise but structurally relevant to the ecosystem. Their high prevalence reflects the *baseline* behavior of developers outside curated, maturity-filtered ecosystems such as package managers.

**Q2: How were confounding factors controlled in the license-change analysis?**  
The model includes controls for each major observable factor known to influence activity metrics:

* **project age** (EarliestCommit),  
* **inactivity interval** (LatestCommit),  
* **adoption delay** (time between project creation and first license adoption),  
* **time distance** between initial and final license adoption,  
* **language ecosystem**,  
* **prevalence of the license type** at adoption time.  
  These controls explicitly address temporal drift, maturity effects, dormant-period distortions, and ecosystem-specific development patterns.

**Other Clarifications**

1. **Inclusion criteria.**  
   The paper’s intent is to characterize the *actual* license landscape, not a curated subset. The analysis deliberately avoids filters that historically underrepresented unlicensed projects that play an outsize role in open source provenance even if most of them are not active open source projects. The provenance analysis demands a complete landscape as public code can be copied from anywhere, while licence change analysis concerns active projects. We will clarify the distinction between the two analyses in the paper to avoid confusion.  
2. **Interpretation of 131M vs. 20M projects.**  
   Table 1 reports the size of the full WoC universe (131M), while later sections analyze the subset with detectable licenses (20M). We will revise the table caption to clarify this distinction. It is the later set that mostly represents active projects while the earlier represents the full provenance picture.   
3. **Toy project bias.**  
   As noted above, distributions of model variables show no pathological concentration of trivial repositories, and extensive controls reduce the risk of distortion because the projects with licenses tend to be active.  
4. **Actionability.**  
   The paper provides actionable insights for practitioners specifically in Section 5.1.3 and the language-specific findings in Section 5.2.
   