/* ANCOVA: Adjusting Day 28 O2SAT for baseline */

ods pdf file="/home/u64139722/ancova_o2sat.pdf" style=journal;

/*Baseline extraction (day1)*/
proc sql;
	create table o2_day1 as
	select USUBJID, O2SAT as O2SAT_BL
	from vitals
	where VISITDY = 1;
quit;

/* Day 28 extraction*/
proc sql;
	create table o2_day28 as
	select USUBJID, ARMCD, O2SAT as O2SAT_28
	from vitals
	where VISITDY = 28;
quit;

/*Merge baseline + day 28*/
data o2_ancova;
	merge o2_day28(in=a) o2_day1;
	by USUBJID;
	if a;
run;

/*ANCOVA*/
proc glm data=o2_ancova;
	class ARMCD;
	model O2SAT_28 = ARMCD O2SAT_BL;
	lsmeans ARMCD / pdiff stderr cl;
	title "ANCOVA: O2SAT at day 28 adjusted for Baseline";
run;

ods pdf close;