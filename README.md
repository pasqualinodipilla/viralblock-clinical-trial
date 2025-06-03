# Viralblock Clinical Trial Simulation

A realistic simulation of a randomized clinical trial evaluating the effectiveness of the antiviral drug **Viralblock** versus **Placebo** for a viral syndrome (e.g. COVID-like illness).

## Objectives

- Simulate a **clinical trial** with random assignment to Placebo or Viralblock
- Generate **realistic CDISC-style datasets**
- Apply statistical analysis using **R, SAS and SQL**

## 1_raw_data/
This folder contains raw data used as input for the clinical trial simulation and future comparison with real-world data.

### Simulated Datasets (location: '1_raw_data/simulated')

| File           | Description                                             |
|----------------|---------------------------------------------------------|
| 'patients.csv' | 300 randomized subjects (ID, age, sex, treatment group) |
| 'vitals.csv'   | Vital signs (TEMP and 02SAT) at days 1, 7, 14, 21, 28   |
| 'ae.csv'       | Adverse events: event term, day, severity, outcome, relationship to treatment |

These datasets were generated to simulate clinical trial conditions. They serve as inputs for SDTM transformation and downstream statistical analysis.

---

### Adverse Events (AE) Simulation Details
The 'ae.csv' file simulated clinical adverse events for each subject, using:
- Terms: headache, nausea, fatigue, etc.
- Severity: MILD, MODERATE, SEVERE
- Relation to treatment: NOT RELATED, POSSIBLY RELATED, RELATED
- Outcome: RECOVERED, RECOVERING, NO RECOVERED

This data can be used to simulate SDTM AE domain and for downstream statistical summaries.

---

### Simulation scripts

The scripts used to generate the simulated datasets above are located in '1_raw_data/simulation_code/':
- 'simulate_patients.R'
- 'simulate_vitals.R'
- 'simulate_ae.R'

## Adverse Event Descriptive Analysis

The script 'analysis/describe_ae.R' produces:
- AE counts by treatment group
- Severity breakdown
- AE × Treatment cross-tab
- Barplot of AE terms

Output saved in 'outputs/'.

## SDTM AE derivation
The script 'generating_ae_sdtm.R' converts raw AE data into an SDTM-like structure, including:

- 'STUDYID', 'DOMAIN', 'AESEQ', 'AESER', 'AESTDTC', etc.,
- ISO-formatted date calculation,
- Derived variables based on AE severity.

Output saved in '3_sdtm_R/ae_sdtm.csv'.

## SAS replication

The script 'ae_sdtm.sas' replicated the AE SDTM derivation in SAS.
It reads the same raw datasets and produces 'ae_sdtm_sas.csv' as output.

Location:
- SAS code: '5_analysis/sas/ae_sdtm.sas',
- Output: '3_sdtm_sas/ae_sdtm_sas.csv'.

## Statistical Analyses (SAS, Pre-ADam Phase)

### 1. T-test on Oxygen Saturation (Day 28)
- **Script:** 't_test_o2sat_export.sas'
- **Location:** '5_analysis/sas/'
- **Description:** Performs a two-sample t-test comparing oxygen saturation (O2SAT) at Day 28 between treatment arms (Viralblock vs Placebo).
- **Output:**
  - Full statistical results exported to PDF and RTF, including:
  - Summary statistics
  - Confidence interval
  - Diagnostic plots (boxplots, histograms)
- **ODS Style:** 'journal'

Output files:
- [ 't_test_full_output.pdf](outputs/t_test_full_output.pdf)
- [ 't_test_full_output.rtf](outputs/t_test_full_output.rtf)

### 2. **ANCOVA - O2SAT at Day 28 Adjusted for baseline**
- **Script:** '5_analysis/sas/ancova_o2sat.sas'
- **Dataset:** Merged subset of 'vitals' for day 1 and day 28
- **Method:** 'PROC GLM'
- **Model:** 'O2SAT_28 = ARMCD + O2SAT_BL'
- **Output:** ['ancova_o2sat.pdf](../outputs/ancova_o2sat.pdf)

### 3. **Logistic regression - Serious Adverse Events (AESER)**
- **Script:** '5_analysis/sas/logistic_aeser.sas'
- **Dataset:** 'ae_sdtm'
- **Method:** 'PROC LOGISTIC'
- **Model:** 'AESER (event="Y") = ARMCD'
- **Output:** ['logistic_aeser.pdf'](../outputs/logistic_aeser.pdf)

### Outputs
All pdf results from sas procedures are saved in 'outputs' folder.

## ADaM Datasets

This section included scripts to derive  ADaM-compliant datasets for the clinical trial.
---

### 'generate_adsl.R'

- **Description**: Derives the ADSL dataset (Subject-Level Analysis Dataset).
- **Source**: '1_raw_data/simulated/vitals.csv'
- **Output**: '4_adam/advs.csv'
- **key variables**:
  - 'PARAM', 'PARAMCD': Vital signs parameter ('O2 Saturation')
  - 'AVISIT': Visit label ('Day 1', 'Day 28')
  - 'AVAL': Actual value
  - 'ANL01FL': Analysis flag (for day 1 or 28)
  
Script path: '4_ada/R/generate_advs.R'

### T-test Analysis (SAS)

This section describes the comparison of oxygen saturation (O2SAT) at **Day 28** between treatment groups using a two-sample t-test in SAS.

- **Datasets used**: 'adsl.csv', 'advs.csv'
- **Subset condition**: 'PARAMCD = "O2SAT"' and 'AVISIT = "Day 28"'
- **Procedure used**: 'PROC TTEST' on 'AVAL' by 'ARMCD'

** Script location **: '5_analysis/sas/ttest_advs.sas'
** Output files:**
- ['ttest_output.pdf'](../outputs/ttest_output.pdf)
- ['ttest_output.rtf'](../outputs/ttest_output.rtf)

** Steps performed: **
1. Imported ADaM datasets into SAS.
2. Filtered 'ADVS' to keep only O2SAT values for Day 28.
3. Merged treatment group info from 'ADSL' using 'USUBJID'.
4. Ran two-sample T-test to compare means between 'ARMCD' groups.
5. Exported output to both PDF and RTF formats via ODS.

This analysis aims to evaluate whether the treatment (ViralBlock) has a statistically significant effect on O2SAT compared to the placebo group at the end of the study.

### ANCOVA Analysis (ADaM)

This analysis evaluates the oxygen saturation (O2SAT) on **Day 28** adjusted for baseilne levels using an ANCOVA model. The data used are structured in ADaM format ('ADSL' and 'ADVS' datasets).

**Scripts:**
'5_analysis/sas/ancova_analysis_adam.sas'

**Input datasets:**
- 'adsl.csv' (subject-level data)
- advs.csv (vitals measurements in ADaM format)

**Method:**
- ANCOVA: 'O2SAT_Day_28 ~ ARMCD + O2SAT_Baseline'
- Performed using 'PROC GLM'

**Outputs:**
- 'outputs/sas/ancova_output.pdf'
- 'outputs/sas/ancova_output.rtf'

### Logistic Regression Analysis (ADaM)

This logistic regression evaluates the effect of treatment on the probability of hypoxemia, defined as oxygen saturation (O2SAT) <= 90 at **Day 28**. The analysis is based on ADaM datasets.

**Script:**
'5_analysis/sas/logistic_o2sat_day28.sas'

**Input datasets:**
- 'adsl.csv' (subject-level ADaM data)
- 'advs.csv' (vital signs ADaM data)

**Method:**
- Binary outcome: 'hypo_flag = 1' if O2SAT <= 90 at Day 28, 0 otherwise
- Logistic regression: 'hypo_flag ~ ARMCD'
- Reference group: 'Placebo (ARMCD = 'PBO')'

**Outputs:**
- 'outputs/sas/logistic_output.pdf'
- 'outputs/sas/logistic_output.rtf'

## Tools Used

- **R** - simulation and analysis
- **Git/Github** - version control
- *SAS scripts, SQL queries, analysis outputs*

## Upcoming Steps

- Simulate **adverse events** dataset ('ae.csv')
- Create **SDTM-like** clinical domains (DM, AE, VS, ...)
- Perform statistical analysis (t-test, ANCOVA, KM curves)
- Draft mock SAP and CSR elements

---

## Author

Pasqualino Di Pilla
Clinical Trial Simulation Project - 2025