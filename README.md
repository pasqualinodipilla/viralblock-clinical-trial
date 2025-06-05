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
| 'dm.csv' | 300 randomized subjects (ID, age, sex, treatment group...) |
| 'vs.csv'   | Vital signs (TEMP and 02SAT) at days 1, 7, 14, 21, 28   |
| 'ae.csv'       | Adverse events: event term, day, severity, outcome, relationship to treatment ... |

These datasets were generated to simulate clinical trial conditions. They serve as inputs for SDTM transformation and downstream statistical analysis.

---

### Simulation scripts

The scripts used to generate the simulated datasets reflecting CDASH standards are located in '1_raw_data/simulation_code/':

#### 'dm.R'
  - Simulates the main patient dataset ('1_raw_data/simulated/dm.csv') with 300 participants.
    **Included Fields:**
    - 'USUBJID': Unique Subject Identifier (e.g. 'SUBJ001')
    - 'AGE': random age between 20 and 85
    - 'AGEU': age units
    - 'SEX': biological sex ('M' or 'F')
    - 'ARMCMD': treatment group ('PBO' for placebo, 'VRB' for Viralblock)
    - 'ARM': Text description of treatment group
    - 'RACE': Ethnicity ('White', 'Black', 'Asian', 'Other')
    - 'COUNTRY': country of origin
    - 'TRTSDT': Start date of treatment
    - 'TRTENDT': End date (automatically 28 days later)
    - 'STUDYID': Fixed identifier '"VIRALBLOCK01"'
    - 'DOMAIN': Domain abbreviation
    
#### 'vs.R'
  - Generates longitudinal vital signs for each patient ('1_raw_data/simulated/vs.csv', CDASH-like vital signs dataset) across visit days 1, 7, 14, 21 and 28.
  
    **Visit schedule**
    Measurements are collected on:
    - **Day 1, 7, 14, 21, 28**
    
    **Simulated variables:**
    - 'STUDYID': Study identifier (e.g. '"VIRALBLOCK01')
    - 'DOMAIN': CDASH domain code, fixed to 'VS'
    - 'USUBJID': Unique Subject ID (e.g. 'SUBJ001')
    - 'VISITNUM': Sequential visit number (1 to 5)
    - 'VISIT': Visit name (e.g., '"Day 1"', '"Day 7"', etc.)
    - 'VSDY': Study day number (aligned with visit schedule)
    - 'VSDTC': Visit date (TRTSDT + VSDY)
    - 'VSTESTCD': Vital sign short name ('TEMP', 'SPO2')
    - 'VSTEST': Vital sign full description ('Body Temperature', 'Oxygen Saturation')
    - 'VSORRES': Observed result (numeric)
    - 'VSORRESU': Unit of measure ('"°C)"' for TEMP, '%"' for SPO2)
    - 'SEX': patient sex from demographics
    - 'AGE': patient age from demographics
    - 'ARMCD': Treatment group ('PBO', 'VRB')
    
    **Simulation logic**
    - 'TEMP': Body temperature (initially higher for placebo group then decreases over time)
    - 'SO2SAT': Oxygen saturation (SpO2), improving more in 'VRB'
    
#### 'ae.R' 
  - This script simulates **Adverse Events (AEs)** for each subject based on probabilities associated with the treatment arm and AE severity. It produces a CDASH-like dataset saved as '1_raw_data/simulated/ae.csv'.

    **Included Fields:**
    - 'STUDYID': Study identifier ('VIRALBLOCK01')
    - 'DOMAIN': CDASH domain code ("AE")
    - 'USUBJID': Unique subject identifier
    - 'AETERM': Adverse event term (e.g. "Headache", "Fatigue")
    - 'AEOUT': Outcome (e.g., "RECOVERED", "RECOVERING", "NOT RECOVERED")
    - 'AEACN': Action taken ("DOSE REDUCED", "DRUG WITHDRAWN", 'NONE')
    - 'AEREL': Relationship to treatment (e.g. "RELATED", "POSSIBLY RELATED" "NOT RELATED")
    - 'AEPRESP': Was the AE present at screening? ('Y', 'N', 'UNKNOWN')
    - 'AEENRF': Is the AE ongoing or resolved? ('ONGOING', 'RESOLVED')
    - 'AESER': Serious event indicator ('Y/N')
    - 'AESEV': Severity ('MILD', 'MODERATE', 'SEVERE')
    - 'AESTDTC': Start date of the adverse event (relative to treatment start)
    - 'AEENDTC': End date of the adverse event
    - 'ARMCD': Treatment arm code ('PBO','VRB')
    - 'AESOC': System organ class (e.g. "Gastrointestinal disorders", "Skin disorders")

#### Notes:
- 'AESOC' is mapped from 'AETERM' using a predefined dictionary of 5 organ classes.
- AE start and end dates are randomized within 14 and 28 days post-treatment start.
- The simulation is fully reproducible using a fixed seed.
- Each subject from "dm.csv" can have between 0 and 3 simulated adverse events.
-The probabilities are adjusted to reflect clinical realism:
  - Events are **more severe** in 'PBO',
  - Recovery is **less likely** in 'PBO',
  - Drug-event relationship is **more likely** in 'VRB'.

## Adverse Event Descriptive Analysis

The script '5_analysis/pre_adam/r/describe_ae.R' produces:
- AE counts by treatment group
- Severity breakdown
- AE × Treatment cross-tab
- Barplot of AE terms

Output saved in 'outputs/' and '5_visualizations/ae_term_barplot.png' (see correponding sections).

---

## 2_sdtm_R: SDTM AE derivation

This folder contains the derivation of a clinical trial Adverse Events (AE) dataset structured in an SDTM-like format, implemented in both R and SAS.

### Contents

- 'R/generating_ae_sdtm.R'
  R script that derives SDTM-style AE data from the simulated raw input.
  - Generates key variables: 'STUDYID', 'DOMAIN', 'AESEQ', 'AESER', 'AESTDTC', etc.
  - Performs ISO-formatted date conversion and AE severity classification.

- 'SAS/ae_sdtm.sas'
  SAS replication of the same logic used in the R script, using the same raw datasets.
  
- 'data/'
  - 'ae_sdtm.csv': output generated by the R script.
  - 'ae_sdtm_sas.csv': Output generated by the SAS script.
  
These outputs can be used to compare R and SAS derivations and validate consistency across implementations.

---

## Statistical Analyses (SAS, Pre-ADam Phase)

This section contains standard statistical analysis conducted directly on SDTM-like datasets, before the creation of ADaM datasets.

### 1. T-test on Oxygen Saturation (Day 28)
- **Script:** 't_test_o2sat_export.sas'
- **Location:** '5_analysis/pre_adam/sas/'
- **Description:** Performs a two-sample t-test comparing oxygen saturation (O2SAT) at Day 28 between treatment arms (Viralblock vs Placebo).
- **Output:**
  - Summary statistics
  - Confidence interval
  - Diagnostic plots (boxplots, histograms)
- **Exported to**:
  - 't_test_full_output.pdf'
  - 't_test_full_output.rtf

### 2. **ANCOVA - O2SAT at Day 28 Adjusted for baseline**
- **Script:** 'ancova_o2sat.sas'
- **Location:** '5_analysis/pre_adam/sas/'
- **Dataset:** Merged subset of 'vitals' for day 1 and day 28
- **Method:** 'PROC GLM'
- **Model:** 'O2SAT_28 ~ ARMCD + O2SAT_BL'
- **Output:**
  - 'ancova_o2sat.pdf'
  - 'ancova_o2sat.rtf'

### 3. **Logistic regression - Serious Adverse Events (AESER)**
- **Script:** 'logistic_aeser.sas'
- **Location:**: '5_analysis/pre_adam/sas/'
- **Dataset:** 'ae_sdtm'
- **Method:** 'PROC LOGISTIC'
- **Model:** 'AESER (event="Y") ~ ARMCD'
- **Output:**
  - 'logistic_aeser.pdf'
  - 'logistic_aeser.rtf'
  
---

### Outputs
All output files from SAS analysis are stored in '5_analysis/pre_adam/output/'.

## ADaM Datasets

This section included scripts to derive  ADaM-compliant datasets for the clinical trial.
---

### 'generate_adsl.R'

**Description**: Derives the ADSL dataset (Subject-Level Analysis Dataset) from patient-level information
**Source**: '1_raw_data/simulated/patients.csv'
**Output**: '4_adam/data/adsl.csv'

**key variables**:
- 'STUDYID': Study identifier ("VIRALBLOCK01")
- 'USUBJID': Unique subject identifier
- 'SEX', 'AGE': Subject demographics
- 'AGEGR1': Age group category ("<40", "40-60", ">60")
- 'RACE': Race category (randomly assigned)
- 'ARMCD': Treatment group code
- 'TRTSDT': Treatment start date (randomized = 2 days)
- 'TRTEDT': Treatment end date (28 days after 'TRTSDT')
- 'ITTFL': ITT (Intent-to-Treat) flag
- 'SAFFL': Safety population flag

**Script path**: '4_adam/R/generate_adsl.R'

---

### 'generate_advs.R'

**Description**: Derives the ADVS dataset (Analysis Dataset for Vital Signs).
**Source**: '1_raw_data/simulated/vitals.csv'
**Output**: '4_adam/data/advs.csv'

**Key variables**
- 'PARAM', 'PARAMCD': Vital signs parameter (e.g., "O2 Saturation")
- 'AVISIT': Visit label (e.g., "Day 1", "Day 28")
- 'AVAL': Actual measurement value
- 'ANL01FL': Analysis flag for visits of interest (e.g., Day 1 or 28)

**Script path**: '4_adam/R/generate_advs.R'

---

## ADaM-Based Analysis

**Location:** '5_analysis/adam/'

### SAS Scripts
- 'sas/ttest_advs.sas':
  Performs a two-sample t-test comparing oxygen saturation (O2SAT) at **Day 28** using ADaM-formatted vitals and subject-level data ('advs.csv', 'adsl.csv').
  **Subset:** 'PARAMCD == "O2SAT"' and 'AVISIT == "Day 28"'
  **Output**:
  - 'output/ttest_output.pdf'
  - 'output/ttest_output.rtf'
  
- 'sas/ancova_analysis_adam.sas':
  Evaluates O2SAT at Day 28 adjusted for baseline using ADaM data.
  **Model:** 'O2SAT_Day_28 ~ ARMCD + O2SAT_Baseline'
  **Output:**
  - 'output/ancova_output.pdf'
  - 'output/ancova_output.rtf'
  
- 'sas/logistic_o2sat_day28.sas':
  Logistic regression to evaluate treatment effect on hypoxemia (O2SAT < 90%) at Day 28.
  **Outcome**: 'hypo_flag' = 1 if 'O2SAT <= 90' at Day 28
  **Output**:
  - 'output/logistic_output.pdf'
  - 'output/logistic_output.rtf'
  
---

## 5_visualizations

This section includes graphical summaries to support the interpretation of clinical trial results.

### Available plots

- 'ae_term_barplot.png':
  Barplot showing the distribution of Adverse Events (AEs) by event term and treatment group.
  Useful to visually compare frequency and severity across groups.

---
## outputs

**Folder:** 'outputs/ae_summary_tables/'

This folder contains summary tables derived from Adverse Events (AE) data. These tables support downstream reporting and visualization activities.

### Available Files

- 'ae_severity_distribution.csv':
  Summary of adverse events by severity level across all treatment groups.
- 'ae_term_by_treatment.csv':
  Frequency table of AE terms stratified by treatment group.
- 'ae_total_by_treatment.csv':
  Total number of adverse events recorded per treatment group.

---

## Tools Used

- **R** - simulation and analysis
- **Git/Github** - version control
- *SAS scripts, SQL queries, analysis outputs*

---

## Author

Pasqualino Di Pilla
Clinical Trial Simulation Project - 2025