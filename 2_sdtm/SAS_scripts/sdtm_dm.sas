proc import datafile="/home/u64139722/dm.csv"
	out=dm_raw
	dbms=csv
	replace;
	guessingrows=max;
run;

data dm_sdtm;
	retain
		STUDYID DOMAIN USUBJID SUBJID RFSTDTC RFENDTC
		RFXSTDTC RFXENDTC RFICDTC RFPENDTC DTHDTC DTHFL
		SITEID INVNAM BRTHDTC AGE AGEU SEX RACE COUNTRY
		ETHNIC ARMCD ARM ACTARMCD ACTARM ARMNRS ACTARMNRS
		TRTSDTC TRTENDTC DMDTC;
	set dm_raw(rename=(USUBJID=USUBJID_OLD));
	
	length
		STUDYID $14 DOMAIN $4 USUBJID $20 SUBJID $9
		RFSTDTC RFENDTC TRTSDTC TRTENDTC DMDTC BRTHDTC $10
		SITEID $6 INVNAM $15
		AGEU $7 SEX $3 RACE $27 COUNTRY $5 ETHNIC $12
		ARMCD $5 ARM $12 ACTARMCD $5 ACTARM $12;
		
	/*Fixed*/
	STUDYID = "VIRALBLOCK01";
	DOMAIN = "DM";
	
	/*Derive SUBJID from USUBJID e.g. 'SUBJ001'*/
	SUBJID = substr(USUBJID_OLD, 5);
	USUBJID = catx("-", "VIRALBLOCK01", SUBJID);
	
	/*Generic values*/
	SITEID = "001";
	INVNAM = "Dr. Rossi";
	
	/*Date ISO08601 */
	if TRTSDT ne . then do;
		RFSTDTC = put(TRTSDT, yymmdd10.);
		TRTSDTC = RFSTDTC;
		DMDTC   = RFSTDTC;
	end;
	
	if TRTENDT ne . then do;
		RFENDTC = put(TRTENDT, yymmdd10.);
		TRTENDTC = RFENDTC;
	end;
	
	/* BRTHDTC from AGE */
	if AGE ne . and TRTSDT ne . and upcase(AGEU)="YEARS" then do;
		BRTHDATE = intnx('year', TRTSDT, -AGE, 's');
		BRTHDTC = put(BRTHDATE, yymmdd10.);
	end;
	
	ACTARM = ARM;
	ACTARMCD = ARMCD;
	
	ETHNIC = "UNKNOWN";
	
	RFXSTDTC = TRTSDTC;
	RFXENDTC = TRTENDTC;
	
	RFICDTC = '';
	RFPENDTC = '';
	DTHDTC = '';
	DTHFL = '';
	
	length ARMNRS ACTARMNRS $200;

    /* Default: null values */
    ARMNRS = "";
    ACTARMNRS = "";

    /* Caso 1: Screen Failure */
    if missing(ARM) and missing(ACTARM) and scrfl eq "Y" then do;
        ARMNRS = "SCREEN FAILURE";
        ACTARMNRS = "SCREEN FAILURE";
    end;

    /* Caso 2: Not Randomized */
    else if missing(ARM) and missing(ACTARM) then do;
        ARMNRS = "NOT ASSIGNED";
        ACTARMNRS = "NOT ASSIGNED";
    end;

    /* Caso 3: Randomized but not treated */
    else if not missing(ARM) and missing(ACTARM) then do;
        ARMNRS = "ASSIGNED, NOT TREATED";
        ACTARMNRS = "NOT TREATED";
    end;
    
    /* Caso 4: ACTARM ≠ ARM */
    else if not missing(ARM) and not missing(ACTARM) and ARM ne ACTARM then do;
        /* ARMNRS not necessary */
        ACTARMNRS = "TREATED DIFFERENT FROM ASSIGNED";
        ACTARMUD = "Unplanned treatment: " || strip(ACTARM);
    end;
	
	label
        STUDYID      = "Study Identifier"
        DOMAIN       = "Domain Abbreviation"
        USUBJID      = "Unique Subject Identifier"
        SUBJID       = "Subject Identifier for the Study"
        RFSTDTC      = "Subject Reference Start Date/Time"
        RFENDTC      = "Subject Reference End Date/Time"
        RFXSTDTC     = "Date/Time of First Study Treatment"
        RFXENDTC     = "Date/Time of Last Study Treatment"
        RFICDTC      = "Date/Time of Informed Consent"
        RFPENDTC     = "Date/Time of End of Participation"
        DTHDTC       = "Date/Time of Death"
        DTHFL        = "Subject Death Flag"
        SITEID       = "Study Site Identifier"
        INVNAM       = "Investigator Name"
        BRTHDTC      = "Date/Time of Birth"
        AGE          = "Age"
        AGEU         = "Age Units"
        SEX          = "Sex"
        RACE         = "Race"
        ETHNIC       = "Ethnicity"
        COUNTRY      = "Country"
        ARMCD        = "Planned Arm Code"
        ARM          = "Description of Planned Arm"
        ACTARMCD     = "Actual Arm Code"
        ACTARM       = "Description of Actual Arm"
        ARMNRS       = "Reason Arm is Null"
        ACTARMNRS    = "Reason Actual Arm is Null"
        TRTSDTC      = "Date/Time of First Exposure to Treatment"
        TRTENDTC     = "Date/Time of Last Exposure to Treatment"
        DMDTC        = "Date/Time of Collection"
    ;
	
	
	keep STUDYID DOMAIN USUBJID SUBJID RFSTDTC RFENDTC
		RFXSTDTC RFXENDTC RFICDTC RFPENDTC DTHDTC DTHFL
		SITEID INVNAM BRTHDTC AGE AGEU SEX RACE ETHNIC COUNTRY
		ARMCD ARM ACTARMCD ACTARM ARMNRS ACTARMNRS TRTSDTC
		TRTENDTC DMDTC;
run;

proc export data=dm_sdtm
    outfile="/home/u64139722/sdtm/dm.csv"
    dbms=csv
    replace;
run;

data dm_xpt;
    set dm_sdtm;
    length ARMNRSX $200 ACTARNX $200;
    ARMNRSX = ARMNRS;
    ACTARNX = ACTARMNRS;
    drop ARMNRS ACTARMNRS;
    rename ARMNRSX = ARMNRS
           ACTARNX = ACTARMRS;
run;

proc freq data=dm_xpt;
    tables SEX RACE COUNTRY ETHNIC ARMCD ARM ACTARMCD ACTARM DTHFL / missing;
run;

libname xptout xport "/home/u64139722/sdtm/dm.xpt";

data xptout.DM_FIN;
    set dm_xpt;
run;

libname xptout clear;



