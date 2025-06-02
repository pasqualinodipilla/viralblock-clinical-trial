# Viralblock Clinical Trial Simulation

A realistic simulation of a randomized clinical trial evaluating the effectiveness of the antiviral drug **Viralblock** versus **Placebo** for a viral syndrome (e.g. COVID-like illness).

## Objectives

- Simulate a **clinical trial** with random assignment to Placebo or Viralblock
- Generate **realistic CDISC-style datasets**
- Apply statistical analysis using **R, SAS and SQL**

## Simulated Datasets

| File           | Description                                             |
|----------------|---------------------------------------------------------|
| 'patients.csv' | 300 randomized subjects (ID, age, sex, treatment group) |
| 'vitals.csv'   | Vital signs (TEMP and 02SAT) at days 1, 7, 14, 21, 28   |
| 'ae.csv'       | Adverse events: event term, day, severity, outcome, relationship to treatment |

## Adverse Events (AE) Simulation
The 'ae.csv' file simulated clinical adverse events for each subject, using:
- Terms: headache, nausea, fatigue, etc.
- Severity: MILD, MODERATE, SEVERE
- Relation to treatment: NOT RELATED, POSSIBLY RELATED, RELATED
- Outcome: RECOVERED, RECOVERING, NO RECOVERED

This data can be used to simulate SDTM AE domain and for downstream statistical summaries.

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