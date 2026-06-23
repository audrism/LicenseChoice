#!/usr/bin/env Rscript
# Regenerate paper figures as PDF (replacing the legacy pixelated PNGs).
#
# Reads pre-aggregated small CSVs produced by preagg_figures.sh (which
# scans the 470 MB Zenodo project2licnese_map.csv.gz once on da5 or
# locally if downloaded).
#
# Outputs:
#   ../figures/proportion.pdf  -- license-type adoption proportions over time
#   ../figures/dis1.pdf        -- top-20 licenses, ever vs latest + retention
#   ../figures/dis3.pdf        -- license-type counts ever vs latest
#   ../figures/pie.pdf         -- distribution of # license types per project
#
# Run: cd reanalysis_icse27 && Rscript make_figures.R

suppressMessages({ library(ggplot2); library(dplyr); library(tidyr); library(scales) })

OUT <- "../figures"
dir.create(OUT, showWarnings = FALSE)

theme_paper <- function() {
  theme_bw(base_size = 11) +
    theme(panel.grid.minor = element_blank(),
          legend.position  = "right",
          plot.margin      = margin(2, 2, 2, 2))
}

# ---------- proportion.pdf (from proportions.csv) ----------
p <- read.csv("data/choice/proportions.csv", check.names = FALSE)
p$t <- as.Date(sub("-01$", "-15", p$t))
p_long <- pivot_longer(p, cols = -t, names_to = "LicenseType", values_to = "prop")
p_long$LicenseType <- factor(p_long$LicenseType,
  levels = c("permissive","copyleft","weak-copyleft","conditional-open",
             "public-domain"))
p_long <- p_long[p_long$t >= as.Date("1990-01-01"), ]
gg <- ggplot(p_long, aes(t, prop, color = LicenseType)) +
  geom_line(linewidth = 0.7) +
  scale_x_date(date_breaks = "5 years", date_labels = "%Y") +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(x = NULL, y = "Proportion of new license adoptions",
       color = "License type") +
  theme_paper()
ggsave(file.path(OUT, "proportion.pdf"), gg, width = 7.0, height = 3.2,
       device = cairo_pdf)
cat("wrote", file.path(OUT, "proportion.pdf"), "\n")

# ---------- dis1.pdf: top-20 licenses (ever) + retention ----------
ever <- read.table("fig_top_licenses.csv", sep = ";", header = FALSE,
                   col.names = c("license", "n_ever"),
                   stringsAsFactors = FALSE)
lat <- read.table("fig_top_licenses_latest.csv", sep = ";", header = FALSE,
                  col.names = c("license", "n_latest"),
                  stringsAsFactors = FALSE)
top20 <- head(ever, 20) %>% left_join(lat, by = "license")
top20$n_latest[is.na(top20$n_latest)] <- 0
top20$retention <- top20$n_latest / top20$n_ever

# horizontal bars sorted by n_ever
top20$license <- factor(top20$license, levels = rev(top20$license))
top20_long <- top20 %>%
  select(license, n_ever, n_latest) %>%
  pivot_longer(c(n_ever, n_latest), names_to = "kind", values_to = "n")
top20_long$kind <- factor(top20_long$kind,
  levels = c("n_ever", "n_latest"),
  labels = c("ever held license", "still holds at latest"))

gg1 <- ggplot(top20_long, aes(license, n, fill = kind)) +
  geom_col(position = "dodge") +
  geom_text(data = top20, aes(license,
    n_ever, label = sprintf("%.0f%%", 100 * retention)),
    inherit.aes = FALSE, hjust = -0.1, size = 2.8, color = "black") +
  coord_flip() +
  scale_y_continuous(labels = label_number(scale_cut = cut_short_scale()),
                     expand = expansion(mult = c(0, 0.15))) +
  labs(x = NULL, y = "Projects", fill = NULL,
       caption = "Numbers on the right are retention = latest/ever.") +
  theme_paper() +
  theme(axis.text.y = element_text(size = 9))
ggsave(file.path(OUT, "dis1.pdf"), gg1, width = 7.5, height = 5.0,
       device = cairo_pdf)
cat("wrote", file.path(OUT, "dis1.pdf"), "\n")

# ---------- dis3.pdf: license-type counts ever vs latest ----------
tc_ever <- read.table("fig_type_counts_ever.csv", sep = ";", header = FALSE,
                      col.names = c("TL", "n_ever"), stringsAsFactors = FALSE)
tc_lat  <- read.table("fig_type_counts_latest.csv", sep = ";", header = FALSE,
                      col.names = c("TL", "n_latest"), stringsAsFactors = FALSE)
tc <- left_join(tc_ever, tc_lat, by = "TL")
tc$n_latest[is.na(tc$n_latest)] <- 0
tc$TL <- factor(tc$TL, levels = tc$TL[order(-tc$n_ever)])
tc$retention <- tc$n_latest / tc$n_ever
tc_long <- tc %>%
  select(TL, n_ever, n_latest) %>%
  pivot_longer(c(n_ever, n_latest), names_to = "kind", values_to = "n")
tc_long$kind <- factor(tc_long$kind,
  levels = c("n_ever","n_latest"),
  labels = c("ever held type","still holds at latest"))

gg3 <- ggplot(tc_long, aes(TL, n, fill = kind)) +
  geom_col(position = "dodge") +
  geom_text(data = tc, aes(TL, n_ever, label = sprintf("%.0f%%", 100 * retention)),
    inherit.aes = FALSE, vjust = -0.4, size = 3.0) +
  scale_y_continuous(labels = label_number(scale_cut = cut_short_scale()),
                     expand = expansion(mult = c(0, 0.15))) +
  labs(x = "License type", y = "Projects", fill = NULL,
       caption = "Numbers above bars are retention = latest/ever.") +
  theme_paper() +
  theme(axis.text.x = element_text(angle = 20, hjust = 1, size = 9))
ggsave(file.path(OUT, "dis3.pdf"), gg3, width = 6.8, height = 3.2,
       device = cairo_pdf)
cat("wrote", file.path(OUT, "dis3.pdf"), "\n")

# ---------- pie.pdf: distribution of license-type counts per project ----------
pie_df <- read.table("fig_pie_buckets.csv", sep = ";", header = FALSE,
                     col.names = c("nlic", "n"), stringsAsFactors = FALSE)
pie_df$nlic <- factor(pie_df$nlic, levels = c("1", "2", "3+"))
pie_df$pct  <- pie_df$n / sum(pie_df$n)
pie_df$label <- sprintf("%s license type%s\n%s (%.1f%%)",
                        pie_df$nlic, ifelse(pie_df$nlic == "1", "", "s"),
                        format(pie_df$n, big.mark = ","),
                        100 * pie_df$pct)

gg_pie <- ggplot(pie_df, aes(x = "", y = n, fill = nlic)) +
  geom_col(width = 1, color = "white") +
  coord_polar(theta = "y") +
  geom_text(aes(label = label), position = position_stack(vjust = 0.5),
            size = 3.2, lineheight = 0.9) +
  theme_void(base_size = 11) +
  theme(legend.position = "none")
ggsave(file.path(OUT, "pie.pdf"), gg_pie, width = 4.5, height = 3.5,
       device = cairo_pdf)
cat("wrote", file.path(OUT, "pie.pdf"), "\n")

cat("Done.\n")
