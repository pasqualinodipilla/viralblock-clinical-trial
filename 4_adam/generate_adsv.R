# Load packages
library(tidyverse)
library(lubridate)

#Load source vitals data
vitals <- read.csv("1_raw_data/simulated/vitals.csv")

#Derive ADVS
advs <- vitals %>%
  mutate(
    STUDYID = "VIRALBLOCK01",
    PARAMCD = "O2SAT",
    PARAM = "O2 Saturation (%)",
    AVISIT = paste("Day", VISITDY),
    AVAL = O2SAT,
    ANL01FL = ifelse(VISITDY %in% c(1,28), "Y", NA_character_)
  ) %>%
  select(STUDYID, USUBJID, VISITDY, AVISIT, PARAM, PARAMCD, AVAL, ANL01FL)

# Save as ADaM dataset
write.csv(advs, "4_adam/advs.csv")