#!/usr/bin/env Rscript
# ICSE 2027 reanalysis - PRIMARY: year-before vs year-after final license switch.
# This addresses the central methodological concern from ICSE 2026 Reviewer B
# (re-iterated in MSR 2026 Reviewer B): the original design compares
# "year-after-first-license" to "year-after-last-license", which is asymmetric
# in lifecycle stage. The reanalysis here compares "year-before-last-license"
# to "year-after-last-license" for the same projects.
#
# Pre-window metrics are computed from cP2mongo.gz (monthly commit and author
# counts) which gives us NumCommits, NumAuthors, NumActiveMon in the pre-switch
# year. Blob/file/upstream/downstream pre-window counts require recomputation
# from base maps (not done here; future work).

suppressMessages({
  library(dplyr); library(tidyr); library(lubridate)
  library(car); library(ggplot2)
})

DATA_DIR <- "data"
OUT_DIR  <- "out"
dir.create(OUT_DIR, showWarnings = FALSE)

names1 <- c("ProjectID", "License1", "Adoption1", "License2", "Adoption2",
            "Distance", "EarliestCommitDate", "LatestCommitDate", "Language",
            "NumAuthors1", "NumAuthors2", "NumBlobs1", "NumBlobs2",
            "NumCommits1", "NumCommits2", "NumFiles1", "NumFiles2",
            "NumActiveMon1", "NumActiveMon2", "UpProjects1", "UpProjects2",
            "DownProjects1", "DownProjects2")
classes1 <- c("character","character","character","character","character",
              "integer","numeric","numeric","character", rep("integer", 14))

map <- read.table(file.path(DATA_DIR, "L2TL.s"), sep=";", header=FALSE,
                  col.names=c("L","TL"), quote="", comment.char="")

proportions <- read.csv(file.path(DATA_DIR, "choice", "proportions.csv"),
                        check.names=FALSE, stringsAsFactors=FALSE) %>%
  mutate(t = as.Date(sub("-01$","-15", t)))
prop_long <- proportions %>%
  pivot_longer(cols = -t, names_to = "LicenseType", values_to = "prop_value")
prop1_long <- prop_long %>% rename(Adoption = t, LType = LicenseType,
                                   prop1 = prop_value)
prop2_long <- prop_long %>% rename(Adoption = t, LType = LicenseType,
                                   prop2 = prop_value)

# ---- Load the main cP2all.1y file (after-first vs after-last) ----
d <- read.table(file.path(DATA_DIR, "choice", "cP2all.1y"),
                sep=";", header=FALSE, col.names=names1,
                colClasses=classes1, quote="", comment.char="") %>%
  left_join(map, by=c("License1"="L")) %>% rename(L1Type = TL) %>%
  left_join(map, by=c("License2"="L")) %>% rename(L2Type = TL)

d$L1Type <- relevel(droplevels(factor(d$L1Type)), ref="other")
d$L2Type <- relevel(droplevels(factor(d$L2Type)), ref="other")

d$C2 <- ifelse(
  (d$L1Type %in% c("public-domain","permissive")) &
    (d$L2Type %in% c("copyleft","weak-copyleft","conditional-open")),
  "P2R",
  ifelse(
    (d$L1Type %in% c("copyleft","weak-copyleft","conditional-open")) &
      (d$L2Type %in% c("public-domain","permissive")),
    "R2P", "Other"))
d$C2 <- factor(d$C2)

d$Adoption1 <- as.Date(paste0(d$Adoption1, "-15"), format="%Y-%m-%d")
d$Adoption2 <- as.Date(paste0(d$Adoption2, "-15"), format="%Y-%m-%d")
d$EarliestCommitDate <- as.Date(as.POSIXct(d$EarliestCommitDate,
                                           origin="1970-01-01", tz="UTC"))
d$LatestCommitDate <- as.Date(as.POSIXct(d$LatestCommitDate,
                                         origin="1970-01-01", tz="UTC"))
curT <- as.Date("2023-08-01")
d$EarliestCommit <- as.numeric(curT - d$EarliestCommitDate) / 30
d$LatestCommit   <- pmax(0, as.numeric(curT - d$LatestCommitDate) / 30)
d$Delay          <- pmax(0, as.numeric(d$Adoption1 - d$EarliestCommitDate) / 30)
d <- d %>%
  left_join(prop1_long, by=c("Adoption1"="Adoption","L1Type"="LType")) %>%
  left_join(prop2_long, by=c("Adoption2"="Adoption","L2Type"="LType"))

cc <- as.data.frame(table(d$Language))
cc <- cc[order(-cc$Freq), ]; cc$cum_prop <- cumsum(cc$Freq) / sum(cc$Freq)
top <- as.character(cc$Var1[cc$cum_prop <= 0.9])
d$Language <- factor(ifelse(d$Language %in% top, d$Language, "other"))
d$Language <- relevel(d$Language, ref="other")

# popularity proxies measured at or before the final license switch:
# (i)  downstream / upstream project counts in the year after first license
# (ii) lifetime fork count (a third dimension, only weakly correlated with i;
#       see icse27_popularity_corr.R: Spearman 0.29 / 0.15, max VIF 1.36 in the
#       combined model).
sl <- function(x) sign(x) * log1p(abs(x))
d$lFirstDownP <- sl(d$DownProjects1)
d$lFirstUpP   <- sl(d$UpProjects1)

# ---- Load pre/post final-switch data ----
prepost <- read.table(file.path(DATA_DIR, "choice", "cP2pre_post.1y"),
                      sep=";", header=TRUE, stringsAsFactors=FALSE)
cat("pre/post file has", nrow(prepost), "rows\n")

# Merge: keep only projects that are in BOTH the cP2all.1y sample
# (Distance>=12 and lastAdoption < 2022-08, the regression cohort)
# and have non-null pre/post counts.
m <- merge(d, prepost, by="ProjectID", all.x=FALSE, all.y=FALSE)
cat("merged: ", nrow(m), "rows\n")

# Filter to change rows (P2R / R2P) for the analysis
m <- m[m$C2 != "Other", ]
m$C2 <- droplevels(m$C2)
cat("after filter to P2R/R2P:", nrow(m), "rows\n")

# ---- Compute response variables ----
# Original design: lastCommits - firstCommits, signed log-diff
m$lCommitsDif_AFvAL <- sl(m$NumCommits2) - sl(m$NumCommits1)
m$lAuthorsDif_AFvAL <- sl(m$NumAuthors2) - sl(m$NumAuthors1)
m$lActMonDif_AFvAL  <- sl(m$NumActiveMon2) - sl(m$NumActiveMon1)
# New design: post - pre (around final license adoption)
m$lCommitsDif_BLvAL <- sl(m$postNcmt) - sl(m$preNcmt)
m$lAuthorsDif_BLvAL <- sl(m$postNauth) - sl(m$preNauth)
m$lActMonDif_BLvAL  <- sl(m$postActMon) - sl(m$preActMon)

# Add forks as a third popularity covariate
m$lForks <- sl(m$NumForks)

# logs of controls
for (nm in c("Delay","Distance","EarliestCommit","LatestCommit","prop2")) {
  m[[paste0("l", nm)]] <- sl(m[[nm]])
}

# ---- Model fitting ----
fit_uni <- function(resp, dat, with_pop=TRUE, with_forks=TRUE) {
  rhs <- "C2 * Language + lEarliestCommit + lLatestCommit + lDelay + lDistance + lprop2"
  if (with_pop)   rhs <- paste(rhs, "+ lFirstDownP + lFirstUpP")
  if (with_forks) rhs <- paste(rhs, "+ lForks")
  f <- as.formula(sprintf("%s ~ %s", resp, rhs))
  lm(f, data = dat, contrasts = list(Language = contr.sum))
}

# Compare original-design vs new-design coefficients for each outcome.
# We focus on three outcomes that can be computed both ways: commits, authors,
# active months.

results <- list()
for (tag in c("AFvAL", "BLvAL")) {
  for (resp in c("lCommitsDif", "lAuthorsDif", "lActMonDif")) {
    nm <- paste0(resp, "_", tag)
    fit <- fit_uni(nm, m, with_pop=TRUE)
    co  <- summary(fit)$coef
    # extract C2R2P main + interaction rows
    rn <- rownames(co)
    keep <- rn == "C2R2P" | grepl("^C2R2P:", rn)
    sub <- co[keep, , drop=FALSE]
    df  <- data.frame(
      design = tag, outcome = resp,
      term = rownames(sub),
      beta = sub[, 1], se = sub[, 2],
      pvalue = sub[, 4],
      OR = exp(sub[, 1]),
      lower = exp(sub[, 1] - 1.96 * sub[, 2]),
      upper = exp(sub[, 1] + 1.96 * sub[, 2]),
      stringsAsFactors = FALSE
    )
    results[[nm]] <- df
  }
}
all_res <- do.call(rbind, results)
write.csv(all_res, file.path(OUT_DIR, "prepost_vs_orig_design.csv"),
          row.names=FALSE)

cat("\n=== Main R2P effect (C2R2P) by design and outcome ===\n")
main <- all_res[all_res$term == "C2R2P", c("design","outcome","OR","pvalue")]
main$pvalue <- signif(main$pvalue, 3); main$OR <- round(main$OR, 3)
print(main)

cat("\n=== Significant R2P:Language interactions (p<0.05) by design ===\n")
sig <- all_res[all_res$term != "C2R2P" & all_res$pvalue < 0.05,
               c("design","outcome","term","OR","pvalue")]
sig$pvalue <- signif(sig$pvalue, 3); sig$OR <- round(sig$OR, 3)
print(sig)

# Save merged data for further inspection
write.csv(m[, c("ProjectID","Language","C2","Distance","Delay",
                "NumCommits1","NumCommits2","preNcmt","postNcmt","firstNcmt",
                "NumAuthors1","NumAuthors2","preNauth","postNauth","firstNauth",
                "NumActiveMon1","NumActiveMon2","preActMon","postActMon",
                "firstActMon","DownProjects1","UpProjects1")],
          file.path(OUT_DIR, "merged_prepost.csv"), row.names=FALSE)

cat("\nMerged data saved to out/merged_prepost.csv\n")
cat("Done.\n")
