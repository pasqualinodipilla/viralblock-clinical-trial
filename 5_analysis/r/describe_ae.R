# Load libraries
library(dplyr)
library(ggplot2)

#Load AE data and patient treatment info
ae <- read.csv("1_raw_data/simulated/ae.csv")
patients <- read.csv("1_raw_data/simulated/patients.csv")

#Merge treatment arm into AE data
ae <- merge(ae, patients[, c("USUBJID", "ARMCD")], by = "USUBJID")

# 1. Total number of AE by treatment arm
table_total <- ae %>%
  group_by(ARMCD) %>%
  summarise(total_ae = n())

print("Total AE by treatment arm:")
print(table_total)

# 2. AE severity distribution
table_sev <- ae %>%
  group_by(AESEV) %>%
  summarise(n=n()) %>%
  mutate(percentage = round(n / sum(n) * 100, 1))

print("AE severity distribution:")
print(table_sev)

# 3. AE term by treatment (cross-tab)
table_term_treatment <- table(ae$AETERM, ae$ARMCD)
print("AE term by treatment arm:")
print(table_term_treatment)

# 4. Barplot of most frequent AE terms
ggplot(ae, aes(x=AETERM)) +
  geom_bar(fill = "steelblue") +
  labs(title = "Most common adverse events", x = "Adverse Event", y = "Count") + 
  theme_minimal()

# Save summary tables as csv
write.csv(table_total, "outputs/ae_total_by_treatment.csv", row.names = FALSE)
write.csv(table_sev, "outputs/ae_severity_distribution.csv", row.names = FALSE)
write.csv(as.data.frame.matrix(table_term_treatment), "outputs/ae_term_by_treatment.csv")

# Save barplot as png
ggsave("outputs/ae_term_barplot.png", width = 7, height = 5)