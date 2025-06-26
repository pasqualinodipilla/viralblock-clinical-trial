/******************************************************/
/* REPEATED MEASURE ANALYSIS – SPO2 over Time         */
/******************************************************/

/* 1. Import datasets */
proc import datafile="/home/u64139722/adam/advs.csv"
    dbms=csv out=advs replace;
    guessingrows=max;
run;

proc import datafile="/home/u64139722/adam/adsl.csv"
    dbms=csv out=adsl replace;
    guessingrows=max;
run;

/* 2. Filtra solo SPO2 */
data spo2_raw;
    set advs;
    where PARAMCD = "SPO2";
run;

/* 3. Unisci con dati demografici */
proc sql;
    create table spo2_merge as
    select a.*, b.ARM, b.AGE, b.SEX
    from spo2_raw a
    left join adsl b on a.USUBJID = b.USUBJID;
quit;

/* 4. RM-ANOVA: crea dataset wide per RMANOVA */
proc sort data=spo2_merge; by USUBJID AVISITN; run;

proc transpose data=spo2_merge out=spo2_wide prefix=SPO2_;
    by USUBJID ARM;
    id AVISITN;
    var AVAL;
run;

/* 5. Repeated Measures ANOVA */
ods pdf file="/home/u64139722/results/rmanova_spo2.pdf";
proc glm data=spo2_wide;
    class ARM;
    model SPO2_1 SPO2_2 SPO2_3 SPO2_4 SPO2_5 = ARM / nouni;
    repeated Time 5 (1 2 3 4 5) profile;
    title "Repeated Measures ANOVA on SPO2 by Treatment Group";
run;
ods pdf close;

/* 6. Linear Mixed Model (long format) */
ods pdf file="/home/u64139722/results/lmm_spo2.pdf";
proc mixed data=spo2_merge method=REML;
    class USUBJID ARM AVISITN;
    model AVAL = ARM AVISITN ARM*AVISITN / solution;
    repeated AVISITN / subject=USUBJID type=cs;
    title "Linear Mixed Model for SPO2 (Treatment x Time)";
run;
ods pdf close;
