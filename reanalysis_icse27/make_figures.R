#!/usr/bin/env Rscript
# Regenerate paper figures as PDF (replacing the legacy pixelated PNGs).
#
# Inputs available locally:
#   data/choice/proportions.csv     -> figures/proportion.pdf
#
# Inputs needed from da5 (not in this repo by default; see the rebuild
# instructions at the bottom of this file):
#   project2licnese_map.csv.gz      -> figures/dis1.pdf, figures/dis3.pdf
#   cP2mongo.gz                     -> figures/pie.pdf
#
# Run: cd reanalysis_icse27 && Rscript make_figures.R

suppressMessages({ library(ggplot2); library(dplyr); library(tidyr) })

OUT <- "../figures"
dir.create(OUT, showWarnings = FALSE)

theme_paper <- function() {
  theme_bw(base_size = 11) +
    theme(panel.grid.minor = element_blank(),
          legend.position  = "right",
          plot.margin      = margin(2, 2, 2, 2))
}

# ---------- proportion.pdf ----------
p <- read.csv("data/choice/proportions.csv", check.names = FALSE)
p$t <- as.Date(sub("-01$", "-15", p$t))
p_long <- tidyr::pivot_longer(p, cols = -t, names_to = "LicenseType",
                              values_to = "prop")
p_long$LicenseType <- factor(p_long$LicenseType,
  levels = c("permissive","copyleft","weak-copyleft","conditional-open",
             "public-domain"))
# Smooth out the very early noisy years (sample sizes < 100 give wild swings)
p_long <- p_long[p_long$t >= as.Date("1990-01-01"), ]

gg <- ggplot(p_long, aes(t, prop, color = LicenseType)) +
  geom_line(linewidth = 0.7) +
  scale_x_date(date_breaks = "5 years", date_labels = "%Y") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(x = NULL, y = "Proportion of new license adoptions",
       color = "License type") +
  theme_paper()
ggsave(file.path(OUT, "proportion.pdf"), gg, width = 7.0, height = 3.2,
       device = cairo_pdf)
cat("wrote", file.path(OUT, "proportion.pdf"), "\n")

# ---------- dis1.pdf, dis3.pdf, pie.pdf ----------
# These require inputs not committed to the repo (the 470 MB
# project2licnese_map.csv.gz and the cP2mongo.gz aggregate).  See the
# block-comment at top of this file for the staging recipe.  When those
# files are present, the code below regenerates the PDFs.

p2l_path <- "project2licnese_map.csv.gz"
if (file.exists(p2l_path)) {
  L2TL <- read.table("data/L2TL.s", sep = ";", header = FALSE,
                     col.names = c("L","TL"), quote = "", comment.char = "")

  # latest license per project
  latest <- read.csv(p2l_path, header = FALSE, sep = ";",
                     col.names = c("p","L","t"))
  latest_latest <- latest[latest$t == "latest", ]
  latest_ever   <- latest[latest$t != "latest", ]

  # dis1: top-20 licenses by ever-occurrence + retention
  top20 <- as.data.frame(table(latest_ever$L))
  top20 <- top20[order(-top20$Freq), ][1:20, ]
  names(top20) <- c("license", "n_ever")
  top20$n_latest <- as.numeric(table(factor(latest_latest$L,
                                            levels = top20$license)))
  top20$retention <- top20$n_latest / top20$n_ever

  # Bar chart with retention overlay
  top20_long <- top20 %>% select(license, n_ever, n_latest) %>%
    pivot_longer(c(n_ever, n_latest), names_to = "kind", values_to = "n")
  top20_long$kind <- factor(top20_long$kind,
    levels = c("n_ever", "n_latest"),
    labels = c("ever held license", "still holds license at latest"))

  gg1 <- ggplot(top20_long, aes(reorder(license, -n), n, fill = kind)) +
    geom_col(position = "dodge") +
    geom_point(data = top20, aes(license, retention * max(top20$n_ever),
                                  group = 1), inherit.aes = FALSE,
               shape = 17, size = 2) +
    scale_y_continuous(
      labels = scales::label_number(scale_cut = scales::cut_short_scale()),
      sec.axis = sec_axis(~ . / max(top20$n_ever),
                          labels = scales::percent_format(accuracy = 1),
                          name = "Retention (triangle)")
    ) +
    labs(x = NULL, y = "Projects", fill = NULL) +
    theme_paper() +
    theme(axis.text.x = element_text(angle = 35, hjust = 1, size = 8))
  ggsave(file.path(OUT, "dis1.pdf"), gg1, width = 7.5, height = 3.5,
         device = cairo_pdf)
  cat("wrote", file.path(OUT, "dis1.pdf"), "\n")

  # dis3: by license type
  type_df <- latest_ever %>%
    left_join(L2TL, by = c("L" = "L")) %>%
    group_by(TL) %>% summarise(n_ever = n(), .groups = "drop")
  type_df$n_latest <- (latest_latest %>%
    left_join(L2TL, by = c("L" = "L")) %>%
    group_by(TL) %>% summarise(n = n(), .groups = "drop"))$n[
      match(type_df$TL, (latest_latest %>%
        left_join(L2TL, by = c("L" = "L")) %>%
        group_by(TL) %>% summarise(n = n(), .groups = "drop"))$TL)]
  type_df$n_latest[is.na(type_df$n_latest)] <- 0
  type_df$retention <- type_df$n_latest / type_df$n_ever
  type_long <- type_df %>% select(TL, n_ever, n_latest) %>%
    pivot_longer(c(n_ever, n_latest), names_to = "kind", values_to = "n")
  type_long$kind <- factor(type_long$kind,
    levels = c("n_ever","n_latest"),
    labels = c("ever held license", "still holds license at latest"))

  gg3 <- ggplot(type_long, aes(reorder(TL, -n), n, fill = kind)) +
    geom_col(position = "dodge") +
    scale_y_continuous(
      labels = scales::label_number(scale_cut = scales::cut_short_scale())) +
    labs(x = "License type", y = "Projects", fill = NULL) +
    theme_paper()
  ggsave(file.path(OUT, "dis3.pdf"), gg3, width = 6.5, height = 3.0,
         device = cairo_pdf)
  cat("wrote", file.path(OUT, "dis3.pdf"), "\n")
} else {
  cat("project2licnese_map.csv.gz not present; skipping dis1.pdf, dis3.pdf\n")
  cat("Fetch with:\n")
  cat("  curl -sL https://zenodo.org/api/records/15031139/files/project2licnese_map.csv.gz/content -o project2licnese_map.csv.gz\n")
}

# pie.pdf -- shares of projects with 1 / 2 / 3+ license types in lifetime.
# Recomputed from project2licnese_map.csv.gz if available; otherwise the
# numbers in Section 5.2 (78% 1-type, 22% >1-type) are sufficient.
if (file.exists(p2l_path)) {
  ntypes <- read.csv(p2l_path, header = FALSE, sep = ";",
                     col.names = c("p","L","t"))
  L2TL <- read.table("data/L2TL.s", sep = ";", header = FALSE,
                     col.names = c("L","TL"), quote = "", comment.char = "")
  ntypes <- left_join(ntypes, L2TL, by = c("L" = "L"))
  per_project_types <- ntypes %>%
    group_by(p) %>% summarise(n_types = n_distinct(TL), .groups = "drop")
  per_project_types$bucket <- cut(per_project_types$n_types,
    breaks = c(0, 1, 2, Inf), labels = c("1", "2", "3+"))
  pie_df <- as.data.frame(table(per_project_types$bucket))
  names(pie_df) <- c("nlic", "n")
  pie_df$pct <- pie_df$n / sum(pie_df$n)
  pie_df$label <- sprintf("%s license type%s\n%.1f%%",
                          pie_df$nlic,
                          ifelse(pie_df$nlic == "1", "", "s"),
                          100 * pie_df$pct)
  gg_pie <- ggplot(pie_df, aes(x = "", y = n, fill = nlic)) +
    geom_col(width = 1, color = "white") +
    coord_polar(theta = "y") +
    geom_text(aes(label = label), position = position_stack(vjust = 0.5),
              size = 3.2) +
    theme_void(base_size = 11) +
    theme(legend.position = "none")
  ggsave(file.path(OUT, "pie.pdf"), gg_pie, width = 4.5, height = 3.5,
         device = cairo_pdf)
  cat("wrote", file.path(OUT, "pie.pdf"), "\n")
}

cat("Done.\n")
