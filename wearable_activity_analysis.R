# =====================================================================
# Wearable Activity Analysis
# Original analysis (2023) of Fitbit activity data from 33 participants.
# Data: "FitBit Fitness Tracker Data" on Kaggle (see data/README.md).
#
# Setup (run once):
#   install.packages(c("tidyverse", "lubridate"))
# Then put the CSV files in the data/ folder and run this script from
# the project folder.
# =====================================================================

library(tidyverse)
library(lubridate)

data_dir <- "data"
dir.create("figures", showWarnings = FALSE)

# ---- Load data ------------------------------------------------------
calories_hrly  <- read.csv(file.path(data_dir, "hourlyCalories_merged.csv"))
intensity_hrly <- read.csv(file.path(data_dir, "hourlyIntensities_merged.csv"))
steps_hrly     <- read.csv(file.path(data_dir, "hourlySteps_merged.csv"))
sleep_daily    <- read.csv(file.path(data_dir, "sleepDay_merged.csv"))
activity_daily <- read.csv(file.path(data_dir, "dailyActivity_merged.csv"))
weight         <- read.csv(file.path(data_dir, "weightLogInfo_merged.csv"))

# ---- 1. Data sufficiency: how many participants are in each table? --
id_counts <- tibble(
  table = c("hourly calories", "hourly intensity", "hourly steps",
            "daily sleep", "daily activity", "weight log"),
  participants = c(n_distinct(calories_hrly$Id), n_distinct(intensity_hrly$Id),
                   n_distinct(steps_hrly$Id), n_distinct(sleep_daily$Id),
                   n_distinct(activity_daily$Id), n_distinct(weight$Id))
)
print(id_counts)
# Activity, steps, intensity and calories cover all 33 participants.
# Sleep (24) and weight (8) cover too few participants for reliable
# conclusions, so they are excluded from the main analysis.

# ---- 2. Clean: convert text timestamps to date-times -----------------
to_datetime <- function(x) as.POSIXct(x, format = "%m/%d/%Y %I:%M:%S %p", tz = "UTC")

calories_hrly  <- calories_hrly  %>% mutate(ActivityHour = to_datetime(ActivityHour))
intensity_hrly <- intensity_hrly %>% mutate(ActivityHour = to_datetime(ActivityHour))
steps_hrly     <- steps_hrly     %>% mutate(ActivityHour = to_datetime(ActivityHour))

# ---- 3. Merge hourly steps, intensity and calories -------------------
hourly <- steps_hrly %>%
  inner_join(intensity_hrly, by = c("Id", "ActivityHour")) %>%
  inner_join(calories_hrly,  by = c("Id", "ActivityHour")) %>%
  mutate(Hour = hour(ActivityHour),
         Day  = as_date(ActivityHour))

# Days of data contributed by each participant
days_per_user <- hourly %>%
  group_by(Id) %>%
  summarise(total_days = n_distinct(Day))

ggplot(days_per_user, aes(x = total_days)) +
  geom_histogram(binwidth = 1) +
  labs(title = "Days of data per participant",
       x = "Days with hourly data", y = "Participants")
ggsave("figures/days_per_participant.png", width = 7, height = 4)

# ---- 4. Activity by hour of day --------------------------------------
hourly_avg <- hourly %>%
  group_by(Hour) %>%
  summarise(mean_steps     = mean(StepTotal),
            mean_calories  = mean(Calories),
            mean_intensity = mean(TotalIntensity))

ggplot(hourly_avg, aes(x = Hour, y = mean_steps)) +
  geom_line() + geom_point() +
  scale_x_continuous(breaks = seq(0, 23, 2)) +
  labs(title = "Average steps by hour of day",
       x = "Hour of day (0 = midnight)", y = "Average steps per hour")
ggsave("figures/steps_by_hour.png", width = 7, height = 4)

ggplot(hourly_avg, aes(x = Hour, y = mean_intensity)) +
  geom_line() + geom_point() +
  scale_x_continuous(breaks = seq(0, 23, 2)) +
  labs(title = "Average activity intensity by hour of day",
       x = "Hour of day (0 = midnight)", y = "Average total intensity")
ggsave("figures/intensity_by_hour.png", width = 7, height = 4)
# Finding: activity, intensity and calories burned peak from about
# 5 pm to 7 pm, suggesting most participants are active after work.

# ---- 5. Steps vs. calories --------------------------------------------
daily <- hourly %>%
  group_by(Id, Day) %>%
  summarise(daily_steps    = sum(StepTotal),
            daily_calories = sum(Calories),
            .groups = "drop")

ggplot(daily, aes(x = daily_steps, y = daily_calories)) +
  geom_point(alpha = 0.4) +
  geom_smooth(method = "lm") +
  labs(title = "Daily steps vs. calories burned",
       x = "Daily steps", y = "Daily calories")
ggsave("figures/steps_vs_calories.png", width = 7, height = 4)

cor(daily$daily_steps, daily$daily_calories)
# Finding: more daily steps go with more calories burned
# (positive correlation).
