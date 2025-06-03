/* Export output in pdf and rtf */
ods pdf file="/home/u64139722/ancova_output.pdf" style=journal;
ods rtf file="/home/u64139722/ancova_output.rtf" style=journal;

/* Import ADSL */
proc import datafile="/home/u64139722/adsl.csv"
	out=adsl
	dbms=csv
	replace;
	guessingrows=MAX;
run;

/* Import ADVS */
proc import datafile="/home/u64139722/advs.csv"
	out=advs
	dbms=csv
	replace;
	guessingrows=MAX;
run;

/* Convert ADVS to wide format */
proc transpose data=advs out=vs_wide prefix=O2SAT_;
	by USUBJID;
	id VISITDY;
	var AVAL;
run;

/* Join wide O2SAT with ADSL */
proc sql;
	create table ancova_adsl as
	select
		b.USUBJID,
		b.ARMCD,
		a.O2SAT_1 as O2SAT_Baseline,
		a.O2SAT_28 as O2SAT_Day_28
	from vs_wide as a
	inner join adsl as b
	on a.USUBJID = b.USUBJID;
quit;

/*Perform ANCOVA */
proc glm data=ancova_adsl;
	class ARMCD;
	model O2SAT_Day_28 = ARMCD O2SAT_Baseline;
	lsmeans ARMCD / pdiff stderr cl;
	title "ANCOVA: O2SAT Day 28 adjusted for baseline";
run;

/* close export */
ods pdf close;
ods rtf close;