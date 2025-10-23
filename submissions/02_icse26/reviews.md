ICSE 2026, Research Track Paper #819 Reviews and Comments
===========================================================================
Paper #819 The Prevalence and Impact of Licenses in Open Software Projects


Review #819A
===========================================================================

Overall merit
-------------
2. Weak reject

Paper summary
-------------
This paper explores the prevalence and impact of licensing in open-source software (OSS) projects. The aim of the study is to examine the current state of license selection in OSS projects and to develop and test a preliminary theory explaining how license choices influence OSS projects. To achieve this, the authors compiled a substantial dataset comprising 131 million OSS projects, conducted a comprehensive statistical analysis, and built a regression model. The findings provide valuable insights into the significance of licensing, drawing attention to projects without licenses and deepening our understanding of how license choices affect OSS projects across different programming language ecosystems.

Strengths
---------
+ important issues that SE filed concerned
+ large-scale data
+ interesting perspective

Weaknesses
----------
- insufficient comparison with related studies
- model construction issues
- missing the detail of data collection
- presentation issue

Detailed comments for authors
-----------------------------
# Significance  
This paper explores the prevalence and impact of licensing in OSS projects at an unprecedented scale, offering valuable insights into how license changes affect projects across different language ecosystems. The study's focus on license transitions and their varying impacts depending on the programming language is a novel and interesting perspective. However, the significance of the findings is somewhat undermined by unresolved issues raised in the introduction, such as the question of why some license violations (e.g., the use of unlicensed code) appear to be tolerated. Addressing these questions could have strengthened the paper's contribution. Additionally, concerns about model fitting and validation (discussed in the "Rigor" section) threaten the validity of the findings, which limits the potential impact of the study.


# Rigor  
The soundness of the findings is compromised by several methodological issues:  

The paper includes various control factors but fails to justify their inclusion or explain how they were selected. This omission raises questions about the model's validity. For instance, factors like the number of stars (a proxy for project popularity) could significantly influence the responses such as number of upstream projects, but are not considered.  

The hypotheses (e.g., H1a: "More restrictive licenses result in higher total numbers of authors") are framed as causal relationships, but the regression analysis can only establish associations. The authors should clarify the limitations of their methodology in inferring causality or consider alternative approaches (e.g., quasi-experimental designs) to strengthen their claims.  

The relationship between the hypotheses and the regression model is unclear. Many hypotheses (e.g., H2a and H2b) suggest that "The license choice is affected by...". However, in the regression model, the factors hypothesized to influence license choice are instead treated as dependent variables, implying that "... is affected by license choice." This reversal of causality between the hypotheses and the regression model may lead to confusion for the reader.

The analysis lacks critical steps such as evaluating correlation and redundancy among independent variables (including control factors). While the authors mention that multivariate multiple regression is suitable for correlated dependent variables, they do not demonstrate that this assumption holds or address potential multicollinearity among predictors.  

There is no discussion of the model's overall performance, such as goodness-of-fit metrics (e.g., R^2 or adjusted R^2). Without these, it is difficult to assess whether the model adequately explains the observed data.  

For H2a ("The license choice is affected by overall popularity of the license at adoption time), the authors claim that copyleft licenses are "sticky" but note a decreasing adoption trend over time. However, it is unclear how this observation directly validates H2a, as the hypothesis pertains to license popularity at adoption time, not retention rates or trends. The analysis should explicitly test whether projects are more likely to adopt licenses that are popular at the time of adoption.  


# Novelty  
The paper emphasizes its novelty primarily in terms of data scale (e.g., Section 3, "Comparison to Prior Work"). While the large-scale dataset is a strength, there are concerns about data quality:  

The dataset includes many small and inactive projects, which are less likely to have licenses. While the authors justify this by citing Jahanshahi et al. [20] (showing that 18% of reused artifacts originate from small projects), the relevance of these projects to licensing risks is questionable. Unlicensed projects do not pose licensing risks in the same way as licensed projects with incompatible terms. A clearer rationale for including these projects would strengthen the paper.  

The comparison with prior work in Section 3 primarily highlights differences in RQ1 (prevalence of licenses). For RQ2 (impact of license changes), the novelty is less clear, as the analysis is limited to the small subset of projects with licenses. The authors should better articulate how their approach advances understanding beyond existing studies, particularly in terms of methodology or theoretical framing.  

# Presentation  
The paper's presentation could be improved in several ways:  

*Introduction*: The final paragraph summarizes findings for RQ1 but omits key results for RQ2. A balanced summary of both research questions would provide a more complete overview.  

*Dataset Description*: The relationship between Jahanshahi et al. [19] and the World of Code (WoC) infrastructure is unclear. The paper mentions that Jahanshahi et al. [19] compiled the dataset but does not explain how their work builds on or differs from WoC. A more detailed description of Jahanshahi et al. [19]'s methodology (e.g., license detection using filepaths and the winnowing algorithm) would help readers evaluate data quality.  

*Related Work*: The paper lacks a dedicated related work section. While Section 2 and Table 1 compare data scales, they do not situate the study within the broader literature on OSS licensing. For example, the introduction claims there are no prior studies modeling the impact of license choice, but Table 1 lists studies like Wu et al. [44] and Cui et al. [7], which presumably address similar questions. A synthesis of what prior work has examined (e.g., license compatibility, adoption drivers) and how this study advances the field would clarify its contribution.  

*Key Findings*: The "Key Findings" section does not explicitly mention results for H3a–d (e.g., the impact of licenses on project activity, complexity, sustainability, or burstiness). Adding these would provide a more comprehensive summary of the hypotheses tested.

Questions for authors’ response
-------------------------------
1. How did you select control variables for the regression model?

2. Can you provide goodness-of-fit metrics (e.g., R^2) and multicollinearity diagnostics (VIF scores) to validate model robustness?

3. Given the observational nature of the data, how do you justify interpreting regression results as causal effects (e.g., H1a's "results in") rather than associations?

4. Given that RQ2's analysis excludes the unlicensed projects that constitute the paper's claimed the main novelty of paper, what specific new insights does it provide beyond prior studies of licensed projects?

Artifact assessment
-------------------
3. Satisfactory, i.e., the artifacts are in line with what is declared in
   the submission form or the paper [OR] the authors explained why the
   artifacts are not provided and I find the explanation to be reasonable.

Comments on artifact assessment
-------------------------------
The artifacts are in line with what is declared in the submission form or the paper.



Review #819B
===========================================================================

Overall merit
-------------
3. Weak accept

Paper summary
-------------
In this paper, the authors explore the state of licensing in open-source software, as well as the impact of license changes on various software project metrics. Unlike the previous works, the authors employ a large dataset based on the World of Code, consisting of more than 130 million projects. The authors group all licenses in projects into different types (unlicensed, permissive, copyleft, weak copyleft, conditionally open, and public domain) and study how the types are distributed, discovering much more unlicensed code than previously reported. Then, the authors focus on license shifts and run a multivariate multiple regression model to see how different project metrics change with the change of the license from permissive to restrictive or vice versa. Among the specific findings, it can be seen that almost all metrics are very dependent on the language ecosystem.

Strengths
---------
+ Important topic.
+ Novel approach, combining theory and analysis.
+ Some novel and important results.
+ Good replication package.

Weaknesses
----------
- Not clear how licenses were categorized.
- Methodological motivations missing.
- Not clear how to interpret or use the results of the regression analysis.

Detailed comments for authors
-----------------------------
Overall, I found the paper to be interesting and insightful. Among many papers about OSS licenses, this work definitely offers something new and tries a unique approach, pulling from different sources for theory and trying to build a unified model. The usage of a very large dataset and the focus on unlicensed code is undoubtedly a welcome addition. At the same time, the paper has some unclear details in methodology, which I elaborate on below (mostly in the **Rigor** section).

**Novelty**

The parer explores a known topic, but it clearly articulates its differences from previous work. Also, with my experience of working with a lot of 0-star unlicensed projects on GitHub, I find it welcome that these peculiarities in the paper are highlighted.

One downside I found in the paper in this regard is a very small comparison to previous exploratory works. While the second, regression, part of the work is more specific, I am not sure why the first part is only compared to Cui et al. and Wu et al., since there are many works that study the prevalence of different licenses in software. The authors should consider at least tangentially comparing their results with the classic works of Christopher Vendome and Daniel German or any of the recent large-scale empirical studies on the topic.

**Rigor**

It is in the methodology of the study that I find the largest concerns. Overall, the work is very broad – covering a large dataset, a lot of metrics and conjectures, and not going into details on specific projects, so the work inherently has many limitations and a certain compounding error, which it addresses. Some conjectures seem very reasonable, while some are less so, for example, H3d about burstiness. However, my two main concerns are the grouping of licenses and the comparison points.

_Grouping of licenses_. In Section 4.1, the authors write: _“We group licenses based on their characteristics”_, however, it is not clear how exactly this was done. The replication package indicates 597 licenses, and I assume that the authors categorized them manually. I have some questions about that.

For some major licenses, the category is traditional and clear. However, the line between “permissive” and “conditionally open” seems very thin to me, and it is important, because “conditionally open” licenses are later considered “restrictive”. The authors say that permissive licenses _“are known for their minimal restrictions on how the software can be used”_. Then it is not clear to me why BSD-3-Clause is permissive (it clearly is), but BSD-3-Clause-Attribution is “other”. It adds a condition of attribution (adding one line), that’s true, but the initial BSD-3-Clause license also contained _some_ conditions, just simple ones. Similarly, it is not clear why:
* old Apache and BSD family licenses are not permissive;
* both GPL-3.0+ and deprecated_GPL-3.0+ are copyleft, but while GPL-2.0 is copyleft, deprecated_GPL-2.0 is “other”;
* WTFPL is “permissive” when it seems to be “public-domain-like”, etc.

While this might not be very crucial for analysis, since usually the 10 main licenses cover 95%  of all projects, it is still not clear to me how the categorization was validated.

_Comparison points_. My main concern with how the authors decided to compare the metrics is the choice to go with the year after the initial license choice instead of comparing, for example, the year before the final license switch and the year after, which seems more straightforward. On line 443 the authors themselves write that _“initial license selections … may be arbitrary or uninformed”_, and yet they consider a year after them in comparison. I understand that the comparison revolves around the final license switch, but then it’s not clear to me why not choose the time before that as a closer target for comparison. 

It seems probable that initial licenses are also selected at the very start of the project in a significant number of cases. Because of this, the authors end up comparing early stages of such projects with much later ones, which means that the changes can be due to other factors. The authors do control for “Adopt delay”, but it is not clear from the paper how often it is the case that the first license exists in the early stages of the project, where the dynamics are very different. The authors should definitely comment on this in the paper.

The authors also write: _“This also means that if a project starts with license A, then changes to B, and later changes to license C, we consider it as one change from A to C, rather than two separate changes.”_. Considering the authors’ methodology of using 1-year spans, this is not a problem, but they later write: _“Projects are excluded if less than one year separates the adoption dates of the first and last licenses”_. Reading this, it seems like the projects are not filtered out if in that one year from the initial license A it might have changed into some other license B, if A is still separated from the final license switch C by at least a year. If this is the case, this seems like a threat to validity, it is not clear how prevalent this case is and why such repos can’t simply be filtered out.

Finally, minor, in section 5.2, the authors write: _“The middle group, consisting of projects that had more than one license type in their lifetime but have only one type ultimately, is the group we analyze license changes in.”_ This results in only 2.4% of licensed projects studied for the final part, (which are themselves a minority from the initial 100+ million). I believe this has to be indicated in the abstract and the introduction.

**Relevance**

The paper is relevant to the field, and some of its findings are very valuable to the community.
Highlighting unlicensed projects is crucial, and I also found Section 5.1.3 to be very insightful. In general, I find the results of the first part of the paper to be a great contribution.

At the same time, I am not sure about the usefulness of the regression analysis. The results do indeed differ between the languages, but despite the authors’ efforts, I was not able to see a clear reason for that in the paper, rather the paper just draws attention to how different the languages are. Given my concerns about the validity of the comparison of the year-long intervals that I expressed above, I am not sure what practical implications can be drawn from these results. Even though this is probably outside the scope of this paper, it lacks some kind of case study or a qualitative addition, because with all the threats to the validity of the general large-scale comparisons and such a complicated regression model, the results feel distant from a practical reality.

**Verifiability and Transparency**

I would like to thank the authors for a great replication package. I was able to dive deeper into the results by studying it.

**Presentation**

Overall, the paper is structured and written well, it is mostly easy to understand. One exception is the abstract, which is very hard to get through. It is written in rather complicated grammar and lacks commas. This is not a problem for the paper itself, though.

One thing that bothered me about the structure of the work is that the hypotheses are very structurally and clearly introduced, but are not resolved the same way. Most of them are only mentioned once in the middle of results, not in Key findings. They are also somewhat hard to track because they are introduced and concluded following different logic. They are introduced divided by some motivational logic, but checked divided by prevalence and performance metrics.

I was also a bit confused in Section 4.1 point 5, where the authors write _“Public Domain/Unlicensed: Public domain and unlicensed software, including those using the Creative Commons Zero (CC0) license, are not restricted by copyright law.”_ The authors clearly understand that unlicensed code is not the same as public domain, they write several times that using unlicensed code is a violation and that it is not technically even open-source. So in a way it is the opposite of the public domain. Did the authors mean “licensed under the _Unlicense_ public domain license”? Anyway, this is never an issue in the paper, but this part is written strangely.

Finally, Figure 4 is a bit confusing to read, it would be easier if the numbers were marked with what exactly they are showing.

Questions for authors’ response
-------------------------------
1. How were the licenses categorized into types and how was this verified? If the authors wish, they can address specific examples I give (BSD-3-Clause-Attribution, deprecated_GPL-2.0, WTFPL) after the rebuttal word limit, and I will read it.
2. Why did you not compare the year before the final license switch and the year after, instead comparing “years after” separated by a long time, in which other parameters may have influenced the comparison?
3. How prevalent is the case when the initial license selection happens at the early stages of the project, and can the results of comparison then be due to factors other than the change of license?
4. How often does there exist the case when the initial license A is separated by at least a year from the final license C, but in that first studied year after A it is switched to some other license B? 
5. What practical implications are there from the regression analysis?



Review #819C
===========================================================================
* Updated: Jun 5, 2025

Overall merit
-------------
2. Weak reject

Paper summary
-------------
Modern software development strongly depends on software reuse in terms of libraries. Teh terms of the reuse are defined through licensed, which need to be respected by downstream reusers. Software licensing has been (extensively) studied before, but existing research suffers from an insufficient license identification and a lack of scale and recency. The paper heads out to change this and to understand the state of software licensing. To this end, the paper contains a literature survey of existing work to develop an initial theory. Then it collects a massive dataset of 100M project through the World of Code infrastructure, and it tests several hypotheses in this context. Many results are presented, the key insights seem to be that the fraction of projects that does not declare a license is much larger than estimated so far. The paper reports on the effects of changing between permissive and restrictive licenses and concludes that the results depend on the studied ecosystem.

Strengths
---------
- Novelty: Novel research, but ...
- Verifiability & Transparency: Clearly positioned to related work, detailed methodology
- Presentation: Well written paper

Weaknesses
----------
- Novelty: ... small delta to existing work?
- Rigor: study remained at border of statistics, additional qualitative measures could have helped interpreting the results
- Relevance: narrow results and no future work

Detailed comments for authors
-----------------------------
### Comments on Novelty

- The introduction positions the paper in an interest research context and motivates the problem well. However, as prior work has already studied licensing use, only scale and recency seem to be the novel aspects. Adding a list of contributions to the introduction would have made it easier to understand the novelty, as is, the delta to related work remains somewhat unclear to me. 


### Comments on Rigor

- I believe the statement that unlicensed code is waiving all rights it not correct. To the best of my knowledge, authors always retain the rights. Unlicensed code cannot legally be copied or reused (as the terms of reuse are not defined and, ergo, no permission for reuse has been given, see https://choosealicense.com/no-permission/. (addressed in rebuttal)

- The overall research design (review, dataset, analysis) makes sense to me. I am not an expert in statistical models, but from my basic understanding, the argumentation to defend the choice of regression model makes sense and is suitable for producing the results that the paper is searching for.

- Unfortunately, the paper stops at a very descriptive level and the "implications" are pure speculations. While I can appreciate them as a type of discussion, I feel like the formulated conclusions are very narrow... the recommendations are essentially "metric gets worse, then don't do it" and "metric gets better, then do it". Without reflection on where the differences between the different PLs come from, I have a hard time accepting so fundamentally different recommendations.

### Comments on Relevance

- The research design initially creates several hypotheses. While the general design of the following empirical study is certainly related, I do not think that the hypotheses get a proper answer. Why were the hypotheses then defined in the first place?

- The paper aims for a "comprehensive study" to overcome shortcoming of previous work. The cost of such a study is that also many toy projects are subject, which no-one would want to reuse anyway. What I am missing in the discussion is a motivation why a filter, as applied in previous work, is such a bad idea... one could ask whether the previously filtered projects even contain interesting insights whether adding them just increases the noise in the data?

- As the devils advocate, I will ask the nasty question.. how is the design of the experiment different to simple "p-hacking"? The experimental setup is valid, but the paper essentially throws many different values into the model and reports everything that sticks. I cannot argue against the correctness of the findings, but I also cannot help but wonder about the relevance of the findings, when the only finding is that many things are very different for different PLs/communities and no attempt is done to explain these observations further. (partially addressed in rebuttal)

- How would findings for a "super study" look like that essentially just merges the sub results per PL?

- Despite claiming the creation of a theory on licensing use, which should create large potential for reuse in future work, the paper does not motivate any future studies that build on top of the presented findings.


### Comments on Verifiability and Transparency

- Regarding the section on theory development, I am wondering, how the related work has been identified and how exhaustive the selection is or whether the presented works are even representative for current research on licensing.

- The review of related work presents clearly defines the shortcoming that are addressed by this work and their relation to it. I really like how the review of related work turns into actual hypotheses that get researched later.

- The configuration of the regression model has been described in details. Future researchers should be able to replicate a similar model from the descriptions.

- The paper references a replication package, which seems to contain all data and scripts relevant for the replication of the presented statistics. The replication package has a minimal readme, which should be sufficient together started.

### Comments on Presentation

- The paper is well written and the story was easy to follow.

- As a very nitpicky observation, it does not make sense to connect the retention rate in Figure 1 to a graph, as the individual categories have no natural order. The green data points should be visualized as separate dots, not as a connected line.

- Many of the figures are pixelated. This combination with tiny font-sizes makes the content very difficult to read. It would be advisable to use scalable image formats, like PDF, which are supported by every serious plotting tool.

- The fonts in ALL(!) figures are illegible, because they are tiny.

Questions for authors’ response
-------------------------------
I have no questions that would change my assessment. I invite the authors to point out mistakes in my review, if they want to respond.



Cycle-1-Rebuttal Response by Author [Mahmoud Jahanshahi <mjahansh@vols.utk.edu>] (3013 words)
---------------------------------------------------------------------------
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

These findings are not only novel but also form the basis for the practical implications we outline in our response to Review B, Question 5; namely, that license changes are not universally beneficial or harmful, but interact with language-specific community norms. This points toward the need for context-aware licensing strategies. Thus, while RQ2 does not include unlicensed projects directly, it provides new empirical insights into how and when license choice matters, insights that are essential for understanding licensing dynamics across the full OSS landscape identified in RQ1.

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



Review #819D
===========================================================================

Metareview
----------
Thank you for submitting to ICSE 2026.

This paper investigates the prevalence and impact of licensing in OSS projects. While reviewers recognized the importance of the topic, they consistently expressed concerns about the soundness of the approach. In particular, the comparison methodology—fresh just-starting repos are being compared with mature versions—was seen as problematic, raising questions about data stability. The authors’ response did not sufficiently address the omission of key factors such as project popularity (e.g., stars), nor did it justify the low R² values, casting doubt on the reliability of the findings. The paper was also found to lack novelty and depth in its discussion. Additionally, the revision directions remain unclear, leaving reviewers uncertain about the paper’s potential for improvement. As a result, the reviewers recommend rejection.

Recommendation
--------------
1. Reject
