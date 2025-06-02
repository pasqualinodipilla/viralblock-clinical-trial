/* Import VITALS dataset from raw folder */
proc import datafile="/home/u64139722/vitals.csv"
	out=vitals
	dbms=csv
	replace;
	guessingrows=MAX;
run;

/* Filter data to keep only Day 28 visits */
data vitals_day28;
	set vitals;
	where VISITDY = 28;
run;

/* Two-sample t-test for O2SAT at Day 28 by treatment arm */
ods pdf file = "/home/u64139722/t_test_full_output.pdf" style=journal;
title "T-test: O2SAT at Day 28 - Viralblock vs Placebo";

proc ttest data=vitals_day28;
	class ARMCD; /*Grouping variable: PBO vs VIR*/
	var O2SAT;	/*Outcome: oxygen saturation*/
run;

ods pdf close;

ods rtf file="/home/u64139722/t_test_full_output.rtf" style=journal;
title "T-test: O2SAT at Day 28 - Viralblock vs Placebo";

proc ttest data=vitals_day28;
	class ARMCD; /*Grouping variable: PBO vs VIR*/
	var O2SAT;	/*Outcome: oxygen saturation*/
run;

ods rtf close;
