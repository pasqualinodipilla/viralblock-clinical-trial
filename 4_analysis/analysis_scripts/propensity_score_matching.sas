/******************************************************/
/* PROPENSITY SCORE MATCHING – Placebo vs ViralBlock */
/******************************************************/

/* Step 1: Import ADSL */
proc import datafile="/home/u64139722/adam/adsl.csv"
    dbms=csv out=adsl replace;
    guessingrows=max;
run;

/* Step 2: Create binary treatment variable */
data ps_input;
    set adsl;
    if ARM in ("Placebo", "ViralBlock");
    treat = (ARM = "ViralBlock"); /* 1 = ViralBlock, 0 = Placebo */
run;

/* === Step 3: Estimate propensity scores === */
ods pdf file="/home/u64139722/results/ps_model.pdf";
ods graphics on;

proc logistic data=ps_input descending;
    class SEX (ref='F') / param=ref;
    model treat = AGE SEX;
    output out=ps_scores p=pscore;
    title "Propensity Score Model: Treatment ~ AGE + SEX";
run;

ods graphics off;
ods pdf close;

/* === Step 4: Matching diagnostics === */
ods pdf file="/home/u64139722/results/psm_diagnostics.pdf";
ods graphics on;

proc psmatch data=ps_scores region=allobs;
    class treat SEX;
    psmodel treat(Treated='1') = AGE SEX;

    match method=greedy(k=1); /* Nearest neighbor = greedy match 1:1 */
    
    assess lps var=(AGE SEX) / plots=all;
    
    output out=matched_dataset matchid=_MatchID;
    title "Propensity Score Matching - Nearest Neighbor (1:1)";
run;

ods graphics off;
ods pdf close;




