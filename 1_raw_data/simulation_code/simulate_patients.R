# script goal: creating dataset with 300 simulated patients:
# ID patient, age, sex, treatment arms (Viralblock or Placebo), country

# Set seed for reproducibility
set.seed(123)

# Number of patients to simulate
n <- 300

# Dataframe called "patients" with 300 rows
patients <- data.frame(
  # USUBJID= Unique Subject Identifier, standard CDISC (e.g. SUBJ001, SUBJ002,..)
  USUBJID = paste0("SUBJ", sprintf("%03d", 1:n)),
  # Patients age: random values between 20 and 85 years old
  AGE = sample(20:85, n, replace = TRUE),
  # Sex: "M" (maschio) o "F" (femmina), random (normal) distribution
  SEX = sample(c("M", "F"), n, replace = TRUE),
  # Randomly assign treatment arms : "PBO" = placebo, "VRB" = Viralblock
  ARMCD = sample(c("PBO", "VRB"), n, replace = TRUE),
  RACE = sample(c("White", "Black", "Asian", "Other"), n, replace=TRUE),
  # Patient country
  COUNTRY = sample(c("ITA", "USA", "DEU", "FRA"), n, replace = TRUE),
  TRTSDT = as.Date("2023-01-01") + sample(0:10,n,replace=TRUE),
  STUDYID = "VIRALBLOCK01"
)

# Add treatment end date 28 days later (e.g. fixed duration)
patients$TRTSDT <- patients$TRTSDT + 28

# Save the simulated dataset as a csv file
write.csv(patients, "1_raw_data/simulated/patients.csv", row.names = FALSE)