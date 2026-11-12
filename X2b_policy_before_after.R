# X2b. Policy before/after chart
# Paste after the X2 cell (needs `hdb`, `col_main`, `col_grey`, `theme_deck`, `save_slide`)

events <- tribble(
  ~date,        ~label,
  "2020-04-01", "1  Apr 2020: circuit breaker, BTO delays",
  "2021-12-01", "2  Dec 2021: LTV 90% → 85%",
  "2022-09-01", "3  Sep 2022: LTV 85% → 80%, 15-month wait",
  "2024-08-01", "4  Aug 2024: LTV 80% → 75%, higher grants",
  "2024-10-01", "5  Oct 2024: Standard / Plus / Prime"
) %>% mutate(date = as.Date(date))

# Monthly 4-room median PSM and month-on-month growth
mom <- hdb %>%
  filter(flat_type == "4 ROOM") %>%
  group_by(transaction_date) %>%
  summarise(median_psm = median(price_psm), .groups = "drop") %>%
  arrange(transaction_date) %>%
  mutate(mom_growth = median_psm / lag(median_psm) - 1)

# Average monthly growth in the 6 months before and after each event
policy_ba <- events %>%
  rowwise() %>%
  mutate(
    `6 months before` = mean(mom$mom_growth[mom$transaction_date >= date %m-% months(6) &
                                              mom$transaction_date <  date], na.rm = TRUE),
    `6 months after`  = mean(mom$mom_growth[mom$transaction_date >  date &
                                              mom$transaction_date <= date %m+% months(6)], na.rm = TRUE)
  ) %>%
  ungroup()

policy_ba   # table version

policy_long <- policy_ba %>%
  pivot_longer(c(`6 months before`, `6 months after`),
               names_to = "window", values_to = "growth") %>%
  group_by(label) %>%
  mutate(side = if_else(growth == min(growth), "left", "right")) %>%   # put each value label outside its dot
  ungroup() %>%
  mutate(window = factor(window, levels = c("6 months before", "6 months after")),
         label = factor(label, levels = rev(events$label)))

x2b <- ggplot(policy_long, aes(growth, label)) +
  geom_line(aes(group = label), colour = "grey70", linewidth = 1.2) +
  geom_point(aes(colour = window), size = 4) +
  geom_text(data = filter(policy_long, side == "left"),
            aes(label = percent(growth, accuracy = 0.01), colour = window),
            hjust = 1.35, size = 3.6, show.legend = FALSE) +
  geom_text(data = filter(policy_long, side == "right"),
            aes(label = percent(growth, accuracy = 0.01), colour = window),
            hjust = -0.35, size = 3.6, show.legend = FALSE) +
  scale_colour_manual(values = c("6 months before" = col_grey,
                                 "6 months after"  = col_main)) +
  scale_x_continuous(labels = label_percent(accuracy = 0.01),
                     breaks = c(0.0025, 0.005, 0.0075, 0.01, 0.0125),
                     limits = c(0.002, 0.0125)) +
  labs(
    title = "Price growth sped up after the 2020 supply shock and slowed after the 2022-24 measures",
    subtitle = "Average monthly change in 4-room median price per sqm, 6 months before vs after each event",
    x = "Average monthly price growth", y = NULL, colour = NULL,
    caption = "Source: HDB resale transactions (data.gov.sg); policy dates from HDB/MND announcements.\nEvents 4 and 5 are two months apart, so their windows overlap. Descriptive only: not a causal estimate."
  ) +
  theme_deck +
  theme(panel.grid.major.y = element_blank(),
        plot.title.position = "plot", plot.caption.position = "plot",
        plot.title = element_text(size = 13))

save_slide(x2b, "X2b_policy_before_after.png")
x2b
