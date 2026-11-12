# X5 (4-panel version, updated): articles per year, actual $1m share, and how often media gave the share
# Needs `hdb` (2017-2025, with million_dollar_flag), col_main, and media_headlines.csv

media <- read_csv("media_headlines.csv", show_col_types = FALSE) %>%
  mutate(year = year(as.Date(date)))

media_year <- media %>%
  group_by(year) %>%
  summarise(
    `A. Articles in our sample` = n(),
    n_up = sum(gives_denominator), n_art = n(),
    `C. Articles giving the denominator in the headline or first paragraph` = sum(gives_denominator),
    `D. Context appears anywhere in the article (%)` = mean(context_in_body) * 100,
    .groups = "drop"
  )

actual_share <- hdb %>%
  group_by(year) %>%
  summarise(`B. Actual share of resale deals at $1m+ (%)` = mean(million_dollar_flag) * 100,
            .groups = "drop")

panel_data <- media_year %>%
  left_join(actual_share, by = "year") %>%
  pivot_longer(-c(year, n_up, n_art), names_to = "panel", values_to = "value") %>%
  mutate(panel = factor(panel, levels = c(
    "A. Articles in our sample",
    "B. Actual share of resale deals at $1m+ (%)",
    "C. Articles giving the denominator in the headline or first paragraph",
    "D. Context appears anywhere in the article (%)")),
    label = case_when(
      str_starts(panel, "A") ~ as.character(round(value)),
      str_starts(panel, "C") ~ as.character(round(value)),
      TRUE ~ as.character(round(value, 1))))

# C uses the same scale as A (number of articles), so a few articles look small next to the total;
# D keeps a 0-100% scale
scale_fix <- tibble(year = 2017,
                    panel = factor(c("C. Articles giving the denominator in the headline or first paragraph",
                                     "D. Context appears anywhere in the article (%)"),
                                   levels = levels(panel_data$panel)),
                    value = c(max(media_year$`A. Articles in our sample`), 100))

outlets <- media %>% count(outlet, sort = TRUE)

x5_four <- ggplot(panel_data, aes(factor(year), value)) +
  geom_col(fill = col_main, width = 0.7) +
  geom_text(aes(label = label), vjust = -0.3, size = 3.2) +
  geom_blank(data = scale_fix) +
  facet_wrap(~ panel, ncol = 1, scales = "free_y") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.25)),
                     breaks = function(lim) { b <- pretty(lim); b[b <= max(100, b[1])] }) +
  labs(
    title = "Few headlines gave the denominator; the context, when present, sat lower in the story",
    subtitle = paste0("Content analysis of ", nrow(media), " articles on million-dollar HDB flats, ",
                      paste(range(media$year), collapse = "-")),
    x = NULL, y = NULL,
    caption = paste0("Sources: coded articles from ",
                     paste0(outlets$outlet, " (", outlets$n, ")", collapse = ", "),
                     ";\nHDB resale transactions (data.gov.sg). Years before 2020 have fewer than 5 articles each.")
  ) +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(face = "bold", size = 13),
        plot.subtitle = element_text(colour = "grey45"),
        plot.caption = element_text(colour = "grey45", hjust = 0),
        plot.title.position = "plot", plot.caption.position = "plot",
        strip.text = element_text(face = "bold", hjust = 0, size = 10),
        panel.grid.minor = element_blank(), panel.grid.major.x = element_blank())

ggsave("X5_four_panel.png", x5_four, width = 9, height = 7.5, dpi = 200, bg = "white")
x5_four
