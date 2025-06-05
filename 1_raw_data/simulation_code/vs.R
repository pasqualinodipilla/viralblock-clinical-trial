# Load patients dataset
dm <- read.csv("1_raw_data/simulated/dm.csv")

# Define visit days and labels
visit_days <- c(1,7,14,21,28)
visit_labels <- paste("Day", visit_days)

# Crete visit schedule
visits <- expand.grid(
  USUBJID = dm$USUBJID,
  VISITNUM = 1:length(visit_days)
)
visits$VISIT <- visit_labels[visits$VISITNUM]
visits$VSDY <- visit_days[visits$VISITNUM] #for VSDTC

# Merge patient and visit data by subject ID
vitals <- merge(visits, dm[, c("USUBJID", "ARMCD", "SEX", "AGE")], by = "USUBJID")

# Add metadata
vitals$STUDYID <- "VIRALBLOCK01"
vitals$DOMAIN <- "VS"

# Seed for reproducibility
set.seed(456)

# Simulate body temperature: higher at the beginning, improving over time
vitals_TEMP <- vitals
vitals_TEMP$VSTESTCD <- "TEMP"
vitals_TEMP$VSTEST <- "Body Temperature"
vitals_TEMP$VSORRESU <- "°C"
vitals_TEMP$VSORRES <- round(
  rnorm(nrow(vitals_TEMP),
        mean = ifelse(vitals_TEMP$ARMCD == "PBO", 38 - vitals_TEMP$VSDY * 0.03,
                                          38 - vitals_TEMP$VSDY * 0.05),
        sd = 0.3), 1)

# Simulate oxygen saturation (Sp02): improving more with Viralblock
vitals_SPO2 <- vitals
vitals_SPO2$VSTESTCD <- "SPO2"
vitals_SPO2$VSTEST <- "Oxygen Saturation"
vitals_SPO2$VSORRESU <- "%"
vitals_SPO2$VSORRES <- round(
  rnorm(nrow(vitals_SPO2),
        mean = ifelse(vitals_SPO2$ARMCD == "PBO", 94 + vitals_SPO2$VSDY * 0.05,
                      94 + vitals_SPO2$VSDY * 0.12),
        sd=1), 1)

# Combine TEMP and SPO2
vitals_final <- rbind(vitals_TEMP, vitals_SPO2)

# Create VSDTC (date, optional for SDTM conversion)
vitals_final$VSDTC <- as.Date("2023-01-01") + vitals_final$VSDY

# Save the vital signs dataset
write.csv(vitals_final, "1_raw_data/simulated/vs.csv", row.names = FALSE)