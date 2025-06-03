/*Logistic regression analysis*/

/*Import AE sdtm csv file*/
proc import datafile='/home/u64139722/ae_sdtm.csv'
	out=ae_sdtm
	dbms=csv 
	replace;
	guessingrows=MAX;
run;

ods pdf file="/home/u64139722/logistic_aeser.pdf" style=journal;
title "Logistic regression: Probability of Severe AE by treatment";

/*Run logistic regression*/
proc logistic data=ae_sdtm;
	class ARMCD (param=ref ref="PBO");
	model AESER(event="Y") = ARMCD;
run;

/*close pdf output*/
ods pdf close;

ods rtf file="/home/u64139722/logistic_aeser.rtf" style=journal;
title "Logistic regression: Probability of Severe AE by treatment";

/*Run logistic regression*/
proc logistic data=ae_sdtm;
	class ARMCD (param=ref ref="PBO");
	model AESER(event="Y") = ARMCD;
run;

/*close rtf output*/
ods rtf close;