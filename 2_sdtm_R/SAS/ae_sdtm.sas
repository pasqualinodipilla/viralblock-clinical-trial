/* Import AE and Patients CSVs from your SAS Studio /home folder*/
proc import datafile = "/home/u64139722/ae.csv"
	out = ae_raw
	dbms = csv
	replace;
	guessingrows = MAX;
run;

proc import datafile = "/home/u64139722/patients.csv"
	out=patients
	dbms=csv 
	replace;
	guessingrows=MAX;
run;

/*Merge datasets*/
proc sort data=ae_raw; by USUBJID; run;
proc sort data=patients; by USUBJID; run;

data ae_merged;
	merge ae_raw (in=a) patients (keep=USUBJID ARMCD);
	by USUBJID;
	if a;
run;

/*Derive SDTM variables*/
data ae_sdtm;
	set ae_merged;
	lenght STUDYID $20 DOMAIN $2 AEDECOD AESER $1 AESTDTC $10;
	
	STUDYID = "VIRALBLOCK01";
	DOMAIN = "AE";
	AESEQ = _N_;
	AEDECOD = AETERM;
	
	if AESEV = "SEVERE" then AESER="Y";
	else AESER = "N";
	
	BASEDATE = '01JAN2023'd;
	AESTDTC = put(BASEDATE + AESTDY - 1, yymmdd10.);
	
	keep STUDYID DOMAIN USUBJID AESEQ AETERM AEDECOD AESEV AESER AESTDTC AEOUT AEREL ARMCD;
run;
	
/*Export as CSV (optional) */
proc export data=ae_sdtm
	outfile = "/home/u64139722/ae_sdtm_sas.csv"
	dbms = csv
	replace;
run;