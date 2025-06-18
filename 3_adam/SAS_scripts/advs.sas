/* Step 1: Importa SDTM.VS */
proc import datafile="/home/u64139722/sdtm/vs.csv"
    out=vs
    dbms=csv
    replace;
    guessingrows=max;
run;

/* Importa ADSL per avere TRTA */
proc import datafile="/home/u64139722/adam/adsl.csv"
    out=adsl
    dbms=csv
    replace;
    guessingrows=max;
run;

/* Ordina ADSL per merge */
proc sort data=adsl(keep=USUBJID ACTARM); by USUBJID; run;
proc sort data=vs; by USUBJID; run;

/* Step 2: Deriva ADVS */
data advs;
    merge vs(in=a) adsl(rename=(ACTARM=TRTA));
    by USUBJID;
    if a;

    length PARAMCD $8 PARAM $40 AVISIT $20 AVISITN 8 ABLFL $1 TRTA $20;

    /* PARAMCD / PARAM */
    PARAMCD = VSTESTCD;
    PARAM   = VSTEST;

    /* Valori derivati standard */
    AVAL    = VSSTRESN;
    AVALC   = VSSTRESC;

    /* Baseline flag */
    if VSBLFL = "Y" then ABLFL = "Y";
    else ABLFL = "";

    /* VISIT derivato in formato AVISIT */
    AVISIT  = VISIT;
    AVISITN = VISITNUM;

    /* Variabili ADaM richieste */
    ADT = input(VSDTC, yymmdd10.);
    format ADT date9.;

    label
        USUBJID  = "Unique Subject Identifier"
        ADT      = "Analysis Date"
        AVAL     = "Analysis Value"
        AVALC    = "Character Result"
        ABLFL    = "Baseline Flag"
        PARAMCD  = "Parameter Code"
        PARAM    = "Parameter"
        AVISIT   = "Analysis Visit"
        AVISITN  = "Analysis Visit (Numeric)"
        TRTA     = "Actual Treatment";
run;

/* Step 3: Ordina e conserva le variabili ADaM */
proc sort data=advs;
    by USUBJID PARAMCD ADT;
run;

data advs_final;
    retain STUDYID USUBJID PARAMCD PARAM ADT AVAL AVALC ABLFL AVISIT AVISITN TRTA;
    set advs;
run;

/* Step 4: Esporta in CSV */
proc export data=advs_final
    outfile="/home/u64139722/adam/advs.csv"
    dbms=csv
    replace;
run;

/* Step 5: Esporta in XPT */
libname xptout xport "/home/u64139722/adam/advs.xpt";

data xptout.advs;
    set advs_final;
run;

libname xptout clear;
