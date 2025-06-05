# script goal: creating dataset with 300 simulated patients:
# ID patient, age, sex, treatment arms (Viralblock or Placebo), country etc.

# Set seed for reproducibility
set.seed(123)

# Number of patients to simulate
n <- 300

# Dataframe called "dm" with 300 rows:
# Create CDASH-like Demographics dataset
dm <- data.frame(
  STUDYID       = "VIRALBLOCK01", #study identifier
  DOMAIN        = "DM", #domain abbreviation
  USUBJID       = paste0("SUBJ", sprintf("%03d", 1:n)), # USUBJID= Unique Subject Identifier, standard CDISC (e.g. SUBJ001, SUBJ002,..)
  SEX           = sample(c("M", "F"), n, replace = TRUE), # Sex: "M" (male) o "F" (female)
  AGE           = sample(20:85, n, replace = TRUE), # Patients age: random values between 20 and 85 years old
  AGEU          = "YEARS", #Age units
  RACE          = sample(c("White", "Black", "Asian", "Other"), n, replace=TRUE), #Patient race
  COUNTRY       = sample(c("ITA", "USA", "DEU", "FRA"), n, replace = TRUE), # Patient country
  ARMCD         = sample(c("PBO", "VRB"), n, replace = TRUE), # Randomly assign treatment arms : "PBO" = placebo, "VRB" = Viralblock
  TRTSDT        = as.Date("2023-01-01") + sample(0:10,n,replace=TRUE), #start date of treatment
  TRTENDT       = NA
)

# Calculate variable dependent on armcd
dm$ARM     <- ifelse(dm$ARMCD == "VRB", "ViralBlock", "Placebo")
# Add treatment end date 28 days later (e.g. fixed duration)
dm$TRTENDT <- dm$TRTSDT + 28

# Save the simulated dataset as a csv file
write.csv(dm, "1_raw_data/simulated/dm.csv", row.names = FALSE)