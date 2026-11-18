# Wearable Activity Analysis (R)

> **Status:** original analysis complete; expansion in progress (see *Next steps*).

An analysis of Fitbit activity data from 33 participants to understand **when people are most active during the day** and **how daily steps relate to energy expenditure**. The project began as the Bellabeat case study in the Google Data Analytics Professional Certificate and is being expanded into a health-focused statistical analysis.

## Data
- **Source:** "FitBit Fitness Tracker Data" on Kaggle: daily and hourly activity, sleep and weight logs from 33 Fitbit users over about one month (April–May 2016)
- **Tables used:** hourly steps, intensity and calories; daily activity; sleep; weight
- How to get the data: see [`data/README.md`](data/README.md)

## What the analysis does
1. **Checks data sufficiency:** counts participants in each table
2. **Cleans:** converts text timestamps to date-times
3. **Merges:** joins hourly steps, intensity and calories by participant and hour
4. **Analyzes:** activity by hour of day, and the relationship between daily steps and calories

## Key findings
- **Peak activity is in the early evening.** Steps, intensity and calories burned peak from about 5 pm to 7 pm, suggesting most participants are active after work.
- **More steps, more calories.** Daily steps and calories burned are positively correlated.
- **Not every measure supports conclusions.** Activity data covers all 33 participants, but sleep covers 24 and weight only 8, so those were excluded from the main analysis.

## Limitations
- Small sample (33 participants) of self-selected volunteers, over about one month
- No demographic information (age, sex, health status)
- Some days likely reflect non-wear (zero steps), which can lower averages

## Next steps (in progress)
- Remove non-wear days and duplicate sleep records, and document the cleaning rules
- Use mixed-effects models (`lme4`) to account for repeated measures per participant
- Test weekday vs. weekend activity and the relationship between activity and sleep
- Publish the full analysis as a reproducible Quarto report

## How to run
```r
install.packages(c("tidyverse", "lubridate"))
```
Put the CSV files in `data/`, open the project folder in RStudio, and run `wearable_activity_analysis.R`. Charts are saved to `figures/`.

## Tools
R, tidyverse (dplyr, ggplot2), lubridate
