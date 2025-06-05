# Load necessary library
library(dplyr)
# Set seed for reproducibility
set.seed(789)
# Load patient data
dm <- read.csv("1_raw_data/simulated/dm.csv")

terms <- c("Headache", "Fatigue", "Nausea", "Cough", "Fever", "Rash") # Define possible adverse events
severity <- c("MILD", "MODERATE", "SEVERE") # Define possible severity levels
outcomes <- c("RECOVERED", "RECOVERING", "NOT RECOVERED") # Define possible outcomes
relations <- c("NOT RELATED", "POSSIBLY RELATED", "RELATED") # Define possible relationships
# Mapping of AETERM (event term) to AESOC (System organ class)
aesoc_map <- list(
  "Headache" = "Nervous system disorders",
  "Fatigue" = "General disorders and administration site conditions",
  "Nausea" = "Gastrointestinal disorders",
  "Cough" = "Respiratory disorders",
  "Fever" = "General disorders and administration site conditions",
  "Rash" = "Skin and subcutaneous tissue disorders"
)

# Create empty list to store AE rows
ae_list <- list()
# Loop through each patient
for (i in 1:nrow(dm)) {
  # Randomly decide how many AEs this patient will have (0-3)
  n_ae <- sample(0:3, 1, prob = c(0.3, 0.4, 0.2, 0.1)) # increased prob for >= 1 events
  if (n_ae > 0) {
    arm <- dm$ARMCD[i]
    sev_probs <- if (arm == "PBO") c(0.4, 0.4, 0.2) else c(0.6, 0.3, 0.1) # AE severity more likely severe in placebo
    out_probs <- if (arm == "PBO") c(0.5, 0.3, 0.2) else c(0.7, 0.2, 0.1) # Outcome less likely recovered in placebo
    rel_probs <- if (arm == "VRB") c(0.2, 0.3, 0.5) else c(0.4, 0.4, 0.2) # Relation more likely for VRB
    for (j in 1:n_ae) {
      AETERM <- sample(terms, 1, replace=TRUE)
      ae_row <- data.frame(
        STUDYID = dm$STUDYID[i],
        DOMAIN = "AE",
        USUBJID = dm$USUBJID[i],
        AETERM = AETERM,
        AESEV = sample(severity, 1, prob = sev_probs, replace=TRUE),
        AESOC = aesoc_map[[AETERM]],
        AEOUT = sample(outcomes, 1, prob = out_probs, replace=TRUE),
        AEACN = sample(c("DOSE REDUCED", "DRUG WITHDRAWN", "NONE"), 1),
        AEREL = sample(relations, 1, prob=rel_probs, replace=TRUE),
        AEPRESP = sample(c("Y", "N", "UNKNOWN")),
        AEENRF = sample(c("ONGOING", "RESOLVED"), 1),
        AESER = sample(c("Y", "N"), size=1, prob=c(0.1, 0.9), replace=TRUE), #Serious AE
        AESTDTC = as.Date(dm$TRTSDT[i]) + sample(0:14,size=1), #AE start date
        AEENDTC = as.Date(dm$TRTSDT[i]) + sample(15:28,size=1),
        ARMCD = arm
      )
      ae_list[[length(ae_list)+1]] <- ae_row
    }
  }
}
# Combine all AE rows into a single data frame
ae <- bind_rows(ae_list)
# Save to csv
write.csv(ae, "1_raw_data/simulated/ae.csv", row.names = FALSE)