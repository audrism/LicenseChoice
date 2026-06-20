#!/usr/bin/env Rscript
# Examine multicollinearity among popularity proxies before deciding which
# to include in the regression.

suppressMessages({ library(dplyr); library(car) })

DATA_DIR <- "data"
names1 <- c("ProjectID","License1","Adoption1","License2","Adoption2",
            "Distance","EarliestCommitDate","LatestCommitDate","Language",
            "NumAuthors1","NumAuthors2","NumBlobs1","NumBlobs2",
            "NumCommits1","NumCommits2","NumFiles1","NumFiles2",
            "NumActiveMon1","NumActiveMon2","UpProjects1","UpProjects2",
            "DownProjects1","DownProjects2")
classes1 <- c("character","character","character","character","character",
              "integer","numeric","numeric","character", rep("integer",14))

d <- read.table(file.path(DATA_DIR,"choice","cP2all.1y"),
                sep=";", header=FALSE, col.names=names1,
                colClasses=classes1, quote="", comment.char="")

# pre/post with forks etc.
pp <- read.table(file.path(DATA_DIR,"choice","cP2pre_post.1y"),
                 sep=";", header=TRUE, stringsAsFactors=FALSE)

m <- merge(d, pp, by="ProjectID")

sl <- function(x) sign(x) * log1p(abs(x))

prox <- data.frame(
  Forks       = sl(m$NumForks),
  Community   = sl(m$CommunitySize),
  Core        = sl(m$NumCore),
  DownProj1   = sl(m$DownProjects1),
  UpProj1     = sl(m$UpProjects1),
  Authors1    = sl(m$NumAuthors1),
  Commits1    = sl(m$NumCommits1),
  Blobs1      = sl(m$NumBlobs1)
)

cat("\n=== Spearman correlations among candidate popularity proxies ===\n")
print(round(cor(prox, method = "spearman"), 2))

cat("\n=== Pearson correlations (on signed-log scale) ===\n")
print(round(cor(prox, method = "pearson"), 2))

# Median/quartiles to see effective range
cat("\n=== Distribution of popularity proxies (raw) ===\n")
for (v in c("NumForks","CommunitySize","NumCore","DownProjects1","UpProjects1")) {
  x <- m[[v]]
  cat(sprintf("%-20s  min=%d  p25=%g  median=%g  mean=%.2f  p95=%g  max=%d\n",
              v, min(x), quantile(x,.25), median(x), mean(x),
              quantile(x,.95), max(x)))
}

# Compute VIF on a *predictor-only* model (no response, no factors needed)
# for the candidate covariate set we propose to use together.
cat("\n=== VIF for candidate covariate sets in a dummy regression ===\n")

dummy_y <- m$NumAuthors2  # any numeric will do
df <- data.frame(
  y = dummy_y,
  lFirstDownP = sl(m$DownProjects1),
  lFirstUpP   = sl(m$UpProjects1),
  lForks      = sl(m$NumForks),
  lCommunity  = sl(m$CommunitySize),
  lCore       = sl(m$NumCore))

cat("\n-- Model A: DownP + UpP only (current paper specification)\n")
print(round(vif(lm(y ~ lFirstDownP + lFirstUpP, data=df)), 2))

cat("\n-- Model B: DownP + UpP + Forks\n")
print(round(vif(lm(y ~ lFirstDownP + lFirstUpP + lForks, data=df)), 2))

cat("\n-- Model C: DownP + UpP + Forks + CommunitySize\n")
print(round(vif(lm(y ~ lFirstDownP + lFirstUpP + lForks + lCommunity, data=df)), 2))

cat("\n-- Model D: DownP + UpP + Forks + CommunitySize + NumCore\n")
print(round(vif(lm(y ~ lFirstDownP + lFirstUpP + lForks + lCommunity + lCore, data=df)), 2))

cat("\n-- Model E: Forks only (drop DownP/UpP)\n")
print(round(vif(lm(y ~ lForks + lCommunity, data=df)), 2))

# PCA to see effective dimensionality
cat("\n=== PCA of the 5 popularity proxies (signed-log) ===\n")
pca <- prcomp(prox[, c("Forks","Community","Core","DownProj1","UpProj1")],
              scale. = TRUE)
print(summary(pca))
cat("Loadings (first 3 PCs):\n")
print(round(pca$rotation[, 1:3], 2))
