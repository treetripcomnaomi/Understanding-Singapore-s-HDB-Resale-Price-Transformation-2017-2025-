# X5 dashboard: the three media charts + the four-panel context, combined into one figure
# Needs `hdb` (2017-2025, with million_dollar_flag), col_main, col_accent, col_grey, theme_deck,
# and media_headlines.csv in the working folder. Uses the patchwork package.
library(patchwork)

source("X5_media_headlines.R")   # builds x5a (waffle), x5b (frames), x5c (over time) and `media`

# Panel D: articles per year (our sample) next to the actual $1m share (HDB data)
media_n <- media %>% mutate(year = year(as.Date(date))) %>% count(year, name = "value") %>%
  mutate(panel = "Articles in our sample (number)")
actual  <- hdb %>% group_by(year) %>%
  summarise(value = mean(million_dollar_flag) * 100, .groups = "drop") %>%
  mutate(panel = "Actual share of resale deals at $1m+ (%)")
d_data <- bind_rows(media_n, actual) %>%
  mutate(panel = factor(panel, levels = c("Articles in our sample (number)",
                                          "Actual share of resale deals at $1m+ (%)")),
         label = if_else(str_starts(panel, "Articles"), as.character(value),
                         as.character(round(value, 1))))

x5d <- ggplot(d_data, aes(factor(year), value)) +
  geom_col(fill = col_main, width = 0.7) +
  geom_text(aes(label = label), vjust = -0.3, size = 3) +
  facet_wrap(~ panel, nrow = 1, scales = "free_y") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.2))) +
  labs(title = "Articles in our sample vs the actual $1m share", x = NULL, y = NULL) +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(size = 13), plot.title.position = "plot",
        strip.text = element_text(hjust = 0, size = 10),
        panel.grid.minor = element_blank(), panel.grid.major.x = element_blank(),
        axis.text.x = element_text(size = 8))

# Same text size in every panel
tidy <- theme(plot.title = element_text(size = 13), plot.subtitle = element_blank(),
              plot.caption = element_blank())
pa <- x5a_bottom + tidy
pb <- x5b + theme_minimal(base_size = 11) +
  theme(plot.title = element_text(size = 13), plot.title.position = "plot",
        axis.text.x = element_blank(), panel.grid = element_blank(),
        axis.text.y = element_text(size = 10, colour = "grey20"))
pb$layers[[2]]$aes_params$size <- 3.6   # count labels
pb$layers[[3]]$aes_params$size <- 3.4   # text inside the orange bar
pb$layers[[4]]$aes_params$size <- 3.4   # notes beside the short bars
pc <- x5c + tidy

dashboard <- (pa | pb) / (pc | x5d) +
  plot_layout(heights = c(0.72, 1)) +
  plot_annotation(
    title = "Media tells only half of the story",
    subtitle = paste0("Content analysis of ", nrow(media), " articles on million-dollar HDB flats, ",
                      paste(range(year(as.Date(media$date))), collapse = "-")),
    caption = paste0("Sources: coded articles from ", outlet_caption,
                     "; HDB resale transactions (data.gov.sg). Grey years in the line chart have fewer than 5 articles."),
    tag_levels = "A",
    theme = theme(plot.title = element_text(size = 18, face = "bold"),
                  plot.subtitle = element_text(size = 12, colour = "grey40"),
                  plot.caption = element_text(size = 9, colour = "grey45", hjust = 0))
  ) &
  theme(plot.tag = element_text(face = "bold", size = 13))

ggsave("X5_dashboard.png", dashboard, width = 16, height = 8.6, dpi = 200, bg = "white")
dashboard
