************************************************************************************************************
*Stata Workshop 2 Data Collection & Merging Process   @author: Dr. You Zhou, Leeds University Business School
************************************************************************************************************
*Window system users: Select codes first, then press "CTRL + D" to run them 

*****************************************************************
*Note 1: pwd : display or change the path of working directory
*****************************************************************
pwd
cd
*cd "M:\stata"

************************************************
*Note 2: prepare example Excel datasets
************************************************

*Prepare 4 datasets first
*str20 tells Stata it is a string variable and that it could be up to 20 characters wide.

*Dataset 1 Firm-Year Data Panel
clear all
input str20 company year total_asset bm 
A 2010 1000 1.2
A 2011 1200 1.5 
A 2012 1300 1.4
A 2012 1305 1.5 
B 2010 3000 0.8
B 2011 3200 0.9 
B 2012 3300 1.2 
C 2010 600 1.6 
C 2011 900 1.8 
C 2012 800 1.3
end 

*save data1.dta,replace

export excel using "excel_data1.xlsx", firstrow(variables) replace

*Dataset 2 Year Time series Data 
clear all
input year index1 index2 index3
2009 30 56 65
2010 26 67 35
2011 38 61 23
2012 39 58 13
2013 23 58 66
end

*save data2.dta,replace

export excel using "excel_data2.xlsx", firstrow(variables) replace


*Dataset 3 Firm-Year Data Panel
clear all
input str20 company year liability ratings 
A 2009 800 3.2
A 2011 1100 2.5 
A 2012 1200 6.4 
B 2010 2000 2.8
B 2011 2200 4.9 
B 2012 2300 6.2 
C 2010 300 1.8 
C 2011 500 2.8 
C 2012 600 2.3
end  

*save data3.dta,replace

export excel using "excel_data3.xlsx", firstrow(variables) replace

*Dataset 4 Firm-Year Data Panel
clear all
input str20 company year equity roa
A 2011 1200 1.2
A 2012 1300 1.5 
A 2013 1500 1.6 
B 2011 3100 0.8
B 2012 3600 0.6 
B 2013 3200 1.3 
C 2009 800 1.6 
C 2011 900 1.3 
C 2012 800 1.6
end
  
*save data4.dta,replace

export excel using "excel_data4.xlsx", firstrow(variables) replace

************************************************
*Note 2:  download excel data from WRDS or Bloomberg
************************************************

/*import your datasets and save it as Stata <dta> datasets*/

*import excel data
import excel "excel_data1.xlsx", sheet("Sheet1") firstrow clear
*save it as one Stata <dta> dataset
save data1.dta,replace

import excel "excel_data2.xlsx", sheet("Sheet1") firstrow clear
save data2.dta,replace

import excel "excel_data3.xlsx", sheet("Sheet1") firstrow clear
save data3.dta,replace

import excel "excel_data4.xlsx", sheet("Sheet1") firstrow clear
save data4.dta,replace


**********************************************
*Note 3: data cleaning process-drop duplicates
**********************************************

*data1 has one duplicate observation for Company A in 2012
/*
clear all
input str20 company year total_asset bm 
A 2010 1000 1.2
A 2011 1200 1.5 
A 2012 1300 1.4
A 2012 1305 1.5 
B 2010 3000 0.8
B 2011 3200 0.9 
B 2012 3300 1.2 
C 2010 600 1.6 
C 2011 900 1.8 
C 2012 800 1.3
end 
*/

*clean the duplicate observations
use data1.dta,clear
duplicates drop company year, force
save data1.dta,replace


************************
*Note 4: data merging process 
************************

**************************
*4.1 Dataset 1 + Dataset 2
**************************
clear all
use data1.dta,replace
merge m:1 year using data2

sort company year

*if we keep the matched observations
keep if _merge == 3
drop _merge

************************************
*4.2 Dataset 1 + Dataset 2+Dataset 3
************************************

merge 1:1 company year using data3

/*Check these three lines after you already clearly understand the merging process.Here we don't have duplicates in both master file and the using file. Both master file and the using file are clean and are uniquely identified by company and year.

merge m:m company year using data3
merge m:1 company year using data3
merge 1:m company year using data3
 */

*make it easier to read the data panel
sort company year

*if we keep the matched observations
keep if _merge == 3
drop _merge

**********************************************
*4.3 Dataset 1+ Dataset 2+Dataset 3+ Dataset 4
**********************************************

merge 1:1 company year using data4

sort company year

*if we keep the matched observations
keep if _merge == 3
drop _merge

*save the final sample as a Stata dataset.

save sample.dta,replace

*Always check your datasets after merging or appending!!

*Check sample descriptive statistics

describe

summarize

correlate

****************************
*Note 5: take lags and leads
****************************

use sample.dta,replace

/*take lags*/
sort company year
by company: gen bm_lag1_correct=bm[_n-1] /*This is correct to take lags in panel data*/

/*take leads*/
sort company year
by company: gen bm_lead1_correct=bm[_n+1] /*This is correct to take leads in panel data*/


*************************************************************
*Note 6: prepare subsamples for robustness tests
*************************************************************
clear all
use sample.dta,replace

keep if bm > 1
keep if year > 2011
keep if total_asset >900

*And command "&"
clear all
use sample.dta,replace
keep if bm > 1  & year > 2010 & total_asset >900

*prepare 1st subsample
save subsample1.dta,replace

*or command "| "
clear all
use sample.dta,replace
keep if year > 2011 | total_asset >3000

*prepare 2nd subsample 
save subsample2.dta,replace




