#!/usr/bin/env Rscript
# ICSE 2027 primary reanalysis -- year-before vs year-after FINAL license
# switch, on V2604-aligned commit data.
#
# This is the "principled" version of icse27_prepost.R: the pre-window
# metrics for commits, files, blobs, and active months come from a direct
# V2604 base-map scan (data/choice/cP2all.V2604.1y, produced by the da7
# pipeline), not from an approximation via cP2mongo. Upstream/downstream
# pre-window counts come from a V-era Pt2Ptb scan (data/choice/cP2UpDown.V.s,
# produced by the da8 pipeline) and are translated to V2604 project IDs via
# Pold2Pnew.modal.s before the merge.
#
# Schema of cP2all.V2604.1y (semicolon-separated, no header, 22 cols):
#   1  Pnew                        -- V2604 canonical project ID
#   2  firstLic
#   3  firstAdop  (YYYY-MM)
#   4  lastLic
#   5  lastAdop   (YYYY-MM)
#   6  distance   (months)
#   7  firstT     (epoch sec)
#   8  lastT      (epoch sec)
#   9  oldList    (comma-separated V-canonical Pold contributors)
#   10 flag       (FL / LL / MERGE<n> / '-' )
#   11 firstNcmt    12 firstNfiles    13 firstNblobs    14 firstActMon
#   15 lastNcmt     16 lastNfiles     17 lastNblobs     18 lastActMon
#   19 preNcmt      20 preNfiles      21 preNblobs      22 preActMon
#
# Schema of cP2UpDown.V.s (from da8):
#   Pold ; window (FIRST|LAST|PRE) ; direction (U|D) ; count
#
# Schema of Pold2Pnew.modal.s:
#   Pold ; Pnew

suppressMessages({
  library(dplyr); library(tidyr); library(lubridate)
  library(car); library(ggplot2)
})

DATA_DIR <- "data"
TRANSLATION_DIR <- "translation"
OUT_DIR <- "out"
dir.create(OUT_DIR, showWarnings = FALSE)

cP2ALL_V2604 <- file.path(DATA_DIR, "choice", "cP2all.V2604.1y")
cP2UPDOWN_V  <- file.path(DATA_DIR, "choice", "cP2UpDown.V.s")        # also accepts .gz
POLD2PNEW    <- file.path(TRANSLATION_DIR, "Pold2Pnew.modal.s")

# Optional artifacts from the existing (V) round, used as fallbacks where
# V2604 cannot yet compute the metric (e.g., to compare the AFvAL design).
cP2ALL_V    <- file.path(DATA_DIR, "choice", "cP2all.1y")              # original
cP2PRE_POST <- file.path(DATA_DIR, "choice", "cP2pre_post.1y")         # mongo-derived

# ---------- 1. Load V2604 windows ----------
cat("Loading cP2all.V2604.1y ...\n")
V2604_COLS <- c("Pnew","firstLic","firstAdop","lastLic","lastAdop","distance",
                "firstT","lastT","oldList","flag",
                "firstNcmt","firstNfiles","firstNblobs","firstActMon",
                "lastNcmt","lastNfiles","lastNblobs","lastActMon",
                "preNcmt","preNfiles","preNblobs","preActMon")
V2604_CLASSES <- c("character","character","character","character","character",
                   "integer","numeric","numeric","character","character",
                   rep("integer", 12))
d <- read.table(cP2ALL_V2604, sep=";", header=FALSE,
                col.names=V2604_COLS, colClasses=V2604_CLASSES,
                quote="", comment.char="", fill=TRUE)
cat(sprintf("  loaded %d rows\n", nrow(d)))

# Diagnostic flag distribution
cat("\nConsolidation flag distribution:\n")
print(table(d$flag, useNA="ifany"))

# ---------- 2. Translate Pt2Ptb V edges to V2604 ----------
if (file.exists(cP2UPDOWN_V) || file.exists(paste0(cP2UPDOWN_V, ".gz"))) {
  opener <- if (file.exists(paste0(cP2UPDOWN_V, ".gz"))) gzfile else identity
  path_ud <- if (file.exists(paste0(cP2UPDOWN_V, ".gz"))) paste0(cP2UPDOWN_V, ".gz") else cP2UPDOWN_V
  cat(sprintf("\nLoading %s ...\n", path_ud))
  ud <- read.table(path_ud, sep=";", header=FALSE,
                   col.names=c("Pold","window","dir","cnt"),
                   colClasses=c("character","character","character","integer"))
  cat(sprintf("  %d (Pold, window, dir) rows\n", nrow(ud)))

  cat("Translating Pold -> Pnew via Pold2Pnew.modal.s ...\n")
  pmap <- read.table(POLD2PNEW, sep=";", header=FALSE,
                     col.names=c("Pold","Pnew"),
                     colClasses=c("character","character"))
  ud <- ud %>% left_join(pmap, by="Pold") %>% filter(!is.na(Pnew))

  # Sum counts across many->1 Pold to Pnew consolidations
  ud_agg <- ud %>% group_by(Pnew, window, dir) %>%
    summarise(cnt = sum(cnt), .groups="drop")

  # Pivot to wide: firstUpP, firstDownP, lastUpP, lastDownP, preUpP, preDownP
  ud_wide <- ud_agg %>%
    mutate(col = paste0(tolower(window), case_when(dir == "U" ~ "UpP",
                                                    dir == "D" ~ "DownP"))) %>%
    select(Pnew, col, cnt) %>%
    pivot_wider(names_from = col, values_from = cnt, values_fill = 0)

  cat(sprintf("  %d projects with at least one Up/Down edge in any window\n",
              nrow(ud_wide)))
  d <- d %>% left_join(ud_wide, by = "Pnew")
  for (cc in c("firstUpP","firstDownP","lastUpP","lastDownP","preUpP","preDownP")) {
    if (!cc %in% names(d)) d[[cc]] <- 0
    d[[cc]][is.na(d[[cc]])] <- 0
  }
} else {
  cat("\ncP2UpDown.V.s not found; Up/Down columns will be NA\n")
  for (cc in c("firstUpP","firstDownP","lastUpP","lastDownP","preUpP","preDownP")) {
    d[[cc]] <- NA_integer_
  }
}

# ---------- 3. Derive license-change direction (C2) ----------
# License type from license name -- reuse the L2TL map from the original.
L2TL <- read.table(file.path(DATA_DIR, "L2TL.s"), sep=";", header=FALSE,
                   col.names=c("L","TL"), quote="", comment.char="")
d <- d %>%
  left_join(L2TL, by=c("firstLic"="L")) %>% rename(L1Type = TL) %>%
  left_join(L2TL, by=c("lastLic"="L"))  %>% rename(L2Type = TL)

d$C2 <- ifelse(
  (d$L1Type %in% c("public-domain","permissive")) &
    (d$L2Type %in% c("copyleft","weak-copyleft","conditional-open")),
  "P2R",
  ifelse(
    (d$L1Type %in% c("copyleft","weak-copyleft","conditional-open")) &
      (d$L2Type %in% c("public-domain","permissive")),
    "R2P", "Other"))
d$C2 <- factor(d$C2)
cat("\nC2 distribution (V2604 cohort):\n"); print(table(d$C2))

# Drop the "Other" category for regression
m <- d[d$C2 != "Other", ]
m$C2 <- droplevels(m$C2)
cat(sprintf("\nRegression cohort (R2P + P2R only): %d projects\n", nrow(m)))

# ---------- 4. Language collapse (top 90% cum.) ----------
# V2604 doesn't carry Language in cP2all.V2604; pull it from the V-era cP2all.1y
# via the oldList column (use the first Pold).
if (file.exists(cP2ALL_V)) {
  v_cols <- c("ProjectID","License1","Adoption1","License2","Adoption2",
              "Distance","EarliestCommitDate","LatestCommitDate","Language",
              "NumAuthors1","NumAuthors2","NumBlobs1","NumBlobs2",
              "NumCommits1","NumCommits2","NumFiles1","NumFiles2",
              "NumActiveMon1","NumActiveMon2","UpProjects1","UpProjects2",
              "DownProjects1","DownProjects2")
  v <- read.table(cP2ALL_V, sep=";", header=FALSE, col.names=v_cols,
                  colClasses=c("character","character","character","character",
                               "character","integer","numeric","numeric",
                               "character", rep("integer",14)),
                  quote="", comment.char="")[, c("ProjectID","Language",
                                                  "EarliestCommitDate",
                                                  "LatestCommitDate")]
  m$Pold_first <- sapply(strsplit(m$oldList, ","), `[`, 1)
  m <- m %>% left_join(v, by=c("Pold_first" = "ProjectID"))
} else {
  cat("WARNING: cP2all.1y not present; Language and lifecycle dates will be NA\n")
  m$Language <- NA_character_
  m$EarliestCommitDate <- NA_real_
  m$LatestCommitDate   <- NA_real_
}

cc <- as.data.frame(table(m$Language, useNA="no"))
cc <- cc[order(-cc$Freq), ]
cc$cum_prop <- cumsum(cc$Freq) / sum(cc$Freq)
top <- as.character(cc$Var1[cc$cum_prop <= 0.9])
m$Language <- factor(ifelse(m$Language %in% top, m$Language, "other"))
m$Language <- relevel(m$Language, ref="other")

# Lifecycle control variables (months elapsed)
curT <- as.Date("2023-08-01")
m$EarliestCommit <- as.numeric(curT - as.Date(as.POSIXct(m$EarliestCommitDate,
                                                         origin="1970-01-01",
                                                         tz="UTC"))) / 30
m$LatestCommit   <- pmax(0, as.numeric(curT - as.Date(as.POSIXct(m$LatestCommitDate,
                                                                 origin="1970-01-01",
                                                                 tz="UTC"))) / 30)
m$Adoption1 <- as.Date(paste0(m$firstAdop, "-15"), format="%Y-%m-%d")
m$Adoption2 <- as.Date(paste0(m$lastAdop,  "-15"), format="%Y-%m-%d")
m$Delay     <- pmax(0, as.numeric(m$Adoption1 - as.Date(as.POSIXct(m$EarliestCommitDate,
                                                                   origin="1970-01-01",
                                                                   tz="UTC"))) / 30)
m$Distance  <- as.numeric(m$Adoption2 - m$Adoption1) / 30

# License proportion at adoption (from V-era proportions.csv)
prop_path <- file.path(DATA_DIR, "choice", "proportions.csv")
if (file.exists(prop_path)) {
  props <- read.csv(prop_path, check.names=FALSE, stringsAsFactors=FALSE) %>%
    mutate(t = as.Date(sub("-01$","-15", t)))
  pp_long <- props %>% pivot_longer(cols = -t, names_to = "LicenseType",
                                    values_to = "prop_value")
  m <- m %>% left_join(pp_long %>% rename(prop2 = prop_value),
                       by = c("Adoption2" = "t", "L2Type" = "LicenseType"))
} else {
  m$prop2 <- NA_real_
}

# ---------- 5. Compute response variables ----------
sl <- function(x) sign(x) * log1p(abs(x))

# AFvAL design (after-first vs after-last) -- 8 outcomes, V2604 for first 4,
# V (via mongo) for the remaining if cP2pre_post.1y is present; otherwise the
# Up/Down/burstiness outcomes come from V2604 directly.
m$lCommitsDif_AFvAL <- sl(m$lastNcmt)    - sl(m$firstNcmt)
m$lFilesDif_AFvAL   <- sl(m$lastNfiles)  - sl(m$firstNfiles)
m$lBlobsDif_AFvAL   <- sl(m$lastNblobs)  - sl(m$firstNblobs)
m$lActMonDif_AFvAL  <- sl(m$lastActMon)  - sl(m$firstActMon)
m$lUpProjDif_AFvAL  <- sl(m$lastUpP)     - sl(m$firstUpP)
m$lDownProjDif_AFvAL<- sl(m$lastDownP)   - sl(m$firstDownP)

# BLvAL design (year before final switch vs year after)
m$lCommitsDif_BLvAL <- sl(m$lastNcmt)    - sl(m$preNcmt)
m$lFilesDif_BLvAL   <- sl(m$lastNfiles)  - sl(m$preNfiles)
m$lBlobsDif_BLvAL   <- sl(m$lastNblobs)  - sl(m$preNblobs)
m$lActMonDif_BLvAL  <- sl(m$lastActMon)  - sl(m$preActMon)
m$lUpProjDif_BLvAL  <- sl(m$lastUpP)     - sl(m$preUpP)
m$lDownProjDif_BLvAL<- sl(m$lastDownP)   - sl(m$preDownP)

# Log-transform numeric controls
for (nm in c("Delay","Distance","EarliestCommit","LatestCommit","prop2")) {
  if (!nm %in% names(m)) next
  m[[paste0("l", nm)]] <- sl(m[[nm]])
}

# Popularity covariates: firstUpP / firstDownP (now V2604-aligned!),
# plus lifetime forks from the cP2mongo aggregates.
if (file.exists(cP2PRE_POST)) {
  pp_v <- read.table(cP2PRE_POST, sep=";", header=TRUE, stringsAsFactors=FALSE)
  pp_v <- pp_v[, c("ProjectID","NumForks")]
  m$Pold_first <- if ("Pold_first" %in% names(m)) m$Pold_first
                   else sapply(strsplit(m$oldList, ","), `[`, 1)
  m <- m %>% left_join(pp_v, by = c("Pold_first" = "ProjectID"))
  m$NumForks[is.na(m$NumForks)] <- 0
  m$lForks <- sl(m$NumForks)
} else {
  m$lForks <- 0
}
m$lFirstDownP <- sl(m$firstDownP)
m$lFirstUpP   <- sl(m$firstUpP)

# ---------- 6. Fit models ----------
fit_uni <- function(resp, dat, with_pop = TRUE) {
  rhs <- "C2 * Language + lEarliestCommit + lLatestCommit + lDelay + lDistance"
  if (!is.null(dat$lprop2) && any(!is.na(dat$lprop2))) {
    rhs <- paste(rhs, "+ lprop2")
  }
  if (with_pop) rhs <- paste(rhs, "+ lFirstDownP + lFirstUpP + lForks")
  f <- as.formula(sprintf("%s ~ %s", resp, rhs))
  lm(f, data = dat, contrasts = list(Language = contr.sum))
}

OUTCOMES_BOTH <- c("lCommitsDif", "lFilesDif", "lBlobsDif", "lActMonDif",
                   "lUpProjDif",  "lDownProjDif")
DESIGNS <- c("AFvAL", "BLvAL")

results <- list()
for (design in DESIGNS) {
  for (resp_base in OUTCOMES_BOTH) {
    nm <- paste0(resp_base, "_", design)
    if (!nm %in% names(m)) next
    fit <- fit_uni(nm, m, with_pop = TRUE)
    co  <- summary(fit)$coef
    rn  <- rownames(co)
    keep <- rn == "C2R2P" | grepl("^C2R2P:", rn)
    sub <- co[keep, , drop = FALSE]
    if (nrow(sub) == 0) next
    results[[nm]] <- data.frame(
      design = design, outcome = resp_base,
      term = rownames(sub),
      beta = sub[, 1], se = sub[, 2], pvalue = sub[, 4],
      OR = exp(sub[, 1]),
      lower = exp(sub[, 1] - 1.96 * sub[, 2]),
      upper = exp(sub[, 1] + 1.96 * sub[, 2]),
      n = nobs(fit),
      stringsAsFactors = FALSE
    )
  }
}
all_res <- do.call(rbind, results)
write.csv(all_res, file.path(OUT_DIR, "V2604_prepost.csv"), row.names = FALSE)

cat("\n=== Main R2P effect (C2R2P) per design x outcome (V2604) ===\n")
main <- all_res[all_res$term == "C2R2P", c("design","outcome","n","OR","pvalue")]
main$pvalue <- signif(main$pvalue, 3); main$OR <- round(main$OR, 3)
print(main)

cat("\n=== Significant R2P:Language interactions (p<0.05) by design ===\n")
sig <- all_res[all_res$term != "C2R2P" & all_res$pvalue < 0.05,
               c("design","outcome","term","OR","pvalue")]
sig$pvalue <- signif(sig$pvalue, 3); sig$OR <- round(sig$OR, 3)
print(sig)

# VIF on a representative fit (predictor-type)
cat("\n=== GVIF (popforks model on commits, BLvAL design) ===\n")
v <- tryCatch(vif(fit_uni("lCommitsDif_BLvAL", m, with_pop=TRUE),
                  type = "predictor"),
              error = function(e) {cat("vif error:", conditionMessage(e),"\n"); NULL})
if (!is.null(v)) print(v)

cat("\nWrote V2604_prepost.csv to:", normalizePath(OUT_DIR), "\n")
cat("Done.\n")
