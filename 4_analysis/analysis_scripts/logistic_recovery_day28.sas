/***************************************************/
/* Script 3: Logistic regression - Recovery        */
/***************************************************/

/* Import data ADAE and ADSL */
proc import datafile='/home/u64139722/adam/adae.csv'
    dbms=csv out=adae replace;
    guessingrows=max;
run;

proc import datafile='/home/u64139722/adam/adsl.csv'
    dbms=csv out=adsl replace;
    guessingrows=max;
run;

/* Deriva ae_flag */
proc sort data=adae out=ae_flag;
    by USUBJID AESEQ;
run;

data recovery;
    set ae_flag;
    length RECOVFL $1;
    if AEOUT = "RECOVERED" then RECOVFL = "Y";
    else RECOVFL = "N";
run;

proc sort data=recovery nodupkey out=recovery_flagged;
    by USUBJID;
run;

/* Join with ADSL */
data recolog;
    merge recovery_flagged(in=a) adsl(keep=USUBJID AGE SEX ARM);
    by USUBJID;
    if a;
run;

/* ====== Logistic Regression with plot in PDF ====== */
ods pdf file="&outpath./logistic_recovery_plot.pdf";
ods graphics on;

ods trace on;
ods output ParameterEstimates=logit_estimates OddsRatios=logit_odds;

proc logistic data=recolog descending;
    class ARM(ref="Placebo") SEX / param=ref;
    model RECOVFL = ARM AGE SEX;
    title "Logistic Regression: Probability of Recovery";
run;

ods trace off;
ods graphics off;
ods pdf close;

/* Export results in CSV */
%macro export_logistic;
  %if %sysfunc(exist(logit_estimates)) %then %do;
    proc export data=logit_estimates
      outfile="&outpath./logistic_estimates.csv"
      dbms=csv replace;
    run;
  %end;

  %if %sysfunc(exist(logit_odds)) %then %do;
    proc export data=logit_odds
      outfile="&outpath./logistic_oddsratios.csv"
      dbms=csv replace;
    run;
  %end;
%mend;

%export_logistic;