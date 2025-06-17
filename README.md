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

---

## Adverse Event Descriptive Analysis (ricorda di vederlo in adam)

The script '5_analysis/pre_adam/r/describe_ae.R' produces:
- AE counts by treatment group
- Severity breakdown
- AE × Treatment cross-tab
- Barplot of AE terms

Output saved in 'outputs/' and '5_visualizations/ae_term_barplot.png' (see correponding sections).

---

## `2_sdtm/` – SDTM Package for VIRALBLOCK01

This folder contains the full SDTM implementation for the mock clinical study `VIRALBLOCK01`. It includes SAS scripts, generated SDTM datasets, and validation outputs from Pinnacle 21.

### 📁 Subfolders

- `data/`  
  Contains all SDTM datasets exported in both `.csv` and `.xpt` (SAS Transport) formats.  
  Includes domains: `AE`, `DM`, `VS`, and `SUPPAE`.

- `SAS_scripts/`  
  Contains the three SAS programs used to generate the SDTM datasets:
  - `sdtm_dm.sas`
  - `sdtm_vs.sas`
  - `sdtm_ae_suppae.sas`

- `validation/`  
  Contains SDTM metadata and validation files:
  - `define.xlsx`: SDTM Define-XML source
  - `define.xml`: CDISC Define-XML for SDTM submission
  - `pinnacle21-report-sdtm.xlsx`: Output from Pinnacle 21 Community validator

### 🔍 How to Use

1. Review SAS scripts in `SAS_scripts/` to understand SDTM mapping logic.
2. Open datasets in `data/` for inspection or upload to Pinnacle 21 for validation.
3. Use `define.xml` and `define.xlsx` for regulatory submission structure or metadata inspection.
4. Check `pinnacle21-report-sdtm.xlsx` for validation results and compliance notes.

### 📋 Disclaimer

This is a mock SDTM conversion project designed for learning and portfolio purposes. No proprietary or patient data is included.

---

## `sdtm_dm.sas` – SDTM Demographics (DM) Domain Builder

This SAS script imports, processes, and exports the SDTM-compliant `DM` (Demographics) domain dataset for the clinical study `VIRALBLOCK01`.

### What It Does

- **Imports** the raw CSV file (`dm.csv`) containing subject-level data
- **Derives** SDTM variables including:
  - `USUBJID` from `SUBJID`
  - `SUBJID` from `USUBJID_OLD`
  - ISO 8601 dates for treatment and reference periods
  - Birth date from age and treatment start date
  - Actual Arm variables (`ACTARM`, `ACTARMCD`)
  - Null reason flags (`ARMNRS`, `ACTARMNRS`)
- **Formats and labels** variables per SDTM specifications
- **Exports**:
  - A `.csv` file for quick inspection
  - A `.xpt` file for submission compatibility
- **Runs a `proc freq` summary** on key categorical variables

### Output Files

- `/2_sdtm/data/dm.csv` – Final SDTM dataset in CSV format
- `/2_sdtm/data/dm.xpt` – Transport file (XPT) suitable for regulatory submission

### Notes

- Placeholder values for `SITEID`, `INVNAM`, and `ETHNIC` are inserted manually
- The `ARMNRS`/`ACTARMNRS` logic includes handling for:
  - Screen failures
  - Non-randomized subjects
  - Randomized but not treated subjects
  - Unplanned treatment arms
- The `ACTARMRS` variable is renamed to meet 8-character XPT constraints

### Requirements

- This script assumes input from a raw CSV with `USUBJID_OLD`, `AGE`, `TRTSDT`, and `TRTENDT`
- No MedDRA/terminology validation is included



## `sdtm_vs.sas` – SDTM Vital Signs (VS) Domain Builder

This SAS script processes raw vital signs data and converts it into a CDISC SDTM-compliant `VS` domain dataset for the study `VIRALBLOCK01`.

###  What It Does

- **Imports** raw CSV input (`vs.csv`) containing subject vital signs data
- **Cleans and renames** numerical variables for conversion
- **Derives** SDTM variables including:
  - `USUBJID` and `SUBJID` from `USUBJID_OLD`
  - `VSSEQ` (sequence number) by subject
  - `VSDTC` (ISO date) from numeric input
  - `VSSTRESC`, `VSSTRESN`, and `VSSTRESU` (standardized results)
  - `VSBLFL` (baseline flag) based on visit number
- **Applies labels** per SDTM conventions
- **Exports**:
  - A `.csv` file for inspection
  - A `.xpt` (SAS Transport) file for submission

###  Output Files

- `/2_sdtm/data/vs.csv` – Final VS dataset (CSV format)
- `/2_sdtm/data/vs.xpt` – SDTM-compliant XPT file

###  Notes

- Includes logic to fill `VSSTRESU` based on `VSTESTCD` (e.g., "C" for temperature, "%" for SpO2)
- Leaves optional fields (`VSSTAT`, `VSREASND`, `VSLOC`, `VSNAM`) blank
- Performs `proc freq` on key categorical variables for QC

###  Requirements

- Input CSV must include: `USUBJID_OLD`, `VSORRES`, `VSDTC`, `VSTESTCD`, etc.
- `VSORRES` and `VSDTC` are expected to be numeric for date/value parsing
- No external terminology mapping (e.g. CDISC codelists) is applied


## `sdtm_ae_suppae.sas` – SDTM Adverse Events (AE) ans SUPPAE Domain Builder

This SAS script processes raw adverse event data and generates a CDISC SDTM-compliant `AE` domain, along with its supplemental `SUPPAE` dataset, for the study `VIRALBLOCK01`.

###  What It Does

- **Imports** `ae.csv` containing raw AE data
- **Preprocesses** problematic numeric variables (`AESTDTC`, `AEENDTC`) for conversion
- **Derives** SDTM variables:
  - `USUBJID` and `SUBJID` from `USUBJID_OLD`
  - `AESTDTC` and `AEENDTC` as ISO 8601 dates
  - `AESTDY`, `AEENDY` as study days from a fixed reference (`01JAN2023`)
  - `AEONGO` flag derived from `AEENRF`
- **Assigns** sequence numbers via `AESEQ` per subject
- **Creates** a `SUPPAE` dataset:
  - Adds `AESOC` info to supplemental qualifiers using SDTM SUPP structure

###  Output Files

- `/2_sdtm/data/ae.csv` – Final AE domain in CSV format
- `/2_sdtm/data/ae.xpt` – AE domain in SAS Transport format
- `/2_sdtm/data/suppae.csv` – SUPPAE (supplemental) domain in CSV format
- `/2_sdtm/data/suppae.xpt` – SUPPAE domain in SAS Transport format

###  Notes

- Assumes `AESOC` is present in the source data for generating `SUPPAE`
- Labels are applied in accordance with SDTM IG
- Includes `proc freq` outputs for quality control of key categorical variables
- Dates and baseline are managed without external reference data

###  Requirements

- Input CSV must include: `USUBJID_OLD`, `AETERM`, `AESTDTC`, `AEENDTC`, `AESER`, etc.
- Variables `AESTDTC` and `AEENDTC` should be numeric to allow date formatting

---

# CDISC SDTM Package - Pinnacle 21  Validation Report

The goal is to demonstrate the ability to structure clinical trial data according to CDISC SDTM standards and to validate it using industry tools.
- Tool used : Pinnacle 21 Community v4.1.0
- Standards: SDTM IG 3.4 / CDISC SDTM v1.7
- Output: define.xml, .xpt domains, and Pinnacle 21 validation report

## Limitations and Known Validation Issues
This is a **non-regulatory, personal project** created without access to commercial licenses or real patient data. As such, some validation issues reported by Pinnacle 21 are expected and justificable:

### Dictionary Configuration
- **medDRA** and **SNOMED CT** were **not configured**, as they are commercial terminologies not available in the Community version of Pinnacle 21.
- Result: some checks for **Adverse Events** and **Trial Summary** were not executed.

### Missing Datasets
- Some standard SDTM datasets (e.g. 'TS', 'LB', 'SE', 'DS', 'TA', 'TE') were **not included** or **simulated**, as no real clinical trial was conducted.
- Result: presence checks triggered in Pinnacle 21.

### Codelist Violations
- A few variable values (e.g. 'AEOUT', 'AEACN', 'AEPRESP') do not match the **non-extensible CDISC Controlled Terminology**.
- Result: synthetic values were used for demonstration purposes (e.g. "RECOVERED" instead of "RECOVERING").

### Data Consistency Issues
- Some records show **duplicate or inconsistent values**, especially in Adverse Event qualifiers.
- These are artifacts of manually generated demo data and do not reflect real clinical inconsistencies.

## Justifications

All validation issues mentioned above are consistent with the scope of a training or portfolio project. This repository is not intended for regulatory submission, but rather to demonstrate:

- understanding of SDTM domains and metadata structure;
- ability to prepare datasets for validation using industry tools;
- familiarity with CSDISC compliance processes and common issues.


## Validation Summary
- Total records processed: 5,292
- Validation engine: FDA 2405.2
- Rejects: 1
- Common issues: missing datasets, non-extensible codelist violations, duplicate values

## Disclaimer 
This project is not intended for regulatory submission, but it is intended to showcase data structuring skills in SDTM format and familiarity with clinical standards and tools. All data is synthetic and does not represent real patients or studies.

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