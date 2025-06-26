/******************************************************/
/* TABLE 1: Baseline Characteristics                  */
/******************************************************/

/* Import ADSL and ADVS */
proc import datafile="/home/u64139722/adam/adsl.csv"
    dbms=csv out=adsl replace;
    guessingrows=max;
run;

proc import datafile="/home/u64139722/adam/advs.csv"
    dbms=csv out=advs replace;
    guessingrows=max;
run;

/* Calcola media SPO2 per soggetto */
data spo2;
    set advs;
    where PARAMCD = "SPO2";
run;

proc means data=spo2 noprint;
    class USUBJID;
    var AVAL;
    output out=spo2_mean(drop=_TYPE_ _FREQ_) mean=MEAN_SPO2;
run;

data adsl_spo2;
    merge adsl(in=a) spo2_mean(in=b);
    by USUBJID;
    if a;
run;

/* Table 1: Summary by Treatment Group */
ods pdf file="/home/u64139722/results/table1_baseline.pdf";
proc means data=adsl_spo2 n mean std min max maxdec=1;
    class ARM;
    var AGE MEAN_SPO2;
    title "Table 1: Baseline Characteristics by Treatment";
run;

proc freq data=adsl_spo2;
    tables ARM*SEX ARM*RACE / chisq;
    title "Table 1: Categorical Baseline Characteristics by Treatment";
run;
ods pdf close;


/******************************************************/
/* TABLE 2: Recovery Status at Day 28                 */
/******************************************************/

/* Import ADAE */
proc import datafile="/home/u64139722/adam/adae.csv"
    dbms=csv out=adae replace;
    guessingrows=max;
run;

/* Deriva variabile RECOVERED/NOT RECOVERED per ogni soggetto */
data recovery;
    set adae;
    if AEOUT in ("RECOVERED", "RECOVERING", "NOT RECOVERED");
run;

proc sort data=recovery;
    by USUBJID AESEQ;
run;

proc sort data=recovery nodupkey out=recovery_final;
    by USUBJID;
run;

data recovery_flag;
    set recovery_final;
    if AEOUT = "RECOVERED" then RECOV_STATUS = "RECOVERED";
    else RECOV_STATUS = "NOT RECOVERED";
run;

/* Merge with treatment */
data recov_tab2;
    merge recovery_flag(in=a keep=USUBJID RECOV_STATUS)
          adsl(in=b keep=USUBJID ARM);
    by USUBJID;
    if a and b;
run;

/* Table 2 */
ods pdf file="/home/u64139722/results/table2_recovery.pdf";
proc freq data=recov_tab2;
    tables ARM*RECOV_STATUS / chisq;
    title "Table 2: Recovery Status by Treatment Group";
run;
ods pdf close;


/******************************************************/
/* TABLE 4: Adverse Events Summary                    */
/******************************************************/

/* AE presence per soggetto */
proc sql;
    create table ae_flag as
    select distinct USUBJID, 1 as AE_FLAG
    from adae;
quit;

data ae_summary;
    merge adsl(in=a keep=USUBJID ARM) ae_flag(in=b);
    by USUBJID;
    if a;
    if not b then AE_FLAG = 0;
run;

/* Table 4 - Any AE */
ods pdf file="/home/u64139722/results/table4_ae_summary.pdf";
proc freq data=ae_summary;
    tables ARM*AE_FLAG / chisq;
    title "Table 4: Subjects with at least one AE";
run;

/* AE Severity */
data ae_sev;
    merge adae(in=a keep=USUBJID AESEV) adsl(in=b keep=USUBJID ARM);
    by USUBJID;
    if a and b;
run;

proc freq data=ae_sev;
    tables ARM*AESEV / chisq;
    title "Table 4: AE Severity by Treatment Group";
run;
ods pdf close;
