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
  n_ae <- sample(0:3, 1, prob = c(0.5, 0.3, 0.15, 0.05)) # most patients have 0-1 events
  
  if (n_ae > 0) {
    for (j in 1:n_ae) {
      ae_list[[length(ae_list)+1]] <- data.frame(
        USUBJID = patients$USUBJID[i],
        AETERM = sample(terms, 1),
        AESTDY = sample(c(1,3,7,14,21), 1),
        AESEV = sample(severity, 1, prob = c(0.6, 0.3, 0.1)),
        AEOUT = sample(outcomes, 1, prob = c(0.7, 0.2, 0.1)), 
        AEREL = sample(relations, 1, prob = if (patients$ARMCD[i] == "VIR") c(0.2, 0.3, 0.5) else c(0.4, 0.4, 0.2))
      )
    }
  }
}

# Combine all AE rows into a single data frame
ae <- bind_rows(ae_list)

# Save to csv
write.csv(ae, "1_raw_data/simulated/ae.csv", row.names = FALSE)