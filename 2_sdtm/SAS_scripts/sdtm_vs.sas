/* Import vs file */
proc import datafile="/home/u64139722/vs.csv"
    out=vs_raw
    dbms=csv
    replace;
    guessingrows=MAX;
run;

/* Step 2: Rename numeric variables before conversion */
data vs_step1;
    set vs_raw;
    VSORRES_num = VSORRES;
    VSDTC_num = VSDTC;
    drop VSORRES VSDTC;
run;

/* Step 3: Mapping SDTM */
data vs_sdtm;
    set vs_step1(rename=(USUBJID=USUBJID_OLD)); /* salva il valore originale */

    length 
        STUDYID $20 DOMAIN $2 USUBJID $30 SUBJID $10
        VSTESTCD $8 VSTEST $40
        VSORRES $10 VSORRESU $10
        VSSTRESC $10 VSSTRESU $10
        VSSTAT $10 VSREASND $100
        VSDTC $10 VISIT $20
        VSBLFL $1 VSLOC $20 VSNAM $50;

    STUDYID = "VIRALBLOCK01";

    /* Derive SUBJID from USUBJID_OLD, e.g.: SUBJ001 → 001 */
    if substr(USUBJID_OLD, 1, 4) = "SUBJ" then do;
        SUBJID = substr(USUBJID_OLD, 5);
        USUBJID = catx("-", STUDYID, SUBJID);
    end;
    else do;
        SUBJID = USUBJID_OLD;
        USUBJID = catx("-", STUDYID, SUBJID);
    end;

    DOMAIN = "VS";

    /* Conversion numeric-to-char */
    VSORRES = strip(put(VSORRES_num, best.));
    VSDTC   = put(VSDTC_num, yymmdd10.);

    /* Standardized values */
    VSSTRESC = VSORRES;
   	VSSTRESN = input(VSORRES, ?? best.);

    if VSTESTCD = "TEMP" then VSSTRESU = "C";
    else if VSTESTCD = "SPO2" then VSSTRESU = "%";
    else VSSTRESU = "";

    if VISITNUM = 1 then VSBLFL = "Y";

    VSSTAT = "";
    VSREASND = "";
    VSLOC = "";
    VSNAM = "";

    label
        STUDYID    = "Study Identifier"
        DOMAIN     = "Domain Abbreviation"
        USUBJID    = "Unique Subject Identifier"
        SUBJID     = "Subject Identifier for the Study"
        VSSEQ      = "Sequence Number"
        VSTESTCD   = "Vital Signs Test Short Name"
        VSTEST     = "Vital Signs Test Name"
        VSORRES    = "Result or Finding in Original Units"
        VSORRESU   = "Original Units"
        VSSTRESC   = "Character Result/Finding in Std Format"
        VSSTRESN   = "Numeric Result/Finding in Std Format"
        VSSTRESU   = "Standard Units"
        VSSTAT     = "Completion Status"
        VSREASND   = "Reason Not Done"
        VSDTC      = "Date/Time of Measurement"
        VSDY       = "Study Day of Measurement"
        VISITNUM   = "Visit Number"
        VISIT      = "Visit Name"
        VSBLFL     = "Baseline Flag"
        VSLOC      = "Location of Measurement"
        VSNAM      = "Name of Evaluator or Measurement Method";
run;

/* Step 4: Order and assignment of VSSEQ */
proc sort data=vs_sdtm;
    by USUBJID VSDTC VSTESTCD;
run;

data vs_sdtm;
    set vs_sdtm;
    by USUBJID;
    retain VSSEQ;
    if first.USUBJID then VSSEQ = 1;
    else VSSEQ + 1;
run;

/* Step 5: final Dataset in SDTM order*/
data vs_final;
    retain 
        STUDYID DOMAIN USUBJID VSSEQ
        VSTESTCD VSTEST VSORRES VSORRESU
        VSSTRESC VSSTRESN VSSTRESU
        VSSTAT VSREASND
        VSDTC VSDY VISITNUM VISIT
        VSBLFL VSLOC VSNAM;
    set vs_sdtm;
    drop VSORRES_num VSDTC_num USUBJID_OLD SEX AGE ARMCD SUBJID;
run;

/* Step 6: Export in CSV */
proc export data=vs_final
    outfile="/home/u64139722/sdtm/vs.csv"
    dbms=csv
    replace;
run;

proc freq data=vs_final;
    tables VSSTAT VSBLFL VSTESTCD VSTEST / missing;
run;

/* Step 7: Export in XPT (SAS Transport) */
libname xptout xport "/home/u64139722/sdtm/vs.xpt";

data xptout.VS_FIN;
    set vs_final;
run;

libname xptout clear;