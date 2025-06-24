# Viralblock Clinical Trial Simulation

A realistic simulation of a randomized clinical trial evaluating the effectiveness of the antiviral drug **Viralblock** versus **Placebo** for a viral syndrome (e.g. COVID-like illness).

## Objectives

- Simulate a **clinical trial** with random assignment to Placebo or Viralblock
- Generate **realistic CDISC-style datasets**
- Apply statistical analysis using **R and SAS**

## 1_raw_data/
This folder contains raw data used as input for the clinical trial simulation.

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

## `2_sdtm/` – SDTM Package for VIRALBLOCK01

This folder contains the full SDTM implementation for the mock clinical study `VIRALBLOCK01`. It includes SAS scripts, generated SDTM datasets, and validation outputs from Pinnacle 21.

###  Subfolders

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

###  Disclaimer

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
## Dataset: ADSL (Subject-Level Analysis Dataset)

### 📜 Purpose
Builds the master subject-level ADaM dataset from SDTM Demographics (`DM`).

### 📥 Inputs
| File    | Location         | Role                                  |
|---------|------------------|---------------------------------------|
| `dm.csv`| `2_sdtm/data/`   | Demographics source (SDTM-style CSV)  |

### ⚙️ Key Steps
1. **Date conversion** – transforms ISO-8601 text dates (`TRTSDTC`, `TRTENDTC`, `BRTHDTC`) into numeric SAS dates (`TRTSDT`, `TRTEDT`, `BRTHDT`).  
2. **Population flags** – derives  
   * `SAFFL = "Y"` if `TRTSDT` exists (safety population)  
   * `ITTFL = "Y"`, `EFFFL = "Y"` for every subject (simplified rule).  
3. **Variable ordering** – reorders variables to standard ADaM ADSL layout.  
4. **XPT compatibility** – renames `ACTARMNRS` → `ACTARMRS` before export.

### 🧾 Outputs
| File        | Location        | Format |
|-------------|-----------------|--------|
| `adsl.csv`  | `3_adam/data/`  | CSV    |
| `adsl.xpt`  | `3_adam/data/`  | XPT    |

### 📎 Notes
* Flags are intentionally simplified for demonstration; real studies should derive populations per protocol.  
* All data are **synthetic** – no real patient information is included.


## Dataset: ADVS (Vital Signs)

### 📜 Description
This script creates the `ADVS` (Analysis Dataset for Vital Signs) by merging SDTM-like `VS` data with treatment assignments from `ADSL`. It prepares a structured ADaM-compliant dataset ready for statistical analysis.

### 📥 Input
- `vs.csv` — Vital Signs dataset (SDTM-like), located in `2_sdtm/data/`
- `adsl.csv` — Subject-level data for treatment arm info

### ⚙️ Key Processing Steps
- Merges `VS` with `ADSL` to bring in `TRTA` (actual treatment arm)
- Derives key ADaM variables:
  - `PARAMCD` / `PARAM` from `VSTESTCD` / `VSTEST`
  - `AVAL` / `AVALC` from standard result fields
  - `ABLFL` (baseline flag) from `VSBLFL`
  - `AVISIT`, `AVISITN` from visit info
  - `ADT` as formatted analysis date from `VSDTC`
- Applies CDISC-compliant labeling and variable order

### 🧾 Output
- `advs.csv` → saved to `3_adam/data/`
- `advs.xpt` → saved to `3_adam/data/`

### 📎 Notes
- Assumes `VSDTC` is in `YYYY-MM-D


## Dataset: ADAE (Adverse Events)

### 📜 Description
This script creates the `ADAE` (Analysis Adverse Events) dataset from a raw AE CSV file. It simulates an SDTM-like structure before deriving the analysis-ready dataset.

### 📥 Input
- `ae.csv` — located in `2_sdtm/data/`
- Simulated reference start date: `01JAN2023` (hardcoded for AESTDY/AEENDY calculation)

### ⚙️ Key Processing Steps
- Renames problematic numeric date variables to avoid conflicts
- Creates SDTM-style AE dataset (`ae_sdtm`) with:
  - Derived variables: `AESTDTC`, `AEENDTC` (ISO format), `AESTDY`, `AEENDY`
  - `AEONGO` flag derived from `AEENRF`
  - Proper formatting and labeling
- Generates `AESEQ` per subject and sorts events chronologically
- Reorders variables to match CDISC SDTM specifications

### 🧾 Output
- `ae.csv` → saved to `3_adam/data/`
- `ae.xpt` → saved to `3_adam/data/`
- Frequency tables (not exported)

### 📎 Notes
- `AESOC` is not part of the main ADAE dataset but extracted separately into SUPPAE
- The dataset is simulated and not based on real MedDRA-coded terms

## Dataset: SUPPAE (Supplemental Qualifiers for ADAE)

### 📜 Description
This script generates `SUPPAE`, a supplemental qualifiers dataset for `ADAE`, using the `AESOC` field (System Organ Class) if available.

### 📥 Input
- Derived from the `ae_final` dataset created during ADAE construction
- Assumes `AESOC` is present in the original raw AE data

### ⚙️ Key Processing Steps
- Constructs SUPP domain fields: `QNAM`, `QLABEL`, `QVAL` for `AESOC`
- Links each record to `ADAE` using `USUBJID` + `AESEQ`
- Retains only supplemental records with non-missing `AESOC`

### 🧾 Output
- `suppae.csv` → saved to `3_adam/data/`
- `suppae.xpt` → saved to `3_adam/data/`
- Frequency count of `QVAL` for `AESOC`

### 📎 Notes
- This dataset is required to maintain standard traceability for supplemental terms not included in the core `ADAE`
- Used for structured representation of MedDRA SOC if available

---
## 🧪 Pinnacle 21 Validation Summary (ADaM Datasets)

This project includes a simulated ADaM package created for educational and portfolio purposes. The datasets were validated using **Pinnacle 21 Community**, configured for **ADaM-IG 1.3 (FDA)**.

### ✅ Validation Results

- All `.xpt` datasets were successfully processed with **no rejections**.
- The following ADaM domains were included:
  - `ADSL` (Subject-Level Analysis Dataset)
  - `ADAE` (Adverse Events Dataset)
  - `ADVS` (Vital Signs Dataset)
  - `SUPPAE` (Supplemental Qualifiers for ADAE)

### ⚠️ Known Issues (Expected in a Simulated Context)

| Issue Category      | Description                                                                                         | Acceptable in Simulated Data? |
|---------------------|-----------------------------------------------------------------------------------------------------|-------------------------------|
| **Missing Traceability Checks** | Warnings about missing SDTM datasets (e.g., `DM`, `AE`, `EX`) prevent traceability rules from executing. | ✅ Yes — SDTM is not included in this project.part |
| **Controlled Terminology (CT) Errors** | Terms such as `AESER`, `AERESP`, `RACE` are not mapped to CDISC extensible codelists (e.g., MedDRA). | ✅ Yes — MedDRA is proprietary and not used in simulated datasets. |
| **Missing Required Variables** | Some required ADaM variables (e.g., `AEHLT`, `AEPTCD`, `AETOXGR`) are not present.                            | ✅ Yes — Dataset scope is limited for simplicity. |
| **Variable Label/Type Mismatches** | Minor mismatches between dataset variable names/types and ADaM-IG expectations.                           | ✅ Yes — Not impactful for the demo objective. |
| **Length Warnings** | Variable length exceeds observed value length (e.g., `length too long for actual data`).           | ✅ Yes — Result of fixed-length assignment in simulated data. |

### 📝 Disclaimer

This ADaM package is **not regulatory-grade** and is not intended for submission. It is a learning tool and demonstration of:
- ADaM structure and standards
- Use of Pinnacle 21 validation
- How to interpret and document validation outputs in a real-world workflow

No proprietary or clinical data is used — all records are **synthetic and randomly generated**.

---

# 📊 T-Test Analysis – Body Temperature at Day 7

This analysis compares the mean body temperature at Day 7 between the **ViralBlock** and **Placebo** arms using a two-sample t-test.  
The analysis was performed using SAS and follows the standard project structure.

---

## 🔍 Objective

To determine whether there is a statistically significant difference in body temperature at Day 7 between the treatment groups.

---

## 🧪 Data Input

- `advs.csv`: ADaM Vital Signs dataset
  - Filtered on `PARAMCD = "TEMP"` and `AVISIT = "Day 7"`
  - Temperature values stored in `AVAL`
  - Treatment groups identified by `TRTA`

---

## 💻 Script Location

- `4_analysis/analysis_scripts/ttest_temp_day7.sas`

The script:
- Imports ADVS data
- Subsets Day 7 temperature values
- Performs a two-sample t-test
- Generates plots and exports both CSV and PDF output

---

## 📤 Output Files

### Intermediate outputs:
Located in: `4_analysis/analysis_outputs/ttest/`

- `ttest_temp_day7_full.pdf`: PDF with all plots (distribution, boxplot, Q-Q)
- `ttest_temp_day7_results.csv`: T-test statistics (means, SD, t, p-value, CI)

### Final outputs for mock/SAP reports:
Located in: `5_results/final_tables_figures/ttest/`

- `ttest_boxplot.pdf`: Boxplot (single-page)
- `ttest_dist.pdf`: Distribution/histogram
- `ttest_qq.pdf`: Q–Q plot

---

## 📊 Summary of Results

| Group       | Mean (°C) | SD     | N   |
|-------------|-----------|--------|-----|
| Placebo     | 37.86     | 0.28   | 149 |
| ViralBlock  | 37.65     | 0.29   | 151 |

- **Difference (VRB – PBO)**: –0.21 °C  
- **95% Confidence Interval**: [–0.27, –0.14]  
- **t(298) = 6.26**, **p < 0.0001**

**Interpretation**:  
Subjects treated with ViralBlock had a statistically significant lower mean body temperature at Day 7 compared to placebo.

---

## ANCOVA – SpO₂ Change from Baseline to Day 28

This directory contains the SAS script and outputs for an ANCOVA analysis comparing the change in oxygen saturation (SpO₂) from Day 1 (baseline) to Day 28 between treatment arms (Placebo vs ViralBlock).

### Script Location
- `4_analysis/analysis_scripts/ancova_spo2_day28.sas`: SAS script performing the following steps:
  - Imports ADSL and ADVS datasets from the ADaM layer.
  - Extracts SpO₂ values at Day 1 and Day 28.
  - Calculates individual change from baseline.
  - Performs ANCOVA with treatment arm, age, and sex as predictors.
  - Exports:
    - PDF with all diagnostic and model plots.
    - CSV with least-squares means (LSMeans) per treatment group.

### Outputs Location
- `4_analysis/analysis_outputs/ancova/`:
  - `ancova_spo2_plot.pdf`: Multi-page PDF with all ANCOVA plots and diagnostics.
  - `ancova_spo2_lsmeans.csv`: Exported LSMeans results including confidence intervals and group differences.

### Results Summary
- **N = 300** subjects included.
- **Adjusted mean (LSMean) change** in SpO₂:
  - Placebo: 1.37 [95% CI: 1.13 ; 1.61]
  - ViralBlock: 3.24 [95% CI: 3.00 ; 3.49]
- **Adjusted difference (VRB - PBO)**: **+1.88**, statistically significant (*p* < 0.0001).
- **Covariate effects**:
  - Age: Significant (*p* = 0.0238), slight negative association with improvement.
  - Sex: Not significant (*p* = 0.96).

### Final Figures for Report (in `5_results/final_tables_figures/ancova/`)
- Individual plots extracted from `ancova_spo2_plot.pdf`, including:
  - LSMeans summary chart
  - Residual plots
  - Diagnostic graphs for model validity

---

## 🧪 Logistic Regression: Probability of Recovery

**Location:**  
- Script: `4_analysis/analysis_scripts/logistic_recovery.sas`  
- Outputs: `4_analysis/analysis_outputs/logistic/`  
- Final results: `5_results/final_tables_figures/logistic/`

### 🎯 Objective
This analysis models the probability of recovery (`AEOUT = "RECOVERED"`) using logistic regression.  
The binary outcome variable `RECOVFL` is derived and modeled against key covariates.

### 📈 Method
- Logistic regression using `PROC LOGISTIC` in SAS.
- Model:  
  `RECOVFL ~ ARM + AGE + SEX`  
  - `ARM`: Treatment group (Placebo vs. Viralblock)  
  - `AGE`: Continuous covariate  
  - `SEX`: Categorical covariate
- Class variables are treated with reference coding (`ref='Placebo'` for ARM).
- Odds ratios and 95% confidence intervals are reported.

### 📥 Input Datasets
- `adae.csv`: Adverse Events data
- `adsl.csv`: Subject-level data (demographics, treatment)

### 📤 Output Files

#### In `4_analysis/analysis_outputs/logistic/`:
- `logistic_estimates.csv`: Model parameter estimates
- `logistic_oddsratios.csv`: Odds ratios and 95% confidence intervals
- `logistic_recovery_plot.pdf`: Plot output (e.g., model diagnostics)

#### In `5_results/final_tables_figures/logistic/`:
These are the finalized deliverables:
- `logistic_estimates.csv`
- `logistic_oddsratios.csv`
- `logistic_recovery_plot.pdf`

---

📌 *This script is part of the VIRALBLOCK01 analysis pipeline for illustrating statistical analysis in clinical trials.*


---
## 📌 Notes

- Final figures and tables are used in the Mock Report.
- This analysis is referenced in both the Statistical Analysis Plan (SAP) and the final results.

---

## Tools Used

- **R** - simulation and analysis
- **Git/Github** - version control
- *SAS scripts, SQL queries, analysis outputs*

---

## Author

Pasqualino Di Pilla
Clinical Trial Simulation Project - 2025