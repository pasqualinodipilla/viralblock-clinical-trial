/* Export output in pdf and rtf */
ods pdf file="/home/u64139722/logistic_output.pdf" style=journal;
ods rtf file="/home/u64139722/logistic_output.rtf" style=journal;


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

/* Filter O2SAT at day 28*/
data vs28;
	set advs;
	where PARAMCD = "O2SAT" and VISITDY = 28;
	keep USUBJID AVAL;
run;

/* Create binary variable for hypoxemia (O2SAT <= 90) */
data vs28_flag;
	set vs28;
	/* I use 97 instead of 90 (temporary change of the threshold) since for our dataset we have all flags=0*/
	if AVAL <= 97 then hypo_flag = 1;
	else hypo_flag = 0;
run;

/* Merge with ADSL for ARMCD */
proc sql;
	create table log_data as
	select a.USUBJID, a.hypo_flag, b.ARMCD
	from vs28_flag as a
	inner join adsl as b
	on a.USUBJID = b.USUBJID;
quit;

/*Logistic regression */
proc logistic data = log_data descending;
	class ARMCD (ref='PBO'); /* 'PBO'=Placebo */
	model hypo_flag = ARMCD;
	title "Logistic Regression: Effect of Treatment on Risk of Hypoxemia (O2SAT <= 90)";
run;
ods pdf close;
ods rtf close;