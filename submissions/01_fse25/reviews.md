FSE 2025 Paper #276 Reviews and Comments
===========================================================================
Paper #276 Understanding the Dynamics of License Selection in OSS


Review #276A
===========================================================================

Overall merit
-------------
1. Reject

Reviewer expertise
------------------
4. I have published one or more papers on at least one of the topics in the
   paper.

Novelty
-------
2. Incremental improvement

Soundness
---------
1. Poor

Quality of presentation
-----------------------
3. Well-written

Paper summary
-------------
The study builds a fairly large set of hypotheses regarding open source license choice associated with factors such as project popularity, the number of contributors, programming language, activity, and age. It then tests the hypotheses based on the World of Code data set using descriptive statistics and ANOVA techniques. Some of the findings contradict existing studies by a wide margin, while other hypotheses are confirmed.

Strengths
---------
- Interesting field of study, relevant to practitioners
- Commendable (though flawed) attempt at theory building
- The study of license changes is relatively novel and potentially impactful

Weaknesses
----------
- Many hypotheses are presented as correlations, even though they don't even pass the "Post hoc, ergo propter hoc" test. They would be week even if presented as correlations.
- Other hypotheses appear to be plucked out of thin air.
- Too many hypotheses dilute the paper's scope and give the impression of data dredging.
- The presentation of the results has significant room for improvement.

Detailed comments for authors
-----------------------------
This is worthwhile work that can benefit from a number of improvements in the areas of hypothesis building, data selection, and visualization.

## Originality
The work's contributions constitute a small incremental improvement to the state-of-the-art. Open source licensing has been studied extensively. License changes less so, but their study would require more focus and rigor than what is presented here.
The motivation behind this work is clearly set in the introduction.
The work's impact to the field is clear, but likely to be rather small due to serious limitations regarding the study's hypotheses and methods.

## Soundness
The claimed contribution is insufficiently supported by the employed research method. The study's hypothesis building is commendable, but very weak. (See detailed comments below.) Several hypotheses establish a causation between the license, which is typically selected at the project's outset, and diverse metrics, which arise long after a project is launched. It would be difficult to argue even for a correlation between these variables, let alone causation. Other hypotheses don't follow from the discussion leading to them. Furthermore, the author indiscriminately treat version control repositories hosted on Word of Code as open source projects. Many could be (and probably are) in fact be documents, student coursework, or code examples. This severely limits the veracity of Section 5.1 Finding 1, as also argued by Finding 4.

The described methods provide sufficient information regarding how data were obtained, analyzed, and interpreted though some details are missing, particularly regarding the detection of licenses.
The method's description clearly presents how data was obtained, analyzed, and interpreted. Furthermore, the description and the provided materials support independent verification or replication of the paper’s claimed contributions.
Threats to validity are discussed, but in a superficial manner. Important threats are likely to affect the validity of the employed method.
The contribution's evaluation leaves much to be desired especially regarding the findings, many of which would not pass muster if discussed with an OSS practitioner. Triangulation with other instruments is highly recommended.

## Comparison to related work
Existing work in the area is coherently analyzed and synthesized, and the study's contributions are clearly identified in its context.

## Presentation
The paper is mostly well structured, though in the hypothesis development there are overlaps and confusing divisions.
The writing is clear and easy to understand.
The text is free from typos and style errors.
The formatting follows the provided instructions.
The abstract is mostly self-standing and summarizes important parts of the study. Interestingly, the abstract could be improved by narrowing the paper's focus and scope.
The provided figures help the reader understand the presented material. Their design can be improved in terms of aesthetics and readability.


## More detailed comments
__Line 9__: The assertion that “that over 80% of OSS projects have no license” is by definition incorrect. According to the Open Source Initiative definition, open source software shall include a license. Perhaps the authors mean something else when the write “OSS”.   
__Line 89__: The wording “affect” implies post-hoc causation, which is illogical. Consider revising the wording and the whole paragraph accordingly.   
__Line 95__: Is the language choice a function of language or time when the project was initiated?   
__Line 148__: This is an apparently novel and important argument.   
__Section 2.1__: It is unclear how the preceding theory development leads the hypotheses.   
__Line 197__: This is a solid interesting argument. It would be nice to capture it ina hypothesis associated with a language's reuse and linking mechanisms.   
__Line 204__: Again, a post-hoc causation argument: the license is typically chosen before forks, stars, and community size are established.   
__Line 210__: See above.   
__Section 2.2__: It is unclear how the preceding theory development leads to the presented hypotheses.   
__Line 261__: Please clarify, delays in what, adoption of what?   
__Section 2.3__: It is unclear how the preceding theory development leads to the hypotheses.   
__Section 2.4__: Another post-hoc argument: activity, number of files, age, and burstiness can typically be determined long after a license is chosen.   
__Line 412__: It is unclear how the era periods were chosen, especially 2010.   
__Line 472__: Please specify how licenses were detected and determined.   
__Line 573__: I would expect the absence of a license to be studied in the context of the reused code mentioned here.   
__Figure 4__: A stacked 100% bar chart would better visualize this figure's intent.   
__Table 5__: Please use a more descriptive caption   
__Table 5__: It is very difficult to understand this table. Consider reducing the reported accuracy, or, better, depicting the data in a figure.   
__Section 6.1__: A subsection here seems superfluous, as there are no other subsections.



Review #276B
===========================================================================

Overall merit
-------------
1. Reject

Reviewer expertise
------------------
5. I have published on all the topics in the paper.

Novelty
-------
2. Incremental improvement

Soundness
---------
1. Poor

Quality of presentation
-----------------------
2. Adequate

Paper summary
-------------
The manuscript offers a large analysis of Open Source license choice from projects stored the World of Code database (virtually all of them). It does so from very different perspectives, from number of authors to diversity (approximated by female developers) to project age or number of files. The key findings offer insight on how these variables are related to the different types of licenses.

Strengths
---------
  + Analysis with lots of data
  + Comprehensive

Weaknesses
----------
  - Construct validity: once a license is chosen it is difficult to change it
  - License detection seems to be flawed
  - Validation has room for improvement

Detailed comments for authors
-----------------------------
Originality

The manuscript is original. There have been other efforts of a comprehensive license analysis of Open Source projects, but not at this scale.


Soundness

The article has a fundamental problem: it talks about the characteristics that should influence license selection in OSS projects, but it does not take into account that in most cases the license selection is made "a priori", at the beginning or early stages of the project, and that it is very difficult to change afterwards if there are many copyright holders. See among others the "Legal Side of Open Source" 

https://opensource.guide/legal/#:~:text=If%20you're%20the%20sole,in%20order%20to%20change%20licenses.

I understand that what I am saying can be considered as "good practices" and that these may not be reflected in reality (as the manuscript shows, in the case of a large amount of unlicensed free software), but for that to happen, the moment in which the license was introduced should have been studied and it should have been shown that it was done at a late stage, so that statements like "The number of forks, stars, and community size associated with a project can also impact license decisions." (page 5), "Projects aiming to encourage collaboration and reuse to maintain this momentum may favor permissive licenses" (page 5) or "the number of downstream projects a project interacts with can play a crucial role in license selection." make sense. Vendome et al. have studied license changes and found in 16,221 Java projects around 1,160 projects with license change commits (which is 7%)... but it has to be noted that some of these changes were reverted.

@article{vendome2017license,
  title={License usage and changes: a large-scale study on github},
  author={Vendome, Christopher and Bavota, Gabriele and Penta, Massimiliano Di and Linares-V{\'a}squez, Mario and German, Daniel and Poshyvanyk, Denys},
  journal={Empirical Software Engineering},
  volume={22},
  pages={1537--1577},
  year={2017},
  publisher={Springer}
}

I am very surprised that 83% of the projects do not have a license. Since this is a very surprising statement, I think the authors should have dug a little deeper, after all there is the saying that "extraordinary claims require extraordinary evidence". I do not mean that the reported result is incorrect, only that it is extraordinary and should therefore have been investigated further. It is my intuition that this result is due to the fact that the license identification process that has been followed (i.e., seeing if there is a file containing LICENSE in the filepath in the project) is not the only way to indicate a license and that therefore there are many false negatives. This may be because the file containing the license is called COPYING, COPYRIGHT, among others.

Gonzalez et al. who have studied the Software Heritage archive found "the GPL version 3 text [...] with 662 different names, including "COPYING", "LICENSE.GPL3", and "a2ps.license", which means there will be 662 lines in this table for that blob." See:

@article{gonzalez2023software,
  title={The software heritage license dataset (2022 edition)},
  author={Gonzalez-Barahona, Jesus M and Montes-Leon, Sergio and Robles, Gregorio and Zacchiroli, Stefano},
  journal={Empirical Software Engineering},
  volume={28},
  number={6},
  pages={147},
  year={2023},
  publisher={Springer}
}


Evaluation (if relevant)

I have many concerns about the methodology. On the one hand, claims are made that are difficult to sustain, such as that projects can consistently choose their copyright management strategy. Generally, once a license has been chosen, switching to another is difficult. Still, I believe that the method of identifying licenses has not been adequately evaluated and that, therefore, the results offered in the manuscript are not robust.


Importance of contribution

The importance of the contribution depends very significantly on the issues raised above. I believe that if the results offered are proven to be true, this would be a highly impactful article. This is precisely what makes me cautious at this moment in time and with the validation and evidence provided.


Appropriate comparison to related work

Anything to add here. I miss the two references pointed above, but besides that I think what has been done is fine.


Quality of presentation

The manuscript is in general well written and easy to follow. Writing about licenses is not easy, and there are some minor points that I have noted down that I would have expressed in a different way or that I am not sure I understood correctly. In particular:

I would prefer to see a neutral naming of licenses. Thus, copyleft licenses are named as "restrictive" in the manuscript, which is very much in the view of people who are in favor of "permissive" licenses. I would advocate using copyleft consistently.

Also, on page 4 it says that Elasticsearch has moved from a commercial license to AGPL. Strictly speaking, free software licenses also allow commercialization of software, so the more appropriate term would be to use the term "proprietary".

In page 11: "For comparison, only approximately 8% of of “copyleft” licences were changed, which is consistent with our theory (H1c) that ideology-related licence choice should be most “sticky.". This requires rewording or further explanation. It makes sense that projects with a permissive license might change their license, as this is allowed by the license itself; but for copylefted projects this is more difficult, as this would require that all authors agree... That 8% of copylefted projects perform such a change is thus surprising, given that asking for permission from all authors is not an easy task.

Page 1: specifically because copying no-license code is likely to result in license violation, -> if there is no license there is no license violation. What it can be is copyright violation.

Page 8: This characteristic is essential for maintaining the open source nature of software, as it prevents proprietary modifications -> the copyleft does not prevent proprietary modifications, but proprietary redistributions.

Page 10: shown in these figures, -> shown in Figure 1,

Page 17: such as conditional open and weak copyleft licenses, reflecting a desire to retain attribution when code is copied or modified, -> Not sure what is meant here. All open source licenses retain attribution. It is just public domain software or CC0 that does not so. Is that what is meant?

Questions for authors’ response
-------------------------------
1. Could it be that there are 83% unlicensed projects in the dataset?
2. How can you be sure that the studied variables affect the chosen license, if the license was chosen previously (and is difficult to change)?



Review #276C
===========================================================================

Overall merit
-------------
1. Reject

Reviewer expertise
------------------
3. I have worked or work on at least one of the topics in the paper.

Novelty
-------
2. Incremental improvement

Soundness
---------
1. Poor

Quality of presentation
-----------------------
3. Well-written

Paper summary
-------------
This paper investigates the dynamics of license selection within open-source software (OSS) projects. The results show a significant gap in license awareness and enforcement. The authors analyzed over 131 million OSS projects, and discovered that 83% lack formal licensing, which could pose potential risks of license violations. The authors propose a preliminary theory of license choice and test it using a multinomial regression model to explore factors influencing license choices, such as project age, number of commits, and programming languages. The study emphasizes the need for better tools and education to guide developers in making informed licensing decisions

Strengths
---------
- Easy to read and flow is good.

Weaknesses
----------
- The motivation behind the study could be stronger. Some results are predictable or already known, which limits the novelty.
- The methodology linking the theoretical concepts of license choice to actual empirical data could benefit from more elaboration.
- The choice of systems selected for the study is questionable.

Detailed comments for authors
-----------------------------
What exactly can we do with this information? Some of it can be inferred and predicated without the need for a comprehensive study. Saying that the findings can help developers to choose the appropriate license for the project is not enough. Consider providing more practical insights or recommendations based on your findings, which could directly benefit developers and maintainers. 

Software projects without a license are, by definition, NOT open source.  This is both a flaw in the paper and a miss-use of standardized terminology in the field.  Project should be categorized as:  projects without a license and projects with an open-source license.  

Making a statement such as “ of 131 million OSS projects, finds that 83% of these projects lack a formal license”  is completely flawed.  What you have is 131 million public projects of which 83% have no license and 17% have OSS licenses.  Or I’m assuming they are OSS licenses.  Maybe some are more restrictive?

Many projects (e.g., on GitHub) are simple projects, student projects, or very short-lived projects that the developer(s) do not see the need for a license.  Just because they are public, does not imply they are open source, or meant to be used as an open source code by others.  

How did you determine gender of team members?  This is non-trivial in many cases as gender is not totally clear.

Soundness: The authors use a multinomial regression model and statistical analysis to link a set of hypotheses to empirical data. The methods used are fine and appropriate for the study's objectives.   However, the selection of data is very questionable. 

Relevance: The findings might be useful to the OSS community and could provide some guidance for developers and maintainers in choosing appropriate licenses for their projects.  However, this is unclear due to the selection of data.

Originality: The study lacks novelty as it replicates previous research on similar topics. However, the authors claim it distinguishes itself by being the largest study of its kind to date.  

Usability: The study does not focus on a specific tool. However, the extent to which the findings are useful and could be tailored to different demographics within the OSS community (e.g., new vs. experienced developers) could be further explored.

Presentation: The paper is generally well-written, with clear descriptions and explanations. The figures and tables are readable. The flow is good, and the paper reads well.  The paper uses past tense in many places and this is quite distracting.

Questions for authors’ response
-------------------------------
None
