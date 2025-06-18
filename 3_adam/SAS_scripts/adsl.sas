proc import datafile="/home/u64139722/sdtm/dm.csv"
    out=dm
    dbms=csv
    replace;
    guessingrows=MAX;
run;

/* Creazione ADSL */
data adsl;
    set dm;

    length SAFFL ITTFL EFFFL $1;
    format TRTSDT TRTEDT BRTHDT date9.;

    /* Conversione ISO 8601 in date numeriche */
    TRTSDT = input(TRTSDTC, yymmdd10.);
    TRTEDT = input(TRTENDTC, yymmdd10.);
    BRTHDT = input(BRTHDTC, yymmdd10.);

    /* Popolazioni */
    if not missing(TRTSDT) then SAFFL = "Y";
    else SAFFL = "N";

    ITTFL = "Y";
    EFFFL = "Y";

    label
        TRTSDT = "Date of First Exposure to Treatment"
        TRTEDT = "Date of Last Exposure to Treatment"
        BRTHDT = "Date of Birth (Numeric)"
        SAFFL  = "Safety Population Flag"
        ITTFL  = "Intent-To-Treat Population Flag"
        EFFFL  = "Efficacy Population Flag";
run;

/* Ordina secondo ADaM */
data adsl_final;
    retain STUDYID USUBJID SUBJID SITEID AGE AGEU SEX RACE ETHNIC COUNTRY
           ARMCD ARM ACTARMCD ACTARM TRTSDT TRTEDT BRTHDT
           SAFFL ITTFL EFFFL;
    set adsl;
run;

/* Esportazione in CSV */
proc export data=adsl_final
    outfile="/home/u64139722/adam/adsl.csv"
    dbms=csv
    replace;
run;

/* Rinomina variabile per compatibilità XPT */
data adsl_export;
    set adsl_final;
    length ACTARMRS $200;
    ACTARMRS = ACTARMNRS;
    drop ACTARMNRS;
run;

/* Esportazione in XPT */
libname xptout xport "/home/u64139722/adam/adsl.xpt";

data xptout.adsl;
    set adsl_export;
run;

libname xptout clear;