# X4b. Years of income by household income group (SingStat deciles)
# Paste after the X4 cell (needs `hdb`, `col_main`, `col_accent`, `col_grey`, `theme_deck`, `save_slide`)

# SingStat: Average monthly household employment income (excluding employer CPF)
# among resident employed households, by decile (data.gov.sg d_a0a94216a4bb495fcd8682934ce85003)
deciles <- tribble(
  ~year, ~d5,   ~d8,   ~d9,   ~d10,
  2017,  8254, 14353, 17808, 30021,
  2018,  8412, 14556, 18416, 29192,
  2019,  8689, 15187, 18642, 29463,
  2020,  8672, 14618, 18234, 29241,
  2021,  8903, 14987, 18755, 27128,
  2022,  9321, 16096, 20237, 29547,
  2023,  9916, 17464, 21119, 30914,
  2024, 10126, 17972, 22157, 32492,
  2025, 11143, 18887, 22723, 32488
)

typical_price <- hdb %>%
  group_by(year) %>%
  summarise(median_price = median(resale_price), .groups = "drop")

years_income <- deciles %>%
  left_join(typical_price, by = "year") %>%
  transmute(
    year,
    `Typical flat, middle household (5th decile)` = median_price / (d5 * 12),
    `$1m flat, 8th-decile household`              = 1e6 / (d8 * 12),
    `$1m flat, 9th-decile household`              = 1e6 / (d9 * 12),
    `$1m flat, top-10% household (10th decile)`   = 1e6 / (d10 * 12)
  ) %>%
  pivot_longer(-year, names_to = "case", values_to = "years") %>%
  mutate(case = factor(case, levels = c(
    "$1m flat, 8th-decile household", "Typical flat, middle household (5th decile)",
    "$1m flat, 9th-decile household", "$1m flat, top-10% household (10th decile)")))

years_income %>% filter(year %in% c(2017, 2025)) %>%
  pivot_wider(names_from = year, values_from = years)

x4b <- ggplot(years_income, aes(year, years, colour = case, linetype = case)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2) +
  # end labels beside the points: 2017 on the left, 2025 on the right
  geom_text(data = filter(years_income, year == 2017),
            aes(label = sprintf("%.1f", years)), hjust = 1.4, size = 3.5, show.legend = FALSE) +
  geom_text(data = filter(years_income, year == 2025),
            aes(label = sprintf("%.1f", years)), hjust = -0.4, size = 3.5, show.legend = FALSE) +
  scale_colour_manual(values = c(
    "Typical flat, middle household (5th decile)" = "black",
    "$1m flat, 8th-decile household"              = "#E3A15F",
    "$1m flat, 9th-decile household"              = col_accent,
    "$1m flat, top-10% household (10th decile)"   = "#9C5A16")) +
  scale_linetype_manual(values = c(
    "Typical flat, middle household (5th decile)" = "dashed",
    "$1m flat, 8th-decile household"              = "solid",
    "$1m flat, 9th-decile household"              = "solid",
    "$1m flat, top-10% household (10th decile)"   = "solid")) +
  scale_x_continuous(breaks = 2017:2025, expand = expansion(add = 0.5)) +
  scale_y_continuous(limits = c(0, 7)) +
  guides(colour = guide_legend(ncol = 2), linetype = guide_legend(ncol = 2)) +
  labs(
    title = "For the top 20% of households, a $1m flat now costs about what a typical flat costs a middle household",
    subtitle = "Years of household income needed: price / (average monthly household employment income x 12)",
    x = NULL, y = "Years of household income", colour = NULL, linetype = NULL,
    caption = "Sources: HDB resale transactions (data.gov.sg); SingStat average monthly household employment income by decile,\nresident employed households, excluding employer CPF (data.gov.sg). Decile = average income within that 10% group."
  ) +
  theme_deck +
  theme(plot.title.position = "plot", plot.caption.position = "plot",
        plot.title = element_text(size = 12, face = "bold"))

save_slide(x4b, "X4b_income_deciles.png")
x4b
