/* Import AE file */
proc import datafile="/home/u64139722/ae.csv"
    out=ae_raw
    dbms=csv
    replace;
    guessingrows=MAX;
run;

/* Step to rename numeric variables with problems */
data ae_step1;
    set ae_raw(rename=(USUBJID=USUBJID_OLD AESTDTC=AESTDTC_num AEENDTC=AEENDTC_num));
run;

/* AE SDTM dataset creation */
data ae_sdtm;
    set ae_step1;

    length 
        STUDYID $20 DOMAIN $2 USUBJID $30 SUBJID $10 AESEQ 8
        AETERM $200 AESTDTC AEENDTC $10 AESTDY AEENDY 8
        AESER $1 AESEV $10 AEOUT AEACN AEREL $40
        AEPRESP $10 AEONGO $1 AETOXGR $5;

    /* Correct USUBJID */
    STUDYID = "VIRALBLOCK01";
    if substr(USUBJID_OLD, 1, 4) = "SUBJ" then do;
        SUBJID = substr(USUBJID_OLD, 5);
        USUBJID = catx("-", STUDYID, SUBJID);
    end;

    DOMAIN = "AE";

    /* Derive AEONGO from AEENRF */
    if upcase(strip(AEENRF)) = "ONGOING" then AEONGO = "Y";
    else AEONGO = "";

    /* Conversion  numerico-to-character (format ISO 8601) */
    AESTDTC = put(AESTDTC_num, yymmdd10.);
    AEENDTC = put(AEENDTC_num, yymmdd10.);

    /* Compute AESTDY and AEENDY with respect to RFSTDTC simulated */
    format AESTDT AEENDT date9.;
    AESTDT = AESTDTC_num;
    AEENDT = AEENDTC_num;

    if AESTDT ne . then AESTDY = AESTDT - '01JAN2023'd + 1;
    if AEENDT ne . then AEENDY = AEENDT - '01JAN2023'd + 1;

    drop AEENRF ARMCD USUBJID_OLD AESTDT AEENDT AESTDTC_num AEENDTC_num;

    label
        STUDYID   = "Study Identifier"
        DOMAIN    = "Domain Abbreviation"
        USUBJID   = "Unique Subject Identifier"
        AESEQ     = "Sequence Number"
        AETERM    = "Reported Term for the Adverse Event"
        AESTDTC   = "Start Date/Time of Adverse Event"
        AEENDTC   = "End Date/Time of Adverse Event"
        AESTDY    = "Study Day of Start of AE"
        AEENDY    = "Study Day of End of AE"
        AESER     = "Serious Event"
        AESEV     = "Severity/Intensity"
        AEOUT     = "Outcome of Adverse Event"
        AEACN     = "Action Taken with Study Treatment"
        AEREL     = "Causality"
        AEPRESP   = "Present at Screening"
        AEONGO    = "Ongoing AE Flag"
        AETOXGR   = "Toxicity Grade (if used)";
run;

/* Step 3: Order and enumerate AESEQ */
proc sort data=ae_sdtm;
    by USUBJID AESTDTC AETERM;
run;

data ae_sdtm;
    set ae_sdtm;
    by USUBJID;
    retain AESEQ;
    if first.USUBJID then AESEQ = 1;
    else AESEQ + 1;
run;

/* Step 4: Order variables according to SDTM AE */
data ae_final;
    retain
        STUDYID DOMAIN USUBJID AESEQ
        AETERM AESTDTC AEENDTC
        AESTDY AEENDY
        AESER AESEV AEOUT AEACN AEREL
        AEPRESP AEONGO AETOXGR;
    set ae_sdtm;
run;

data ae_final2;
	set ae_final;
	drop AESOC SUBJID;
run;

proc freq data=ae_final2;
    tables AESER AESEV AEOUT AEACN AEREL / missing;
run;

data suppae;
	retain STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL;
    set ae_final;
    where AESOC ne ''; /* if AESOC is available from original dataset */

    length 
        STUDYID $20 RDOMAIN $2 USUBJID $30
        IDVAR $6 IDVARVAL $10 QNAM $8 QLABEL $40 QVAL $100;

    RDOMAIN   = "AE";
    IDVAR     = "AESEQ";
    IDVARVAL  = strip(put(AESEQ, best.));
    QNAM      = "AESOC";
    QLABEL    = "System Organ Class";
    QVAL      = AESOC;

    keep STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL;
run;


/* Step 5: Export in CSV */
proc export data=ae_final2
    outfile="/home/u64139722/sdtm/ae.csv"
    dbms=csv
    replace;
run;

/* Step 6: Export in XPT */
libname xptout xport "/home/u64139722/sdtm/ae.xpt";

data xptout.AE;
    set ae_final2;
run;

libname xptout clear;

proc freq data=suppae;
    where QNAM = "AESOC";
    tables QVAL / missing;
run;

/* Export SUPPAE in CSV */
proc export data=suppae
    outfile="/home/u64139722/sdtm/suppae.csv"
    dbms=csv
    replace;
run;

/* Export SUPPAE in XPT */
libname xptout xport "/home/u64139722/sdtm/suppae.xpt";

data xptout.SUPPAE;
    set suppae;
run;

libname xptout clear;