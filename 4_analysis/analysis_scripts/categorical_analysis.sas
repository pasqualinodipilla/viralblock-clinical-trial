/******************************************************/
/* CATEGORICAL ANALYSIS – AE presence and severity    */
/******************************************************/

/* Import datasets */
proc import datafile="/home/u64139722/adam/adae.csv"
    dbms=csv out=adae replace;
    guessingrows=max;
run;

proc import datafile="/home/u64139722/adam/adsl.csv"
    dbms=csv out=adsl replace;
    guessingrows=max;
run;

/* Merge treatment info from ADSL into ADAE */
proc sql;
    create table ae_with_arm as
    select a.*, b.ARM
    from adae a left join adsl b
    on a.USUBJID = b.USUBJID;
quit;

/* Create binary flag for any AE per subject */
proc sql;
    create table ae_flag as
    select distinct USUBJID, ARM, 1 as AE_FLAG
    from ae_with_arm;
quit;

data adsl_with_flag;
    merge adsl(in=a) ae_flag(in=b);
    by USUBJID;
    if a;
    if not b then AE_FLAG = 0;
run;

/* === AE Presence Chi-Square === */
ods pdf file="/home/u64139722/results/chisq_ae_presence.pdf";
proc freq data=adsl_with_flag;
    tables ARM*AE_FLAG / chisq fisher;
    title "Chi-Square Test: AE Presence by Treatment Group";
run;
ods pdf close;

/* === AE Severity Chi-Square === */
ods pdf file="/home/u64139722/results/chisq_ae_severity.pdf";
proc freq data=ae_with_arm;
    tables ARM*AESEV / chisq fisher;
    title "Chi-Square Test: AE Severity by Treatment Group";
run;
ods pdf close;

/* === RECOVERY OUTCOME: Multinomial Logistic Regression === */

/* Derive RECOV_CAT variable from AEOUT */
data recovery_status;
    set adae;
    length RECOV_CAT $20;
    if AEOUT in ("RECOVERED", "RECOVERING", "NOT RECOVERED") then RECOV_CAT = AEOUT;
run;

/* Keep first AE per subject */
proc sort data=recovery_status;
    by USUBJID AESEQ;
run;

proc sort data=recovery_status nodupkey out=recov_final;
    by USUBJID;
run;

/* Merge with ADSL */
data recov_model;
    merge recov_final(in=a keep=USUBJID RECOV_CAT)
          adsl(in=b keep=USUBJID ARM AGE SEX);
    by USUBJID;
    if a and b;
run;

/* === Multinomial Logistic Regression Output === */
ods pdf file="/home/u64139722/results/multinomial_recovery.pdf";
ods graphics on;

proc logistic data=recov_model;
    class RECOV_CAT (ref="RECOVERED") ARM (ref="Placebo") SEX / param=ref;
    model RECOV_CAT = ARM AGE SEX / link=glogit;
    title "Multinomial Logistic Regression: Recovery Status by Treatment";
run;

ods graphics off;
ods pdf close;

