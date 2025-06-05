# Load patients dataset
patients <- read.csv("1_raw_data/simulated/patients.csv")

# Crete all the combinations of patients and visit days
# VISITDY = visit day: 1, 7, 14, 21, 28
visits <- expand.grid(
  USUBJID = patients$USUBJID,
  VISITDY = c(1, 7, 14, 21, 28)
)

# Merge patient and visit data by subject ID
vitals <- merge(visits, patients[, c("USUBJID", "ARMCD", "AGE", "SEX")], by = "USUBJID")

# Seed for reproducibility
set.seed(456)

# Simulate body temperature: higher at the beginning, improving over time
vitals$TEMP <- rnorm(nrow(vitals),
                     mean = ifelse(vitals$ARMCD == "PBO",
                                   38 - vitals$VISITDY * 0.03,
                                   38 - vitals$VISITDY * 0.05),
                     sd = 0.3)

# Simulate oxygen saturation (Sp02): improving more with Viralblock
vitals$O2SAT <- round(rnorm(nrow(vitals),
                            mean = ifelse(vitals$ARMCD == "PBO",
                                          94 + vitals$VISITDY * 0.05,
                                          94 + vitals$VISITDY * 0.12),
                            sd = 1.0), 1)

# Save the vital signs dataset
write.csv(vitals, "1_raw_data/simulated/vitals.csv", row.names = FALSE)