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