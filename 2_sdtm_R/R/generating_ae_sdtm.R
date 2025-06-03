# Load necessary library
library(dplyr)

# Read AE and patient datasets
ae <- read.csv("1_raw_data/simulated/ae.csv")
patients <- read.csv("1_raw_data/simulated/patients.csv")

# Merge treatment arm into AE
ae <- merge(ae, patients[, c("USUBJID", "ARMCD")], by = "USUBJID")

# Define base study date (for ISO datetime calculation)
base_date <- as.Date("2023-01-01")

# Derive AE SDTM-like structure
ae_sdtm <- ae %>%
  group_by(USUBJID) %>%
  mutate(
    STUDYID = "VIRALBLOCK01",                           # Study ID
    DOMAIN = "AE",                                      # Domain code
    AESEQ = row_number(),                               # Sequence of AE per subject
    AEDECOD = AETERM,                                   # Simplified: decoded term=reported term
    AESER = ifelse(AESEV == "SEVERE", "Y", "N"),        # Serious AE if severe
    AESTDTC = format(base_date + AESTDY -1, "%Y-%m-%d") # ISO 8601 start date
  ) %>%
  select(
    STUDYID, DOMAIN, USUBJID, AESEQ, AETERM, AEDECOD,
    AESEV, AESER, AESTDTC, AEOUT, AEREL, ARMCD
  ) %>%
  arrange(USUBJID, AESEQ)

# Save final AE sdtm-like dataset
if (!dir.exists("3_sdtm_R")) dir.create("3_sdtm_R")
write.csv(ae_sdtm, "3_sdtm_R/ae_sdtm.csv", row.names= FALSE)
