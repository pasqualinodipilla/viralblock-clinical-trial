proc import datafile="/home/u64139722/dm.csv"
	out=dm_raw dbms=csv replace;
run;

libname sdtm "/home/u64139722/sdtm";

/*sdtm DM dataset creation:*/
data sdtm.dm;
	set dm_raw(rename=(USUBJID=USUBJID2));
	

	/*Identifiers*/
	STUDYID = "VIRALBLOCK01";
	DOMAIN  = "DM";
	
	length SUBJID $9 USUBJID $20;
	SUBJID = substr(USUBJID2, 5);
	put SUBJID=;
	USUBJID = catx("-", "VIRALBLOCK01", SUBJID);
	
	/*Input variables*/
	SEX     = SEX;
	AGE     = input(AGE, best.);
	AGEU    = AGEU;
	RACE    = RACE;
	COUNTRY = COUNTRY;
	ARMCD   = ARMCD;
	ARM     = ARM;
	SITEID  = SITEID;
	
	/*date:*/
	TRTSDT    = TRTSDT;
	TRTENDT   = TRTENDT;
	
	/*Date: conversion to character*/
	ACTARM   = ARM;
	ACTARMCD = ARMCD;
	ARMNRS   = "";
	RFSTDTC  = put(TRTSDT, yymmdd10.);
	DMDTC = put(TRTSDT, yymmdd10.);
	RFENDTC  = put(TRTENDT, yymmdd10.);
	RFXSTDTC = put(TRTSDT, yymmdd10.);
	RFXENDTC = put(TRTENDT, yymmdd10.);
	RFICDTC  = "";
	DTHDTC   = "";
	DTHFL    = "";
	
	/*Labels assigning*/
	label
		STUDYID = "Study Identifier"
		DOMAIN = "Domain Abbreviation"
		USUBJID = "Unique Subject Identifier"
		SUBJID = "Subject Identifier"
		SEX = "Sex"
		AGE = "Age"
		AGEU = "Age Units"
		RACE = "Race"
		COUNTRY = "Country"
		ARMCD = "Planned Arm Code"
		ARM = "Description of Planned Arm"
		TRTSDT = "Start Date of Treatment"
		TRTENDT = "End Date of Treatment"
		DMDTC = "Date/Time of Collection"
		SITEID = "Study Site Identifier"
		ACTARM = "Actual Arm"
		ACTARMCD = "Actual Arm Code"
		ARMNRS = "Reason Not Treated"
		RFSTDTC = "Subject Reference Start Date/Time"
		RFENDTC = "Subject Reference End Date/Time"
		RFXSTDTC = "Date/Time of First Exposure to Treatment"
		RFXENDTC = "Date/Time of Last Exposure to Treatment"
		RFICDTC = "Informed Consent Date/Time"
		DTHDTC = "Date/Time of Death"
		DTHFL = "Subject Death Flag";
	
	format
		TRTSDT TRTENDT yymmdd10.
		;
	
	keep STUDYID DOMAIN USUBJID SUBJID SEX AGE AGEU RACE COUNTRY ARMCD
		 ARM TRTSDT TRTENDT DMDTC SITEID ACTARM ACTARMCD RFSTDTC
		 RFENDTC RFXSTDTC RFXENDTC ARMNRS RFICDTC DTHDTC DTHFL;
run;

/*csv*/
proc export data = sdtm.dm
	outfile = "/home/u64139722/sdtm/dm.csv"
	dbms=csv
	replace;
run;

/*xpt*/
libname xptout xport "/home/u64139722/sdtm/dm.xpt";

	data xptout.dm;
		set sdtm.dm;
	run;

libname xptout clear;

PROC CONTENTS data = sdtm.dm varnum;
run;