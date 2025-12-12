MSR 2026 Paper #344 Reviews and Comments
===========================================================================
Paper #344 The Prevalence and Impact of Licenses in Open Software Projects


Review #344A
===========================================================================

Overall merit
-------------
2. Weak reject

Paper summary
-------------
This work focuses on license usage in open source software and analyzes ecosystems for this purpose. The authors identified licenses and license types for over 100M software projects using an existing dataset created in an earlier work from World of Code. Among the findings it was found that that cases most do not indicate any license, permissive licenses represent the license of most cases and there is an increasing proportion of them over time.

Strengths and Weaknesses
------------------------
+ Licensing issues in open source software is always a timely relevant area, as open source software use is wide.
- The main approach has been studied also in prior works (e.g. how licenses change over time, projects without license).
- The approach followed for the theory development does not rely on a formal (or created) methodology.
- The hypotheses are not linked with the results.

Comments for authors
--------------------
**Soundness**

I value the objective of creating a theory on license choices, but the process described is closer to a study of the related work (and respective presentation of background and related work), than a actual methodology to create a theory. I believe that a formal methodology needs to be followed (or created if needed) in order to formally describe how research and businesses choose a license. This comment applies to all subsections of section 2, as they follow the same structure.

Also, an important aspect is that whether projects that are used only for educational or testing purposes were considered, as their licensing scheme is not as important as other projects but might nevertheless affect the results (it might have affected especially the high no-license percentage). 

When it comes to license identification, concerning the approach for the license change it is not clear why only two groups of licenses are used and not more license types (as when identifying a project license).

It would be useful to connect the results (or compare them) with the initial hypotheses. Hypotheses are presented in the beginning of the paper but are not discussed afterwards, so there is also a gap here.

**Relevance**

The work is relevant to the SE community, and specifically to OSS. It is relevant also specifically to MSR.

**Novelty**

OSS license usage has been studied extensively in prior works. Yet, the work focuses mainly on. license choices and in choosing e.g. no license. The main differentiation, as it is indicated in the work, is the consideration of the whole OSS landscape which is useful but I do not believe it is enough as differentiation point. Still, the work relies on an existing dataset [19]. This might bring along drawbacks of the original dataset creation (as indicated also in that prior work it used only: "files explicitly named “license” or located in license-related directories"). 

Overall, I was confused with the introduction because initially the authors would specify a new theory but then many of the main results reported do not differ from prior works that indicate the popular licenses (there data are also available from GitHub now, e.g. https://github.blog/open-source/open-source-license-usage-on-github-com/).

Also in the introduction, it is indicated that prior works have underestimated the percentage of repositories with no license but I am not sure if this is true, I know that much earlier in 2013 only less than 15% of repositories in GitHub had a license as reported by: https://collaborationsummit2013.sched.com/event/Y5cqbV, but the link that refers the percentage does not seem to work any more. But even so, it is to be expected that prior works rely on a small dataset but that can be representative of OSS projects. 

**Presentation**

The text is overall easy to read.

I do not think that the title reflects well the work performed, as the introduction talks mainly about a preliminary theory on license choices not reflected in the title.

Also, I find that the text contains a lot of background text that is not required, as instead a formal methodology could be added.

**Replicability**

A replication package has been made available on Zenodo. It is only not clear whether the large file with licenses is the same one from [19].

Questions for authors' response
-------------------------------
1) Concerning the approach for the license change, why are only two groups of licenses used and not more license types?
2) Were projects that are used only for educational or testing purposes also considered or were they filtered out? If the later is the case, how were they identified?



Review #344B
===========================================================================

Overall merit
-------------
3. Weak accept

Paper summary
-------------
In this paper, the authors explore the state of licensing in open-source software, as well as the impact of license changes on various software project metrics. Unlike the previous works, the authors employ a large dataset based on the World of Code, consisting of more than 130 million projects. The authors group all licenses in projects into different types (unlicensed, permissive, copyleft, weak copyleft, conditionally open, and public domain) and study how the types are distributed, discovering much more unlicensed code than previously reported. Then, the authors focus on license shifts and run a multivariate multiple regression model to see how different project metrics change with the change of the license from permissive to restrictive or vice versa. Among the specific findings, it can be seen that almost all metrics are very dependent on the language ecosystem.

Strengths and Weaknesses
------------------------
**Strengths**

+ Important topic.
+ Novel approach, combining theory and analysis.
+ Some novel and important results.
+ Good replication package.

**Weaknesses**

- Methodological motivations missing.
- Not clear how to interpret or use the results of the regression analysis.

Comments for authors
--------------------
I already reviewed this paper at ICSE, where it was rejected, even though I was more positive towards it. As far as I can see, the text and the figures are exactly the same, with the exception of two places that were added directly in response to some concerns of previous reviewers:

1. The authors mentioned that they only classified 50 most popular licenses (covering 98.9% of projects) at the end of Section 4.1.
2. The authors added information about R2 to Section 5.2.1.

Given that my review was already structured exactly around MSR criteria, I will repeat it here, while taking into account some points from other reviews that I consider relevant and the authors' response from ICSE (_e.g._, my concern about grouping of licenses is fixed in Section 4.1).

**Novelty**

The parer explores a known topic, but it clearly articulates its differences from previous work. Also, with my experience of working with a lot of 0-star unlicensed projects on GitHub, I find it welcome that these peculiarities in the paper are highlighted.

One downside I found in the paper in this regard is a very small comparison to previous exploratory works. While the second, regression, part of the work is more specific, I am not sure why the first part is only compared to Cui et al. and Wu et al., since there are many works that study the prevalence of different licenses in software. The authors should consider at least tangentially comparing their results with the classic works of Christopher Vendome and Daniel German or any of the recent large-scale empirical studies on the topic.

**Soundness**

It is in the methodology of the study that I find concerns. Overall, the work is very broad – covering a large dataset, a lot of metrics and conjectures, and not going into details on specific projects, so the work inherently has many limitations and a certain compounding error, which it addresses. Some conjectures seem very reasonable, while some are less so, for example, H3d about burstiness. 

In my first review, I highlighted some issues with the potential classification of licenses, but the authors responded to them clearly. I don't think they reclassified WTFPT to the public domain, though, nor did they add any comments.

However, my main concerns relate to the comparison points. The authors decided to compare the metrics by going with the year after the initial license choice instead of comparing, for example, the year before the final license switch and the year after, which seems more straightforward. On line 444 the authors themselves write that _“initial license selections … may be arbitrary or uninformed”_, and yet they consider a year after them in comparison. I understand that the comparison revolves around the final license switch, but then it’s not clear to me why not choose the time before that as a closer target for comparison.

It seems probable that initial licenses are also selected at the very start of the project in a significant number of cases. Because of this, the authors end up comparing early stages of such projects with much later ones, which means that the changes can be due to other factors. The authors do control for “Adopt delay”, but it is not clear from the paper how often it is the case that the first license exists in the early stages of the project, where the dynamics are very different. The authors should definitely comment on this in the paper.

The response to this point in the previous rebuttal did not satisfy me, as I believe that the arguments about "anticipatory effects and transitional noise" and "intentional project states" do not beat the fact that the starting year with the first license is just very different. I still do not think that just accounting for AdoptDelay, Project Age (EarliestCommit), and Time Since Last Commit (LatestCommit) mitigates the fact of just how different the entities compared are. Importantly, the authors also did not add any of this discussion to the paper, even though they promised to.

Minor, in section 5.2, the authors write: _“The middle group, consisting of projects that had more than one license type in their lifetime but have only one type ultimately, is the group we analyze license changes in.”_ This results in only 2.4% of licensed projects studied for the final part, (which are themselves a minority from the initial 100+ million). I believe this has to be indicated in the abstract and the introduction.

There is one particular concern mentioned by other reviewers at ICSE that I found relevant. The hypotheses are framed as causal relationships, but the regression analysis can only establish associations. The authors should clarify the limitations of their methodology in inferring causality. They promised to change their phrasings for associational but didn't.

**Relevance**

The paper is relevant to the field, and some of its findings are very valuable to the community. Highlighting unlicensed projects is crucial, and I also found Section 5.1.3 to be very insightful. In general, I find the results of the first part of the paper to be a great contribution.

At the same time, I am not sure about the usefulness of the regression analysis. The results do indeed differ between the languages, but despite the authors’ efforts, I was not able to see a clear reason for that in the paper, rather the paper just draws attention to how different the languages are. Given my concerns about the validity of the comparison of the year-long intervals that I expressed above, I am not sure what practical implications can be drawn from these results. Even though this is probably outside the scope of this paper, it lacks some kind of case study or a qualitative addition, because with all the threats to the validity of the general large-scale comparisons and such a complicated regression model, the results feel distant from a practical reality.

**Reproducibility**

I would like to thank the authors for a great replication package. I was able to dive deeper into the results by studying it.

**Presentation**

Overall, the paper is structured and written well, it is mostly easy to understand. One exception is the abstract, which is very hard to get through. It is written in rather complicated grammar and lacks commas. This is not a problem for the paper itself, though.

One thing that bothered me about the structure of the work is that the hypotheses are very structurally and clearly introduced, but are not resolved the same way. Most of them are only mentioned once in the middle of results, not in Key findings. They are also somewhat hard to track because they are introduced and concluded following different logic. They are introduced divided by some motivational logic, but checked divided by prevalence and performance metrics.

I was also a bit confused in Section 4.1 point 5, where the authors write “Public Domain/Unlicensed: Public domain and unlicensed software, including those using the Creative Commons Zero (CC0) license, are not restricted by copyright law.” The authors clearly understand that unlicensed code is not the same as public domain, they write several times that using unlicensed code is a violation and that it is not technically even open-source. So in a way it is the opposite of the public domain. Did the authors mean “licensed under the Unlicense public domain license”? Anyway, this is never an issue in the paper, but this part is written strangely.

Finally, Figure 4 is a bit confusing to read, it would be easier if the numbers were marked with what exactly they are showing.

Questions for authors' response
-------------------------------
I removed the questions to which I already received satisfactory answers. I only keep the two main ones for the other reviewers to consider them, and for the authors to take another stab at answering them.

1. Why did you not compare the year before the final license switch and the year after, instead comparing “years after” separated by a long time, in which other parameters may have influenced the comparison? Given that the vast majority of projects take the first license right after creation, this makes it so that one comparison point is often very immature.
2. What practical implications are there from the regression analysis?



Review #344C
===========================================================================

Overall merit
-------------
2. Weak reject

Paper summary
-------------
This paper presents a large-scale empirical study on the prevalence and impact of software licenses across more than 131 million open-source projects, leveraging the World of Code (WoC) infrastructure. The study makes two primary contributions. First, it finds that 83% of projects lack a detectable license, a figure much higher than reported in existing studies. Second, it investigates the impact of license changes on project activity. Using a multivariate regression model, the authors find that the effects of switching between permissive and restrictive licenses are strongly moderated by the project’s programming language ecosystem. Interestingly, a switch to a permissive license is associated with a decrease in activity (e.g., commits, authors) in C/C++ projects but with an increase in repository growth and sustained activity in Python projects, providing nuanced, actionable insights for project maintainers.

Strengths and Weaknesses
------------------------
### Strengths
+ A large-scale empirical study of licenses in open-source software projects.
+ The paper provides some actionable insights for practitioners at the end.

### Weaknesses
- The motivation of the study is unclear.
- The selection of the data may lead to misleading results.
- The paper contains some writing issues.

Comments for authors
--------------------
The paper is well written and easy to follow. It also provides some actionable insights for practitioners at the end. However, I have some concerns about the data collection that may lead to misleading results. Please find my review comments below.

### Soundness
My main concern about the soundness of this study is the data collection. The paper argues that it performs a larger-scale study than existing studies [44, 7, 43, 45], analyzing 131,171,379 repositories. From what I understand, the paper includes all available projects in the World of Code (WoC) for analysis. However, there are no inclusion or exclusion criteria set for the projects. This could mean that very simple or toy projects are also included in the analysis, which can be a serious threat to the external validity of the study. Potentially, the large percentage of unlicensed projects (83%) may come from this pool. How do we ensure that the findings are actually representative of the engineered software projects?

To make the analysis clearer, the paper should also provide a breakdown of the unlicensed projects by some metrics such as stars, forks, watchers, and pull requests. So, we can see where these unlicensed projects really come from. 

I think the paper provides practitioners with insightful, actionable implications based on the findings. Nonetheless, the changes in software licenses may be caused by other factors not considered in this study (e.g., seeking commercial adoption). It is unclear how the paper controls for such confounding factors.

When the paper studies the license retention rate, does it also consider a case in which a project switched from an original license to a new license, then switched back to the original license? Would it be considered as license retention?

### Relevance
I think the paper is relevant and should be of interest to the MSR community. The paper investigates an important issue in software development and discusses related prior studies. The paper points out that the existing studies either (1) target some specific ecosystems or specific programming languages, or (2) analyze only specific sets of open-source projects. Thus, the paper conducts a larger-scale analysis of software licenses in open-source projects to fill this gap. 

### Novelty
Given existing studies on the prevalence of software project licenses, the paper’s novelty in this regard is not particularly high. However, the study of the impact of license changes is new and provides interesting findings.  

### Presentation
In Table 1, the number of projects analyzed is presented as 131,171,379. However, the actual number of analyzed projects (after some filtering) in this study is 20,110,256. So, putting the full number of projects in the table is misleading.

Table 2 should include the names of the authors for [44] and [7].

### Replicability
The paper explains the methodology in sufficient detail and should be enough for replicating the study.

The paper also provides a replication package on Zenodo. However, the README for the replication package is pretty brief and does not include instructions for analyzing the data.

Artifact Assessment
-------------------
3. The artifacts are present and sufficiently in line with what is declared
   in the submission form and in the paper

Questions for authors' response
-------------------------------
* Q1: What are the groups or characteristics of projects that do not contain the license?
* Q2: How does the paper control other confounding factors that might affect the changes in the license?
