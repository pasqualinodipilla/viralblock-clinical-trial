/***************************************************/
/* Script 1: t-test on temperature at Day 7         */
/***************************************************/

/* Define output folder */
%let outpath = /home/u64139722/results;

/* Import ADV */
proc import datafile='/home/u64139722/adam/advs.csv'
    dbms=csv out=advs replace;
    guessingrows=max;
run;

/* Extract only Day 7 for TEMP */
proc sort data=advs out=temp_day7;
    where PARAMCD = "TEMP" and AVISIT = "Day 7";
    by USUBJID;
run;

/* ====== Export plot (boxplot + Q-Q + histogram) in PDF ====== */
ods pdf file="&outpath./ttest_temp_day7_full.pdf";
ods graphics on;

ods output TTests=ttest_out;
proc ttest data=temp_day7 plots=all;
    class TRTA;
    var AVAL;
    title "T-Test: Body Temperature at Day 7 by Treatment Group";
run;
ods output close;

ods graphics off;
ods pdf close;

/* ====== Export numeric results in CSV ====== */
proc export data=ttest_out
    outfile="&outpath./ttest_temp_day7_results.csv"
    dbms=csv
    replace;
run;