# Visualisation 2: share of $1m resale transactions, 2017-2025 (highlighted version)
library(tidyverse); library(scales)
# hdb <- read_csv("HDB Resale Flat Prices.csv")   # your data; needs month, resale_price

share <- hdb %>%
  mutate(year = as.integer(substr(month, 1, 4))) %>%
  filter(year >= 2017, year <= 2025) %>%
  group_by(year) %>%
  summarise(share = mean(resale_price >= 1e6), .groups = "drop")

col_main <- "#5C86AD"; col_accent <- "#D9822B"

labs_df <- share %>% filter(year %in% c(2020, 2023, 2024, 2025))

p <- ggplot(share, aes(year, share)) +
  geom_line(data = filter(share, year <= 2023), colour = col_main, linewidth = 1.2) +
  geom_line(data = filter(share, year >= 2023), colour = col_accent, linewidth = 1.6) +
  geom_point(aes(colour = year >= 2024), size = 2.6, show.legend = FALSE) +
  scale_colour_manual(values = c(`FALSE` = col_main, `TRUE` = col_accent)) +
  geom_text(data = labs_df, aes(label = ifelse(year == 2020, percent(share, accuracy = 0.01), percent(share, accuracy = 0.1)),
                                colour = year >= 2024),
            hjust = 1.25, vjust = -0.3, size = 3.6, show.legend = FALSE) +
  scale_x_continuous(breaks = 2017:2025, expand = expansion(add = c(0.3, 0.3))) +
  scale_y_continuous(labels = label_percent(accuracy = 1), limits = c(0, 0.066),
                     breaks = seq(0, 0.06, 0.02)) +
  labs(title = "Share of Million-Dollar HDB Transactions",
       subtitle = "Singapore, 2017-2025", x = NULL, y = NULL) +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(size = 14), plot.title.position = "plot",
        panel.grid.minor = element_blank(), panel.grid.major.x = element_blank(),
        plot.margin = margin(6, 10, 4, 6))

ggsave("V2_share_line.png", p, width = 5.6, height = 5.2, dpi = 220, bg = "white")
p
