/*Open output in pdf, rtf */
ods pdf file = "/home/u64139722/ttest_output.pdf";
ods rtf file = "/home/u64139722/ttest_output.rtf";

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

/* Filter only data O2SAT day 28 */
data day28;
	set advs;
	where PARAMCD = "O2SAT" and AVISIT = "Day 28";
run;

/* Merge with ADSL */
proc sql;
	create table ttest_data as
	select a.USUBJID, a.AVAL, b.ARMCD
	from day28 as a
	inner join adsl as b
	on a.USUBJID = b.USUBJID;
quit;

/* T-test */
proc ttest data=ttest_data;
	class ARMCD;
	var AVAL;
run;

/*close output*/
ods pdf close;
ods rtf close;