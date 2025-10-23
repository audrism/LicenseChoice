# Review A

**1\. How did you select control variables for the regression model?**

The control variables were derived from the theoretical constructs discussed in Section 2\. Specifically:

* Project age (EarliestCommit) and inactivity (LatestCommit) are motivated by Section 2.3, which discusses how maturity and stability relate to license decisions and project dynamics. As cited, older projects are more likely to exhibit sustained activity and reliability \[4\].  
* License adoption delay (AdoptDelay) controls for the timing of the first license relative to project creation. This accounts for differences in early-stage versus later licensing decisions, as discussed in Section 4.3.  
* Distance between license changes (Distance) captures how much time elapsed between the first and final license adoption. This is included because the regression compares project metrics across these two post-adoption intervals. As described in Section 4.3, it helps control for varying project trajectories over time.  
* License popularity at adoption (Proportion) operationalizes Hypothesis H2a (Section 2.2), which posits that license choice is influenced by what others in the ecosystem are adopting. This variable is explicitly included in our regression model to account for social contagion effects.  
* Programming language was included as a control because, as we argue in Section 2.2 (Social and Technical Choice), licensing norms and reuse practices are highly language-dependent. This cultural and technical coupling between language ecosystems and licensing practices is the basis for Hypothesis H2b, and thus language must be controlled for when assessing the effect of license change direction.  
* Additionally, we include an interaction term between language and license change to examine whether the impact of licensing shifts varies across language communities — a key aspect of our findings reported in Section 5.2.

These variables were not selected post hoc but directly reflect the theoretical model we constructed. Each is intended to isolate the effect of license change direction from confounding factors tied to a project’s lifecycle, ecosystem trends, or temporal context. We’d be happy to clarify deliberate and conceptually grounded of our selection in additional detail.

**2\. Can you provide goodness-of-fit metrics (e.g., R^2) and multicollinearity diagnostics (VIF scores) to validate model robustness?**

Due to space constraints, we omitted detailed model diagnostics in the submission but will include them in the revision.

We evaluated model fit by computing R² values for each outcome using equivalent univariate regressions. The R² values range from 0.02 to 0.09 across the eight dependent variables. While modest, these values are consistent with expectations in large-scale observational studies of socio-technical systems, where project behavior is influenced by many unobserved factors and variability is high. 

Inspection of the residuals did not reveal any unexpected patterns. 

To assess multicollinearity, we computed generalized variance inflation factors (GVIFs). All predictors had adjusted GVIF^(1/2Df) values below standard thresholds. The only exception was the binary change variable (license change direction), with a GVIF^(1/2Df) of 3.22, slightly above the common rule-of-thumb of 2.5 but well below conservative thresholds (e.g., 5). Given the inclusion of interaction terms and categorical variables, this does not indicate problematic collinearity.

These diagnostics confirm that the model is well-specified, and we will include them in the final version or supplementary material as appropriate.

**3\. Given the observational nature of the data, how do you justify interpreting regression results as causal effects (e.g., H1a's "results in") rather than associations?**

We appreciate this important point. Our study is based on observational data, and we fully agree that the regression results should be interpreted as associations, not as evidence of causality in a strict sense.

Where the hypotheses or discussion use phrasing such as "results in" (e.g., H1a), the language reflects theoretical expectations and readability rather than a claim of causal identification. We acknowledge this distinction more clearly in Section 2.3 and Section 4.3, and we will revise the phrasing in the final version to emphasize that our findings are associational.

That said, our design incorporates several features intended to improve internal validity:

* By focusing on within-project license changes (i.e., comparing metrics before and after a change), we help control for project-specific confounders that are stable over time.  
* Our regression model includes key temporal and structural covariates (e.g., project age, adoption delay, language, etc.) to further reduce bias from observable differences.

Our within-project design, comparing post-adoption intervals before and after license changes, follows quasi-experimental logic by controlling for stable project-level characteristics. This strengthens confidence that the observed associations reflect meaningful relationships rather than spurious correlations. We view our findings as an empirical foundation for future work using stronger identification strategies (e.g., instrumental variables or natural experiments) or mixed-method designs to more directly assess causality.

**4\. Given that RQ2's analysis excludes the unlicensed projects that constitute the paper's claimed the main novelty of paper, what specific new insights does it provide beyond prior studies of licensed projects?**

While it is true that RQ2 focuses only on projects that adopted at least one license (and later changed it), this restriction is necessary to examine the impact of license transitions. Unlicensed projects, by definition, do not undergo such transitions and thus fall outside the scope of RQ2's comparative framework.

The novelty of RQ2 lies not in including unlicensed projects directly, but in the insights it enables through the design and scale of our analysis of licensed projects:

* While prior studies (e.g., Vendome et al. 2017; Di Penta et al. 2010\) have analyzed license change patterns and developer rationales, our study is the first to use a within-project, quasi-experimental design to assess the effects of license changes on downstream project dynamics. By comparing time intervals before and after license changes within the same project, we control for stable project-level characteristics, enabling stronger inferences than studies that treat license as a static project attribute.  
* Compared to prior license studies, such as Wu et al. \[44\], which examined 3.47 million projects across only five package managers, and Cui et al. \[7\], which analyzed just 16,341 high-star GitHub repositories, our dataset spans over 131 million projects across all ecosystems, including under-studied languages and low-activity projects.  
* We explicitly analyze how license effects vary by language ecosystem, revealing heterogeneous impacts not previously quantified (e.g., permissive licenses correlate with increased activity in Python but reduced activity in C/C++).

We explicitly analyze how license effects vary by language ecosystem, revealing heterogeneous impacts not previously quantified (e.g., permissive licenses correlate with increased activity in Python but reduced activity in C/C++). These findings are not only novel but also form the basis for the practical implications we outline in our response to Review B, Question 5; namely, that license changes are not universally beneficial or harmful, but interact with language-specific community norms. This points toward the need for context-aware licensing strategies. Thus, while RQ2 does not include unlicensed projects directly, it provides new empirical insights into how and when license choice matters, insights that are essential for understanding licensing dynamics across the full OSS landscape identified in RQ1.

# Review B

**1\. How were the licenses categorized into types and how was this verified? If the authors wish, they can address specific examples I give (BSD-3-Clause-Attribution, deprecated\_GPL-2.0, WTFPL) after the rebuttal word limit, and I will read it.**

We categorized licenses into standard types, following conventions in the OSS licensing literature \[21–23\] and SPDX guidelines. A sixth fallback category, "other", was used for licenses that were not manually reviewed.

Due to the very large number of distinct license labels (597 total), and to maintain a practical and reproducible categorization process, we manually classified only the top 50 most-used licenses, which together account for 98.92% of all licensed projects in our dataset. The remaining \~1% of long-tail licenses were conservatively grouped as “other” to avoid misclassification and to focus analysis on the licenses most relevant at scale. 

We acknowledge that this approach may result in some specific licenses, including legitimate variants like BSD-3-Clause-Attribution or deprecated\_GPL-2.0, being assigned to "other" even if their characteristics align with a known category. This was a deliberate trade-off to prioritize reproducibility, minimize noise from rare licenses, and prevent over-interpreting cases we could not verify.

Regarding the specific examples:

* BSD-3-Clause-Attribution and deprecated\_GPL-2.0 both fall outside the top 50 and were therefore assigned to “other” by default.  
* We classified WTFPL as permissive based on its OSI-approved status and widespread treatment in SPDX and package ecosystems. However, we acknowledge that its intent is closer to a public-domain dedication, and that some sources describe it as “public-domain-like.” We will clarify this ambiguity in the final version and are open to reclassifying it to better reflect its legal interpretation.

We will clarify this thresholding strategy in the final version to better reflect the balance we struck between scalability and precision, and we appreciate the reviewer’s detailed examples.

**2\. Why did you not compare the year before the final license switch and the year after, instead comparing “years after” separated by a long time, in which other parameters may have influenced the comparison?**

We chose to compare the one-year period following the first license and the one-year period following the final license (rather than the year before vs. after the final switch) for the following reasons:

1. Avoiding anticipatory effects and transitional noise: The period immediately preceding a license change may include preparation or reduced activity due to uncertainty about legal status, especially for projects undergoing a shift in governance or ownership. We aimed to avoid such volatility by comparing fully post-adoption intervals.  
2. Capturing stable, intentional project states: By comparing intervals after license adoptions, we ensure each measurement reflects the project’s behavior under a fully adopted license, rather than in a state of flux. This was crucial to our goal of studying license effects rather than the dynamics surrounding the decision itself.  
3. Internal consistency across projects: Using the “year before and after” approach would create asymmetry between projects with early vs. late license changes, and would bias comparisons depending on how mature a project was at the time of the switch. Our method ensures all comparisons are anchored around fully adopted license states, regardless of timing.

We acknowledge this design choice introduces the possibility that unrelated factors (e.g., project aging) influence the comparison. To mitigate this, we include covariates like project age, latest activity, and elapsed time between licenses to control for such effects (Section 4.3, Table 3). We will clarify these trade-offs in the final version.

**3\. How prevalent is the case when the initial license selection happens at the early stages of the project, and can the results of comparison then be due to factors other than the change of license?**

The concern about confounding from project evolution is valid, and we address it empirically in the paper.

As shown in Table 3, the median delay between project creation and initial license adoption (AdoptDelay) is 0.13 months, and the 5th percentile is 0\. This indicates that in the majority of cases, the first license is adopted very early in the project’s life cycle, typically within days of the first commit. 

Nonetheless, we recognize that differences between early-stage and later-stage project dynamics could influence results. To account for this, we include AdoptDelay, Project Age (EarliestCommit), and Time Since Last Commit (LatestCommit) as control variables in our regression model (Section 4.3). These help isolate the effect of license change from general project maturation or decline.

While unmeasured factors may still play a role, the prevalence of early license adoption and inclusion of temporal controls reduce the risk that our comparisons are driven solely by unrelated lifecycle effects.

**4\. How often does there exist the case when the initial license A is separated by at least a year from the final license C, but in that first studied year after A it is switched to some other license B?** 

We thank the reviewer for raising this important edge case. After reviewing the data, we found that this situation applies to 1,462 out of 23,619 projects used in the regression analysis, approximately 6.2% of the sample. While this is a relatively small portion, we wanted to ensure that these cases did not influence our results.

To that end, we excluded these projects and reran the full regression model on the remaining 22,157 projects. The results remained consistent: all key findings held, with similar effect direction and significance levels. Notably, the core language-specific patterns we report (e.g., positive effects for permissive licenses in Python, negative effects in C/C++) were unchanged.

We will update the revised version of the paper to reflect this robustness check and include the new results.

**5\. What practical implications are there from the regression analysis?**

The regression analysis offers several practical takeaways for OSS maintainers considering license changes.

1. License effects depend on the language ecosystem: Our results show that the impact of switching between permissive and restrictive licenses varies significantly by programming language. For example:  
   * Python projects tend to benefit from permissive licensing in terms of growth and reuse.  
   * C/C++ projects experience declines in contribution and activity under permissive licenses, suggesting community expectations or governance norms favor restrictive licensing.

   This underscores the importance of choosing a license aligned with the norms and practices of the project’s language ecosystem.

2. Anticipating change-related trade-offs: The analysis helps maintainers anticipate how licensing shifts may affect project metrics, such as contributions, reuse, or stability, and plan accordingly. For example, projects moving toward permissive licenses in restrictive-leaning ecosystems may need to pair that change with stronger community engagement.  
3. Foundation for practical tools: The results offer a data-driven basis for future license recommendation tools that take into account project context (language, size, lifecycle), rather than offering generic templates.

In summary, the regression provides actionable guidance for maintainers to make more informed and context-aware licensing decisions.

# Review C

**I have no questions that would change my assessment. I invite the authors to point out mistakes in my review, if they want to respond.**

**1\. Only scale and recency seem to be the novel aspects.**

Please see the response to Review A, Question 4\.

**2\. The statement that unlicensed code is waiving all rights it not correct.**

The paper does not contain such statements. In fact, the introduction states: “why some license violations (such as the use of unlicensed code) appear to be tolerated.”

In Section 4.1, our category labeled “Public Domain/Unlicensed” refers specifically to cases where a license explicitly declares that the code is unlicensed or released into the public domain. For example, via the Unlicense or Creative Commons Zero (CC0). These are formal licenses that attempt to waive copyright and permit unrestricted use.

This is distinct from code that lacks any license declaration, which we consistently treat elsewhere in the paper (e.g., Sections 1 and 5.1.3) as a major source of legal ambiguity and risk.

We acknowledge that the phrasing in Section 4.1 could be misread as conflating these two cases. We will revise that paragraph to clarify the distinction between:

1. Code with an explicit public domain/unlicensed license, and  
2. Code with no license at all.

We appreciate the reviewer’s attention to this important nuance.

**3\.  The paper stops at a very descriptive level and the "implications" are pure speculations.**

We appreciate the reviewer’s concern about the depth and interpretation of our implications. Our intent was not to offer prescriptive rules (e.g., “metric improves, then do it”), but rather to present empirically grounded patterns that varied meaningfully across language ecosystems. We agree that the paper could more clearly signal that these are context-aware associations, not normative recommendations.

Regarding the cross-language variation: we deliberately avoided strong causal explanations because the observed differences likely stem from complex, community-specific factors, such as tooling, cultural norms, dominant contributors, or historical licensing practices, which we acknowledge cannot be inferred solely from quantitative data. Rather than speculate, we focused on documenting where these differences arise and how they might inform more nuanced license decision-making.

We agree that a deeper reflection on why these differences exist would strengthen the paper. In future work, we hope to explore these dynamics using qualitative methods or targeted studies within specific ecosystems.

We will revise the implications section to clarify that our goal is to highlight ecosystem-specific licensing behavior and its associations with project dynamics, not to offer simplistic prescriptions.

**4\. I do not think that the hypotheses get a proper answer.**

Thank you for this important observation. The hypotheses were included to translate our theory-driven framework into empirically testable claims, guiding the selection of variables and the structure of the analysis. Our aim was not to validate each hypothesis in isolation with a single direct test, but rather to explore them through a consistent regression design that could reveal patterns aligned with (or contradicting) those expectations.

That said, we acknowledge that the connection between specific hypotheses and statistical tests could be made more explicit in some cases, especially for hypotheses like H2a or H3d. We will revise the text to clarify which results inform each hypothesis, and where the evidence is partial, indirect, or inconclusive.

We appreciate the reviewer’s feedback and will use it to strengthen the alignment between theory and empirical analysis in the final version.

**5\. How is the design of the experiment different from simple "p-hacking"?**

Please see response 1 to review A.

**6\. Despite claiming the creation of a theory on licensing use, which should create large potential for reuse in future work, the paper does not motivate any feature studies that build on top of the presented findings.**

It is unfortunate that this point is not sufficiently transparent in the current presentation. This theory does make a number of testable predictions that are grounded in prior research on OSS contributor motivation, project dynamics, and social-technical decision-making. To our knowledge, there are no prior theories that are systematically developed within the specific domain of OSS license choice. The theory introduced here draws together disparate findings to propose a cohesive explanatory framework for license-related decisions.

Several of the theory’s predictions are empirically tested in this study (e.g., effects of license restrictiveness on contributors, language-specific adoption patterns, reuse behaviors). However, many other testable predictions remain, and the theory is designed to support future work, including studies of licensing behavior in specific ecosystems, qualitative validation of decision rationales, and extensions to commercial or hybrid projects.

We will revise the manuscript to more clearly articulate the role of the theory as a foundation for future empirical studies, and to better highlight directions in which it can be expanded or applied.