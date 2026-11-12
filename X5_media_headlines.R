# X5. Media headline analysis: two simple charts
# Needs `col_main`, `col_accent`, `col_grey`, `theme_deck`, `save_slide`; media_headlines.csv in the working folder

media <- read_csv("media_headlines.csv", show_col_types = FALSE)

# Numbers used in titles and captions, computed from the data
n_all     <- nrow(media)
n_up      <- sum(media$gives_denominator)
n_record  <- sum(media$frame == "record")
outlets   <- media %>% count(outlet, sort = TRUE)
outlet_list <- paste(outlets$outlet, collapse = ", ")
outlet_caption <- paste0(outlets$outlet, " (", outlets$n, ")", collapse = "; ")
year_range <- paste(range(year(as.Date(media$date))), collapse = "-")

# ---------- X5a. Where does the article tell readers the share? (one square = one article)
media <- media %>%
  mutate(where_share = case_when(
    gives_denominator ~ "Share given in headline or first paragraph",
    context_in_body   ~ "Share given only further down the article",
    TRUE              ~ "Share never given"
  ),
  where_share = factor(where_share, levels = c(
    "Share given in headline or first paragraph",
    "Share given only further down the article",
    "Share never given")))

counts_a <- media %>% count(where_share)
counts_a

n_cols <- 21   # squares per row
waffle <- media %>%
  arrange(where_share) %>%
  mutate(i = row_number() - 1,
         x = i %% n_cols,
         y = -(i %/% n_cols))

legend_labels <- setNames(
  paste0(counts_a$where_share, " (", counts_a$n, ")"),
  counts_a$where_share)

x5a <- ggplot(waffle, aes(x, y, fill = where_share)) +
  geom_tile(colour = "white", linewidth = 1.2, width = 0.92, height = 0.92) +
  coord_equal() +
  scale_fill_manual(values = c(
    "Share given in headline or first paragraph" = col_accent,
    "Share given only further down the article"  = "#9DB7CF",
    "Share never given"                          = col_grey),
    labels = legend_labels) +
  labs(title = paste0("Only ", n_up, " of ", n_all, " articles told readers the share up front"),
       x = NULL, y = NULL, fill = NULL) +
  theme_void(base_size = 11) +
  theme(plot.title = element_text(size = 13, margin = margin(b = 6)),
        plot.title.position = "plot",
        legend.text = element_text(size = 10),
        legend.key.size = unit(0.4, "cm"),
        plot.margin = margin(6, 6, 6, 6))

# Version 1: legend on the right (wide, short)
x5a_right <- x5a +
  guides(fill = guide_legend(ncol = 1)) +
  theme(legend.position = "right")
ggsave("X5a_where_share_legend_right.png", x5a_right, width = 8, height = 1.95, dpi = 200, bg = "white")

# Version 2: legend below (narrower)
x5a_bottom <- x5a +
  guides(fill = guide_legend(ncol = 1)) +
  theme(legend.position = "bottom", legend.justification = "left")
ggsave("X5a_where_share_legend_bottom.png", x5a_bottom, width = 6, height = 2.75, dpi = 200, bg = "white")

x5a_right

# ---------- X5b. How headlines frame the story
frame_labels <- c(
  record         = "Record-breaking",
  explainer      = "Explainer",
  market_update  = "Market-wide overview",
  contextualised = "Downplays them",
  affordability  = "Affordability concern",
  policy         = "Policy"
)

counts_b <- media %>%
  count(frame) %>%
  mutate(label = frame_labels[frame],
         label = fct_reorder(label, n),
         highlight = frame == "record")
counts_b

x5b <- ggplot(counts_b, aes(n, label, fill = highlight)) +
  geom_col(width = 0.75) +
  geom_text(aes(label = n), hjust = -0.3, size = 5) +
  geom_text(data = filter(counts_b, highlight), aes(x = 2, label = "\u201cnew high\u201d, \u201cmost expensive\u201d"),
            hjust = 0, colour = "white", size = 4.6) +   # examples written inside the bar
  # short descriptions next to the shorter bars
  geom_text(data = tibble(label = factor(c("Explainer", "Market-wide overview"), levels = levels(counts_b$label)),
                          n = c(14, 11),
                          note = c("who buys, where, why", "monthly / quarterly price reports")),
            aes(x = 21, y = label, label = note), inherit.aes = FALSE,
            hjust = 0, colour = "grey35", size = 4.6) +
  scale_fill_manual(values = c(`TRUE` = col_accent, `FALSE` = col_grey), guide = "none") +
  scale_x_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(title = paste0(percent(n_record / n_all, accuracy = 1), " of headlines (", n_record, " of ", n_all,
                      ") presented $1m flats as record-breaking"),
       x = NULL, y = NULL) +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(size = 16),
        plot.title.position = "plot",
        axis.text.y = element_text(size = 13, colour = "grey20"),
        axis.text.x = element_blank(), panel.grid = element_blank(),
        plot.margin = margin(4, 8, 2, 4))

# Compact size for slides: smaller canvas = larger text relative to the chart
ggsave("X5b_frames.png", x5b, width = 7.5, height = 2.9, dpi = 220, bg = "white")
x5b

# ---------- X5c. Over time: context became more common in the body, but not up front
by_year <- media %>%
  mutate(year = year(as.Date(date))) %>%
  group_by(year) %>%
  summarise(n = n(),
            `Share given anywhere in the article` = mean(context_in_body),
            `Share given up front (headline or first paragraph)` = mean(gives_denominator),
            .groups = "drop")
by_year

by_year_long <- by_year %>%
  pivot_longer(-c(year, n), names_to = "measure", values_to = "pct") %>%
  mutate(measure = factor(measure, levels = c("Share given anywhere in the article",
                                              "Share given up front (headline or first paragraph)")))

sparse_years <- by_year %>% filter(n < 5)   # too few articles to read as a trend

lab_end <- by_year_long %>% filter(year == max(year)) %>%
  mutate(lab = ifelse(str_detect(measure, "anywhere"), "Anywhere in article", "Up front"))

x5c <- ggplot(by_year_long, aes(year, pct, colour = measure)) +
  geom_rect(data = sparse_years, inherit.aes = FALSE,
            aes(xmin = year - 0.5, xmax = year + 0.5, ymin = -Inf, ymax = Inf),
            fill = "grey94") +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2.2) +
  geom_text(data = filter(by_year_long, str_detect(measure, "anywhere"), year >= 2020) %>%
              mutate(vj = ifelse(year %in% c(2021, 2023), 1.9, -0.9)),   # dips: label below
            aes(label = percent(pct, accuracy = 1), vjust = vj), size = 3.4, show.legend = FALSE) +
  geom_text(data = lab_end, aes(label = lab), hjust = 0, nudge_x = 0.2, size = 3.6,
            show.legend = FALSE) +
  scale_colour_manual(values = c("Share given anywhere in the article" = "#5C86AD",
                                 "Share given up front (headline or first paragraph)" = col_accent)) +
  scale_x_continuous(breaks = by_year$year,
                     labels = paste0(by_year$year, "\nn=", by_year$n),
                     expand = expansion(add = c(0.4, 2.4))) +
  scale_y_continuous(labels = label_percent(), limits = c(0, 1.05),
                     breaks = c(0, .5, 1)) +
  coord_cartesian(clip = "off") +
  labs(title = "Media added context over time, but almost never up front",
       x = NULL, y = NULL) +
  theme_deck +
  theme(plot.title.position = "plot", legend.position = "none",
        panel.grid.minor = element_blank(),
        plot.margin = margin(4, 6, 2, 4))

ggsave("X5c_context_over_time.png", x5c, width = 7.5, height = 3.2, dpi = 220, bg = "white")
x5c
