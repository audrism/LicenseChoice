#!/usr/bin/env Rscript
# ICSE 2027 reanalysis - addresses ICSE 2026 reviewer concerns
#
# Robustness checks added on top of the original analysis:
#   (A) Adds firstDownP / firstUpP (downstream/upstream project counts measured
#       in the year following the first license adoption) as pre-treatment
#       popularity covariates for the FINAL license switch.
#   (B) Restricts to projects with AdoptDelay >= 12 months (first license
#       adopted at least one year after project creation) to address the
#       reviewer concern that "year-after-first-license" is often "year 1 of
#       project life" and confounds maturity with license effect.
#   (C) Restricts to projects with Distance >= 24 months to ensure clear
#       temporal separation between the two comparison windows.
#   (D) Re-runs on cP2all.2y (2-year window) for window-size robustness.
#   (E) Adds models with the popularity covariate to the full sample.

suppressMessages({
  library(dplyr); library(tidyr); library(lubridate)
  library(car); library(ggplot2)
})

# ---- Configuration ----
DATA_DIR  <- "data"
OUT_DIR   <- "out"
dir.create(OUT_DIR, showWarnings = FALSE)

names <- c("ProjectID", "License1", "Adoption1", "License2", "Adoption2",
           "Distance", "EarliestCommitDate", "LatestCommitDate", "Language",
           "NumAuthors1", "NumAuthors2", "NumBlobs1", "NumBlobs2",
           "NumCommits1", "NumCommits2", "NumFiles1", "NumFiles2",
           "NumActiveMon1", "NumActiveMon2", "UpProjects1", "UpProjects2",
           "DownProjects1", "DownProjects2")
classes <- c("character", "character", "character", "character", "character",
             "integer", "numeric", "numeric", "character",
             rep("integer", 14))

map <- read.table(file.path(DATA_DIR, "L2TL.s"), sep = ";", header = FALSE,
                  col.names = c("L", "TL"), quote = "", comment.char = "")

# Try to load proportions (if available); if not, set prop2 = NA.
prop_path <- file.path(DATA_DIR, "choice", "proportions.csv")
have_props <- file.exists(prop_path)
if (have_props) {
  proportions <- read.csv(prop_path, check.names = FALSE,
                          stringsAsFactors = FALSE)
  proportions <- proportions %>%
    mutate(t = as.Date(sub("-01$", "-15", t)))
  proportions_long <- proportions %>%
    pivot_longer(cols = -t, names_to = "LicenseType", values_to = "prop_value")
  prop1_long <- proportions_long %>%
    rename(Adoption = t, LType = LicenseType, prop1 = prop_value)
  prop2_long <- proportions_long %>%
    rename(Adoption = t, LType = LicenseType, prop2 = prop_value)
}

load_one <- function(path, window_years) {
  d <- read.table(path, sep = ";", header = FALSE, col.names = names,
                  colClasses = classes, quote = "", comment.char = "")
  d <- d %>%
    left_join(map, by = c("License1" = "L")) %>% rename(L1Type = TL) %>%
    left_join(map, by = c("License2" = "L")) %>% rename(L2Type = TL)

  d$L1Type <- relevel(droplevels(factor(d$L1Type)), ref = "other")
  d$L2Type <- relevel(droplevels(factor(d$L2Type)), ref = "other")

  # license-change direction (two-group)
  d$C2 <- ifelse(
    (d$L1Type %in% c("public-domain", "permissive")) &
    (d$L2Type %in% c("copyleft", "weak-copyleft", "conditional-open")),
    "P2R",
    ifelse(
      (d$L1Type %in% c("copyleft", "weak-copyleft", "conditional-open")) &
      (d$L2Type %in% c("public-domain", "permissive")),
      "R2P", "Other"))
  d$C2 <- factor(d$C2)

  d$Adoption1 <- as.Date(paste0(d$Adoption1, "-15"), format = "%Y-%m-%d")
  d$Adoption2 <- as.Date(paste0(d$Adoption2, "-15"), format = "%Y-%m-%d")
  d$EarliestCommitDate <- as.Date(as.POSIXct(d$EarliestCommitDate,
                                             origin = "1970-01-01", tz = "UTC"))
  d$LatestCommitDate <- as.Date(as.POSIXct(d$LatestCommitDate,
                                           origin = "1970-01-01", tz = "UTC"))
  curT <- as.Date("2023-08-01")
  d$EarliestCommit <- as.numeric(curT - d$EarliestCommitDate) / 30
  d$LatestCommit   <- pmax(0, as.numeric(curT - d$LatestCommitDate) / 30)
  d$Delay          <- pmax(0, as.numeric(d$Adoption1 - d$EarliestCommitDate) / 30)

  d$Burstiness1 <- (window_years * 12 + 2) / (d$NumActiveMon1 + 1)
  d$Burstiness2 <- (window_years * 12 + 2) / (d$NumActiveMon2 + 1)

  if (have_props) {
    d <- d %>%
      left_join(prop1_long, by = c("Adoption1" = "Adoption", "L1Type" = "LType")) %>%
      left_join(prop2_long, by = c("Adoption2" = "Adoption", "L2Type" = "LType"))
  } else {
    d$prop1 <- NA_real_
    d$prop2 <- NA_real_
  }

  # collapse rare languages exactly as the original notebook does (90% cum.)
  cc <- as.data.frame(table(d$Language))
  cc <- cc[order(-cc$Freq), ]
  cc$cum_prop <- cumsum(cc$Freq) / sum(cc$Freq)
  top <- as.character(cc$Var1[cc$cum_prop <= 0.9])
  d$Language <- factor(ifelse(d$Language %in% top, d$Language, "other"))
  d$Language <- relevel(d$Language, ref = "other")

  # signed-log diffs
  sl <- function(x) sign(x) * log1p(abs(x))
  d$lNumAuthorsDif    <- sl(d$NumAuthors2)    - sl(d$NumAuthors1)
  d$lNumBlobsDif      <- sl(d$NumBlobs2)      - sl(d$NumBlobs1)
  d$lNumCommitsDif    <- sl(d$NumCommits2)    - sl(d$NumCommits1)
  d$lNumFilesDif      <- sl(d$NumFiles2)      - sl(d$NumFiles1)
  d$lNumActiveMonDif  <- sl(d$NumActiveMon2)  - sl(d$NumActiveMon1)
  d$lUpProjectsDif    <- sl(d$UpProjects2)    - sl(d$UpProjects1)
  d$lDownProjectsDif  <- sl(d$DownProjects2)  - sl(d$DownProjects1)
  d$lBurstinessDif    <- sl(d$Burstiness2)    - sl(d$Burstiness1)

  for (nm in c("Delay", "Distance", "EarliestCommit", "LatestCommit",
               "prop1", "prop2")) {
    d[[paste0("l", nm)]] <- sl(d[[nm]])
  }

  # popularity proxies measured BEFORE the final license switch:
  # downstream / upstream project counts in the year AFTER first license adoption
  d$lFirstDownP <- sl(d$DownProjects1)
  d$lFirstUpP   <- sl(d$UpProjects1)

  # Lifetime fork count from cP2mongo.gz (when available via cP2pre_post merge).
  # Forks adds a third popularity dimension that is only weakly correlated with
  # DownP/UpP (Spearman 0.29/0.15) and well-conditioned in the combined model
  # (max VIF 1.36). CommunitySize is dropped because it is collinear with
  # Forks (Pearson 0.97). NumCore could be added (VIF 1.85) but is omitted
  # for parsimony.

  d
}

load_forks <- function(path = file.path(DATA_DIR, "choice", "cP2pre_post.1y")) {
  if (!file.exists(path)) return(NULL)
  pp <- read.table(path, sep = ";", header = TRUE, stringsAsFactors = FALSE)
  pp[, c("ProjectID", "NumForks")]
}

cat("Loading data...\n")
d1 <- load_one(file.path(DATA_DIR, "choice", "cP2all.1y"), 1)
d2 <- load_one(file.path(DATA_DIR, "choice", "cP2all.2y"), 2)

# Merge in fork counts (lifetime) from cP2pre_post.1y if available.
sl <- function(x) sign(x) * log1p(abs(x))
forks <- load_forks()
if (!is.null(forks)) {
  d1 <- merge(d1, forks, by = "ProjectID", all.x = TRUE)
  d1$NumForks[is.na(d1$NumForks)] <- 0
  d1$lForks <- sl(d1$NumForks)
  d2 <- merge(d2, forks, by = "ProjectID", all.x = TRUE)
  d2$NumForks[is.na(d2$NumForks)] <- 0
  d2$lForks <- sl(d2$NumForks)
  cat(sprintf("Fork counts merged in: 1y N=%d, 2y N=%d\n", nrow(d1), nrow(d2)))
} else {
  d1$lForks <- 0
  d2$lForks <- 0
  cat("WARNING: cP2pre_post.1y not found, lForks set to 0\n")
}

cat(sprintf("Loaded: 1y N=%d, 2y N=%d\n", nrow(d1), nrow(d2)))

# ---- Model fitting helpers ----

OUTCOMES <- c("lNumAuthorsDif", "lNumBlobsDif", "lNumCommitsDif",
              "lNumFilesDif", "lNumActiveMonDif", "lUpProjectsDif",
              "lDownProjectsDif", "lBurstinessDif")

fit_model <- function(d, with_popularity = FALSE, with_prop = TRUE,
                      with_forks = FALSE) {
  d <- d[d$C2 != "Other", ]
  d$C2 <- droplevels(d$C2)
  rhs <- "C2 * Language + lEarliestCommit + lLatestCommit + lDelay + lDistance"
  if (with_prop && have_props) rhs <- paste(rhs, "+ lprop2")
  if (with_popularity)         rhs <- paste(rhs, "+ lFirstDownP + lFirstUpP")
  if (with_forks)              rhs <- paste(rhs, "+ lForks")
  f <- as.formula(sprintf("cbind(%s) ~ %s",
                          paste(OUTCOMES, collapse = ", "), rhs))
  m <- lm(f, data = d, contrasts = list(Language = contr.sum))
  list(model = m, n = nrow(d), formula = deparse(f, width.cutoff = 500))
}

extract_R2 <- function(fit) {
  s <- summary(fit$model)
  data.frame(outcome = OUTCOMES,
             r_squared = sapply(s, function(r) r$r.squared),
             adj_r_squared = sapply(s, function(r) r$adj.r.squared))
}

extract_OR_table <- function(fit, alpha = 0.05) {
  s <- summary(fit$model)
  rows <- list()
  for (resp in names(s)) {
    coefs <- s[[resp]]$coef
    pvals <- coefs[, 4]
    keep  <- rownames(coefs) == "C2R2P" |
              (grepl("^C2R2P:", rownames(coefs)) & pvals < alpha)
    if (!any(keep)) next
    sub <- coefs[keep, , drop = FALSE]
    OR  <- exp(sub[, 1])
    se  <- sub[, 2]
    z   <- qnorm(1 - alpha / 2)
    rows[[resp]] <- data.frame(
      response = resp,
      term = rownames(sub),
      odds_ratio = OR,
      lower = exp(sub[, 1] - z * se),
      upper = exp(sub[, 1] + z * se),
      pvalue = pvals[keep])
  }
  do.call(rbind, rows)
}

# ---- Run model variants ----

cat("\nFitting model variants...\n")
models <- list(
  base_1y          = fit_model(d1, with_popularity = FALSE, with_forks = FALSE),
  popularity_1y    = fit_model(d1, with_popularity = TRUE,  with_forks = FALSE),
  popforks_1y      = fit_model(d1, with_popularity = TRUE,  with_forks = TRUE),
  forks_only_1y    = fit_model(d1, with_popularity = FALSE, with_forks = TRUE),
  base_2y          = fit_model(d2, with_popularity = FALSE, with_forks = FALSE),
  popforks_2y      = fit_model(d2, with_popularity = TRUE,  with_forks = TRUE),
  delay_ge12_1y    = fit_model(d1[d1$Delay >= 12, ],
                               with_popularity = TRUE, with_forks = TRUE),
  distance_ge24_1y = fit_model(d1[d1$Distance >= 24, ],
                               with_popularity = TRUE, with_forks = TRUE)
)

# ---- Persist results ----

r2_summary <- do.call(rbind, lapply(names(models), function(nm) {
  r2 <- extract_R2(models[[nm]]); r2$model <- nm; r2$n <- models[[nm]]$n; r2
}))
write.csv(r2_summary, file.path(OUT_DIR, "r2_summary.csv"), row.names = FALSE)
cat("\nR^2 summary (saved to out/r2_summary.csv):\n")
print(r2_summary %>% group_by(model, n) %>%
        summarise(min_R2 = min(r_squared), max_R2 = max(r_squared),
                  mean_R2 = mean(r_squared), .groups = "drop"))

or_tables <- lapply(names(models), function(nm) {
  t <- extract_OR_table(models[[nm]]); if (nrow(t) > 0) t$model <- nm; t
})
or_all <- do.call(rbind, or_tables)
write.csv(or_all, file.path(OUT_DIR, "odds_ratios_all_models.csv"),
          row.names = FALSE)
cat(sprintf("Wrote %d significant OR rows to out/odds_ratios_all_models.csv\n",
            nrow(or_all)))

# ---- VIF for the popularity model ----
cat("\nGVIF for popularity_1y model:\n")
vif_tab <- tryCatch(vif(models$popularity_1y$model)[, , 1], error = function(e) NA)
if (!is.null(dim(vif_tab))) {
  print(round(vif_tab, 3))
  write.csv(as.data.frame(vif_tab), file.path(OUT_DIR, "vif_popularity_1y.csv"))
} else {
  cat("VIF computation failed\n")
}

# ---- Coefficient stability table: C2R2P main effect across models ----
main_effect <- do.call(rbind, lapply(names(models), function(nm) {
  s <- summary(models[[nm]]$model)
  do.call(rbind, lapply(names(s), function(resp) {
    co <- s[[resp]]$coef
    if (!"C2R2P" %in% rownames(co)) return(NULL)
    data.frame(
      model = nm, outcome = resp,
      n = models[[nm]]$n,
      beta = co["C2R2P", 1],
      se   = co["C2R2P", 2],
      p    = co["C2R2P", 4],
      OR   = exp(co["C2R2P", 1]))
  }))
}))
write.csv(main_effect,
          file.path(OUT_DIR, "main_effect_stability.csv"), row.names = FALSE)
cat("\nMain R2P effect across models (OR):\n")
print(main_effect %>%
        select(model, outcome, n, OR, p) %>%
        mutate(OR = round(OR, 3), p = signif(p, 3)) %>%
        pivot_wider(names_from = model, values_from = c(OR, p)))

cat("\nDone. Outputs in:", normalizePath(OUT_DIR), "\n")

# Compute VIF on the popforks_1y model using type='predictor' (handles
# interactions and factors correctly).
cat("\n=== GVIF for popforks_1y (type='predictor') ===\n")
vif_pf <- tryCatch(vif(models$popforks_1y$model, type = 'predictor'),
                   error = function(e) {
                     cat("Error:", conditionMessage(e), "\n"); NULL
                   })
if (!is.null(vif_pf)) print(vif_pf)
