/***************************************************/
/* Script 2: ANCOVA on SpO2 at Day 28              */
/***************************************************/

/* Define output folder */
%let outpath = /home/u64139722/results;

/* Import data ADSL and ADVS */
proc import datafile='/home/u64139722/adam/advs.csv'
    dbms=csv out=advs replace;
    guessingrows=max;
run;

proc import datafile='/home/u64139722/adam/adsl.csv'
    dbms=csv out=adsl replace;
    guessingrows=max;
run;

/* Extract baseline and Day 28 for SPO2 */
data spo2_base_day28;
    set advs;
    where PARAMCD = "SPO2" and (AVISIT = "Day 28" or AVISIT = "Day 1");
run;

proc sort data=spo2_base_day28;
    by USUBJID AVISIT;
run;

proc transpose data=spo2_base_day28 out=spo2_wide(drop=_NAME_);
    by USUBJID;
    id AVISIT;
    var AVAL;
run;

/* Calculate change and merge with ADSL */
data spo2_ancova;
    merge spo2_wide(in=a) adsl(keep=USUBJID AGE SEX ARM);
    by USUBJID;
    if a and not missing('Day 1'n) and not missing('Day 28'n);
    change = 'Day 28'n - 'Day 1'n;
run;

/* ====== Export plot in PDF ====== */
ods pdf file="&outpath./ancova_spo2_plot.pdf";
ods graphics on;

ods trace on;
ods output LSMeans=lsmeans; /* solo LSMeans */

proc glm data=spo2_ancova plots=all;
    class ARM SEX;
    model change = ARM AGE SEX / solution;
    lsmeans ARM / pdiff cl;
    title "ANCOVA: Change in SpO2 from Baseline to Day 28";
run;

ods trace off;
ods graphics off;
ods pdf close;

/* Export only LSMeans if exist */
%macro export_lsmeans;
  %if %sysfunc(exist(lsmeans)) %then %do;
    proc export data=lsmeans
      outfile="&outpath./ancova_spo2_lsmeans.csv"
      dbms=csv replace;
    run;
  %end;
  %else %put NOTE: LSMeans dataset non esiste, nessun export.;
%mend;

%export_lsmeans;
