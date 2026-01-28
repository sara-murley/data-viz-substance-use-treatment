# -------------------------------
# Libraries
# -------------------------------
library(tidyverse)

# -------------------------------
# Load multi-year TEDS
# -------------------------------
load("../data/tedsa_puf_2006_2023.rdata")
teds <- TEDSA_PUF_2006_2023
rm(TEDSA_PUF_2006_2023)

# -------------------------------
# Filter out missing values (-9)
# -------------------------------

teds <- teds %>%
  filter(
    !is.na(AGE),     AGE != -9,
    !is.na(SEX),     SEX != -9,
    !is.na(RACE),    RACE != -9,
    !is.na(EMPLOY),  EMPLOY != -9,
    !is.na(SUB1),    SUB1 != -9
  )

# -------------------------------
# Select relevant columns
# -------------------------------

teds <- teds %>%
  select(STFIPS, ADMYR, SUB1, AGE, SEX, RACE, EMPLOY)

# -------------------------------
# State crosswalk
# -------------------------------

stfips_crosswalk <- tribble(
  ~STFIPS, ~State,
  1, "Alabama", 2, "Alaska", 4, "Arizona", 5, "Arkansas",
  6, "California", 8, "Colorado", 9, "Connecticut", 10, "Delaware",
  11, "District of Columbia", 12, "Florida", 13, "Georgia", 15, "Hawaii",
  16, "Idaho", 17, "Illinois", 18, "Indiana", 19, "Iowa", 20, "Kansas",
  21, "Kentucky", 22, "Louisiana", 23, "Maine", 24, "Maryland",
  25, "Massachusetts", 26, "Michigan", 27, "Minnesota", 28, "Mississippi",
  29, "Missouri", 30, "Montana", 31, "Nebraska", 32, "Nevada",
  33, "New Hampshire", 34, "New Jersey", 35, "New Mexico", 36, "New York",
  37, "North Carolina", 38, "North Dakota", 39, "Ohio", 40, "Oklahoma",
  41, "Oregon", 42, "Pennsylvania", 44, "Rhode Island", 45, "South Carolina",
  46, "South Dakota", 47, "Tennessee", 48, "Texas", 49, "Utah",
  50, "Vermont", 51, "Virginia", 53, "Washington", 54, "West Virginia",
  55, "Wisconsin", 56, "Wyoming", 72, "Puerto Rico"
)

teds <- teds %>%
  left_join(stfips_crosswalk, by = "STFIPS")

# -------------------------------
# Recode SUB1
# -------------------------------

teds <- teds %>%
  mutate(
    SUB1_group = case_when(
      SUB1 == 2 ~ "Alcohol",
      SUB1 == 3 ~ "Cocaine/Crack",
      SUB1 == 4 ~ "Marijuana/Hashish",
      SUB1 %in% c(5,6,7) ~ "Opioids",
      SUB1 %in% c(10,11,12) ~ "Amphetamines",
      SUB1 %in% c(13,14,15,16) ~ "Sedatives",
      SUB1 %in% c(8,9,17,18,19) ~ "Other Drugs",
      TRUE ~ NA_character_
    )
  )

# -------------------------------
# Pre-aggregate drug counts
# -------------------------------

drug_counts <- teds %>%
  group_by(State, ADMYR, SUB1_group) %>%
  summarise(n = n(), .groups = "drop")

# -------------------------------
# Pre-aggregate demographic counts
# -------------------------------

demo_counts <- teds %>%
  group_by(State, ADMYR, SUB1_group, AGE, SEX, RACE, EMPLOY) %>%
  summarise(n = n(), .groups = "drop")


# -------------------------------
# Save processed data
# -------------------------------

saveRDS(drug_counts, "tedsa_drug_counts.rds")
saveRDS(demo_counts, "tedsa_demo_counts.rds")
