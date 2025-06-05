# Load necessary packages
library(survival)
library(survminer)
library(dplyr)
library(readr)
library(broom)
library(coxphf)

# Load data
adsl <- read.csv("4_adam/data/adsl.csv")
advs <- read.csv("4_adam/data/advs.csv")

# Prepare dataset
adv28 <- advs %>%
  filter(AVISIT == "Day 28", !is.na(AVAL)) %>%
  mutate(hypox_event = ifelse(AVAL <= 96, 1, 0))

df_surv <- adsl %>%
  select(USUBJID, AGE, SEX, ARMCD, TRTEDT) %>%
  inner_join(adv28 %>% select(USUBJID, hypox_event), by = "USUBJID") %>%
  mutate(time=28)

df_surv$ARMCD <- factor(df_surv$ARMCD)
df_surv$SEX <- factor(df_surv$SEX)

# Kaplan-Meier fit
fit_km <- survfit(Surv(time, hypox_event) ~ ARMCD, data=df_surv)

# Save Kaplan-Meier plot
pdf("5_analysis/adam/output/Survival-Analysis/kaplan_meier_plot.pdf", width=7, height=5)
print(ggsurvplot(
  fit_km,
  data = df_surv,
  pval = TRUE,
  risk.table = TRUE,
  surv.median.line = "hv",
  legend.title = "Treatment",
  legend.labs = levels(df_surv$ARMCD),
  xlab = "Days",
  ylab = "Survival Probability",
  title = "Kaplan-Meier Curve by Treatment Group"
))
dev.off()

# Log-rank test
logrank_test <- survdiff(Surv(time, hypox_event) ~ ARMCD, data=df_surv)

# Save log-rank result as CSV
logrank_result <- data.frame(
  chisq = logrank_test$chisq,
  df = length(logrank_test$n)-1,
  p_value = 1-pchisq(logrank_test$chisq, length(logrank_test$n)-1)
)
write.csv(logrank_result, "5_analysis/adam/output/Survival-Analysis/logrank_test.csv", row.names=FALSE)

# Fit cox regression model with Firth correction
cox_firth <- coxphf(Surv(time, hypox_event) ~ ARMCD + AGE + SEX, data = df_surv)

# Visualize model summary
summary(cox_firth)

# Save as csv
cox_firth_result <- data.frame(
  Variable = names(cox_firth$coefficients),
  HR = exp(cox_firth$coefficients),
  CI_lower = exp(cox_firth$ci.lower),
  CI_upper = exp(cox_firth$ci.upper),
  p_value = summary(cox_firth)$prob
)

write.csv(cox_firth_result, "5_analysis/adam/output/Survival-Analysis/cox_firth_summary.csv",
          row.names = FALSE)

# Manual forest plot
ggplot(cox_firth_result, aes(x=HR, y= Variable)) + 
  geom_point() +
  geom_errorbarh(aes(xmin = CI_lower, xmax = CI_upper), height = 0.2) +
  geom_vline(xintercept = 1, linetype = "dashed") +
  scale_x_log10() +
  theme_minimal() +
  labs(
    title = "Hazard Ratios (Cox Model with Firth correction)",
    x = "Hazard Ratio (log scale)",
    y = ""
  )

# save plot as pdf
ggsave("5_analysis/adam/output/Survival-Analysis/cox_firth_forest_plot.pdf", width=7, height = 5)