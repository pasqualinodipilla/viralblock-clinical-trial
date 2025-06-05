# Load necessary library
library(dplyr)

# Set seed for reproducibility
set.seed(789)

# Load patient data
patients <- read.csv("1_raw_data/simulated/patients.csv")

# Define possible adverse events
terms <- c("Headache", "Fatigue", "Nausea", "Cough", "Fever")

# Define possible severity levels
severity <- c("MILD", "MODERATE", "SEVERE")

# Define possible outcomes
outcomes <- c("RECOVERED", "RECOVERING", "NOT RECOVERED")

# Define possible relationships
relations <- c("NOT RELATED", "POSSIBLY RELATED", "RELATED")


# Create empty list to store AE rows
ae_list <- list()

# Loop through each patient
for (i in 1:nrow(patients)) {
  # Randomly decide how many AEs this patient will have (0-3)
  n_ae <- sample(0:3, 1, prob = c(0.3, 0.4, 0.2, 0.1)) # increased prob for >= 1 events

  if (n_ae > 0) {
    arm <- patients$ARMCD[i]
    
    # AE severity more likely severe in placebo
    sev_probs <- if (arm == "PBO") c(0.4, 0.4, 0.2) else c(0.6, 0.3, 0.1)
    # Outcome less likely recovered in placebo
    out_probs <- if (arm == "PBO") c(0.5, 0.3, 0.2) else c(0.7, 0.2, 0.1)
    # Relation more likely for VRB
    rel_probs <- if (arm == "VRB") c(0.2, 0.3, 0.5) else c(0.4, 0.4, 0.2)
    
    
    for (j in 1:n_ae) {
    
      ae_row <- data.frame(
        USUBJID = patients$USUBJID[i],
        AETERM = sample(terms, 1, replace=TRUE),
        AESEV = sample(severity, 1, prob = sev_probs, replace=TRUE),
        AESOC = "General disorders", # optional for categorization
        AEOUT = sample(outcomes, 1, prob = out_probs, replace=TRUE),
        AEREL = sample(relations, 1, prob=rel_probs, replace=TRUE),
        AESER = sample(c("Y", "N"), 1, prob=c(0.1, 0.9), replace=TRUE), #Serious AE
        ARMCD = arm, 
        STUDYID = patients$STUDYID[i]
      )
      ae_list[[length(ae_list)+1]] <- ae_row
    }
  }
}

# Combine all AE rows into a single data frame
ae <- bind_rows(ae_list)

# Save to csv
write.csv(ae, "1_raw_data/simulated/ae.csv", row.names = FALSE)