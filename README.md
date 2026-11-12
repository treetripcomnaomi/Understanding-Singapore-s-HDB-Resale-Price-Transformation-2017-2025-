# Beyond the Million-Dollar Flat: Understanding Singapore's HDB Resale Price Transformation (2017–2025)

Group project (Group 1) for **NMC5344 Coding for Communicators**, National University of Singapore.

📄 **[Read the final report (PDF)](Final_Group_Report.pdf)**
💻 **[View the code and data on GitHub](https://github.com/treetripcomnaomi/Understanding-Singapore-s-HDB-Resale-Price-Transformation-2017-2025-)**

---

## Research question

Million-dollar HDB resale flats regularly make headlines in Singapore. This project asks:

> Does the rise in million-dollar transactions reflect broader price growth, or do these high-value transactions remain concentrated within particular housing segments?

## Key findings

- **Million-dollar sales grew far faster than prices.** Their share of resale transactions rose from 0.22% in 2017 to 6.35% in 2025 (1,593 sales), while the median resale price rose by about 53%.
- **Price growth was broad.** Cheaper and premium flats rose at similar rates, and our median trend closely matches HDB's official Resale Price Index (+53% vs +52%, 2017–2025).
- **Million-dollar sales were concentrated.** In 2025, five towns accounted for 59% of million-dollar sales but only 16% of all resales.
- **Both are explained by a threshold effect.** S$1 million is a fixed line, so broad growth pushes flats that were already close to it across the line first. A counterfactual applying median growth to 2017 prices produces an even larger million-dollar share (10.5%) than actually occurred (6.4%).
- **Context changes the meaning of the numbers.** After adjusting for inflation (CPI), prices rose about 29% in real terms. A typical resale flat went from about 3.8 to 4.4 years of median household income (2017–2024).
- **Media coverage rarely gave the denominator.** Of 123 news articles, 69% framed million-dollar flats as record-breaking, and only 4 gave their share of all transactions in the headline or first paragraph.

## Repository structure

```
├── report/
│   └── Final_Group_Report.pdf                          # Final report submitted for assessment
├── notebooks/
│   ├── 01_main_analysis.ipynb                          # Data cleaning, feature engineering, EDA, Model 1 (regression), Model 2 (time series)
│   ├── 02_extended_eda_benchmarks_validation.ipynb     # Extended EDA, external benchmarks, media analysis, validation models (Colab)
│   └── 02_extended_eda_benchmarks_validation.Rmd       # Same analysis as an R Markdown file (RStudio)
├── scripts/                                            # Standalone scripts for the final versions of selected charts
│                                                       # (media dashboard, policy before/after, income deciles, share line)
├── data/
│   ├── HDB Resale Flat Prices.csv                      # HDB resale transactions (data.gov.sg)
│   └── media_headlines.csv                             # Hand-built dataset of 123 news articles
└── figures/                                            # Charts exported from notebook 02
```

## How to reproduce

**Option A: Google Colab (as used in the project)**

1. Open a notebook from `notebooks/` in Google Colab (*File → Upload notebook*). The notebooks use the R runtime.
2. Upload `HDB Resale Flat Prices.csv` (and `media_headlines.csv` for notebook 02) to the Colab session's `/content/` folder.
3. Run all cells (*Runtime → Run all*). Notebook 02 saves its charts as PNG files.

**Option B: RStudio**

1. Clone or download this repository.
2. Open `notebooks/02_extended_eda_benchmarks_validation.Rmd`. Data paths are relative (`../data/...`).
3. Install the packages below if needed, then *Knit*.

**R packages:** `tidyverse`, `lubridate`, `scales`, `forecast` (notebook 01) and `patchwork` (media dashboard script).

The scripts in `scripts/` reuse objects created in notebook 02 (such as `hdb` and the chart theme), so run notebook 02's setup section first, with the data files in your working folder.

## Methods overview

| Stage | What we did | Main R tools |
|---|---|---|
| Data preparation | Restricted to Jan 2017–Dec 2025 (222,066 transactions); created flat age, storey midpoint, floor band, price per sqm, price bands and a million-dollar flag | `mutate()`, `case_when()`, `filter()` |
| Exploratory analysis | Price distribution over time, percentile growth, town concentration of million-dollar sales | `group_by()`, `summarise()`, `quantile()`, `ggplot2` |
| External benchmarks | HDB Resale Price Index, SingStat CPI and household income (median and deciles), policy event timeline | `tribble()`, `left_join()` |
| Media analysis | Content analysis of 123 articles from six outlets: headline frame and where the share is reported | `count()`, `geom_tile()` (waffle chart), `patchwork` |
| Models | Log-price regression with controls; time-series forecasting (ARIMA vs benchmarks); logistic regression for a million-dollar sale (odds ratios, Brier score vs naive baseline, AUC); counterfactual threshold simulation | `lm()`, `glm()`, `forecast`, `purrr::map_dbl()` |

## Data sources

- **HDB resale flat prices:** Housing & Development Board, via [data.gov.sg](https://data.gov.sg)
- **Resale Price Index:** Housing & Development Board
- **Consumer Price Index and household income:** Department of Statistics Singapore (SingStat)
- **News articles:** Factiva (The Straits Times, CNA) and web search (Mothership, EdgeProp, 99.co, TODAY)

## Limitations

- The data record completed transactions only, so they reflect which flats were sold as well as how prices changed.
- The policy analysis compares price growth before and after each event. It is descriptive, not causal, because interest rates and housing supply also changed.
- The logistic regression shows quasi-separation (some town and flat-type combinations never reach S$1 million), so individual coefficients should be read with caution.
- Web-searched media outlets were not sampled systematically.

## Use of generative AI

Generative AI tools (including Claude) were used to help write and debug R code, explain functions and refine writing. All outputs were reviewed and checked against the data by group members.
