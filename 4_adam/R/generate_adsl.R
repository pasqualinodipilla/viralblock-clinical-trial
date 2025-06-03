# Load packages
library(tidyverse)
library(lubridate)

#read imput data
patients <- read.csv("1_raw_data/simulated/patients.csv")

# Set treatment start date
base_date <- as.Date("2023-01-01")

# Derive ADSL
adsl <- patients %>%
  mutate(
    STUDYID = "VIRALBLOCK01",        # Study ID
    TRTSDT = base_date + sample(0:2, n(), TRUE), #Random treatment strat +- 2 days
    TRTEDT = TRTSDT + 28, #Treatment duration = 28 days
    ITTFL = "Y", #All randomized -> ITT=Y
    SAFFL = "Y", #All treated -> SAF=Y
    AGEGR1 = cut(AGE, breaks = c(0,40,60,Inf),
                 labels = c("<40", "40-60", ">60")),
    RACE = sample(c("White", "Asian", "Black", "Other"), n(), replace=TRUE)
  ) %>%
  select(STUDYID, USUBJID, SEX, AGE, AGEGR1, RACE, ARMCD, TRTSDT, TRTEDT, ITTFL, SAFFL)

# Save ADSL
write.csv(adsl, "4_adam/adsl.csv")