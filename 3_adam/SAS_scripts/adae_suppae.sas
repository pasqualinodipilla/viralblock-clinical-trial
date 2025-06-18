/* Step 1: Import AE SDTM */
proc import datafile="/home/u64139722/ae.csv"
    out=ae_raw
    dbms=csv
    replace;
    guessingrows=MAX;
run;

/* Step 2: Rinominare variabili problematiche */
data ae_step1;
    set ae_raw(rename=(USUBJID=USUBJID_OLD AESTDTC=AESTDTC_num AEENDTC=AEENDTC_num));
run;

/* Step 3: Creazione dataset AE SDTM */
data ae_sdtm;
    set ae_step1;

    length 
        STUDYID $20 DOMAIN $2 USUBJID $30 SUBJID $10 AESEQ 8
        AETERM $200 AESTDTC AEENDTC $10 AESTDY AEENDY 8
        AESER $1 AESEV $10 AEOUT AEACN AEREL $40
        AEPRESP $10 AEONGO $1 AETOXGR $5 AESOC $100;

    /* Ricostruzione USUBJID */
    STUDYID = "VIRALBLOCK01";
    if substr(USUBJID_OLD, 1, 4) = "SUBJ" then do;
        SUBJID = substr(USUBJID_OLD, 5);
        USUBJID = catx("-", STUDYID, SUBJID);
    end;

    DOMAIN = "AE";

    /* Derivazione AEONGO */
    if upcase(strip(AEENRF)) = "ONGOING" then AEONGO = "Y";
    else AEONGO = "";

    /* Conversione date numeriche */
    AESTDTC = put(AESTDTC_num, yymmdd10.);
    AEENDTC = put(AEENDTC_num, yymmdd10.);

    format AESTDT AEENDT date9.;
    AESTDT = AESTDTC_num;
    AEENDT = AEENDTC_num;

    /* Derivazione dei giorni studio */
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
        AETOXGR   = "Toxicity Grade (if used)"
        AESOC     = "System Organ Class";
run;

/* Step 4: Ordinamento e AESEQ */
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

/* Step 5: Dataset finale ADAE */
data adae;
    retain
        STUDYID DOMAIN USUBJID AESEQ
        AETERM AESTDTC AEENDTC
        AESTDY AEENDY
        AESER AESEV AEOUT AEACN AEREL
        AEPRESP AEONGO AETOXGR;
    set ae_sdtm;
run;

/* Step 6: Export ADAE */
proc export data=adae
    outfile="/home/u64139722/adam/adae.csv"
    dbms=csv
    replace;
run;

libname xptout xport "/home/u64139722/adam/adae.xpt";
data xptout.ADAE;
    set adae;
run;
libname xptout clear;

/* Step 7: Rimozione duplicati per SUPPAE */
proc sort data=ae_sdtm nodupkey out=ae_unique;
    by USUBJID AESEQ AESOC;
run;

/* Step 8: SUPPAE derivato */
data suppae;
    set ae_unique;
    where AESOC ne '';

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

/* Step 9: Export SUPPAE */
proc export data=suppae
    outfile="/home/u64139722/adam/suppae.csv"
    dbms=csv
    replace;
run;

libname xptout xport "/home/u64139722/adam/suppae.xpt";
data xptout.SUPPAE;
    set suppae;
run;
libname xptout clear;