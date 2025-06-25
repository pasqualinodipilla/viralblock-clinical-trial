/***************************************************/
/* Survival Analysis - Serious AE (AESER = "Y")    */
/***************************************************/

/* Step 1: Import ADSL and ADAE */
proc import datafile="/home/u64139722/adam/adsl.csv"
    dbms=csv out=adsl replace;
    guessingrows=max;
run;

proc import datafile="/home/u64139722/adam/adae.csv"
    dbms=csv out=adae replace;
    guessingrows=max;
run;

/* Step 2: Get earliest date of serious AE (AESER = Y) */
proc sql;
    create table ae_serious as
    select USUBJID, min(AESTDTC) as event_dt format=yymmdd10. as event_dt format=yymmdd10.
    from adae
    where AESER = "Y" and not missing(AESTDTC)
    group by USUBJID;
quit;

/* Step 3: Merge with ADSL and calculate time-to-event */
data surv;
    merge adsl(in=a keep=USUBJID SEX AGE ARM) 
          ae_serious;  /* contiene già event_dt ricavato da AESTDTC */
    by USUBJID;
    if a;

    /* Use a proxy start date (e.g., randomization or other known) */
    start_dt = '01JAN2022'd; /* oppure un'altra data realistica nota */
    format start_dt yymmdd10.;

    time = .;
    event = 0;

    if not missing(event_dt) and not missing(start_dt) then do;
        time = event_dt - start_dt;
        event = 1;
    end;
    else if not missing(start_dt) then time = 28;

    if not missing(time);
run;


/***************************************************/
/* KM Curve + Log-rank test                        */
/***************************************************/
ods graphics on;
ods pdf file="/home/u64139722/results/km_survival_plot.pdf";

proc lifetest data=surv plots=survival(atrisk=0 to 28 by 7);
    time time*event(0);
    strata ARM;
    title "Kaplan-Meier Curve by Treatment Arm";
run;

ods pdf close;

/***************************************************/
/* Cox Proportional Hazards Model + Forest Plot   */
/***************************************************/

/* Output PDF per risultati Cox */
ods pdf file="/home/u64139722/results/cox_model.pdf";
ods graphics on;

/* Salva HR e CI per forest plot */
ods output HazardRatios=cox_hr;

proc phreg data=surv;
    class ARM(ref="Placebo") SEX / param=ref;
    model time*event(0) = ARM AGE SEX;
    hazardratio ARM / diff=ref cl=wald;
    title "Cox Proportional Hazards Model";
run;

ods graphics off;
ods pdf close;

/* Controlla il contenuto del dataset cox_hr */
proc print data=cox_hr; run;

data forest_plot;
    set cox_hr;
    logHR = log(HazardRatio);
    logLCL = log(WaldLower);
    logUCL = log(WaldUpper);

    /* Forza un'etichetta comprensibile per ciascun parametro */
    if Description =: "ARM" then Group = "Viralblock vs Placebo";
    else if Description =: "SEX" then Group = "Sex: Male vs Female";
    else Group = Description;
run;

/* Genera il forest plot */
ods pdf file="/home/u64139722/results/cox_forest_plot.pdf";
ods graphics on;

proc sgplot data=forest_plot;
    highlow y=Group low=logLCL high=logUCL / type=bar lineattrs=(thickness=2);
    scatter y=Group x=logHR / markerattrs=(symbol=circlefilled size=8);
    refline 0 / axis=x lineattrs=(pattern=shortdash color=gray);
    xaxis label="Log(Hazard Ratio)" grid;
    yaxis discreteorder=data;
    title "Forest Plot of Hazard Ratios (Cox Regression)";
run;

ods graphics off;
ods pdf close;
