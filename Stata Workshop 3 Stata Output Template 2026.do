*Stata Workshop 3 Stata Output Template 2026  @author: Dr. You Zhou, Leeds University Business School

*install commands first
ssc install outreg2,replace
ssc install asdoc,replace
ssc install reghdfe,replace
ssc install ftools,replace
ssc install require

set more off

*check your working directory
cd

*********************************
*step 1: prepare example data
*********************************
clear all
input str20 company year total_asset bm 
A 2010 1000 1.2  30
A 2011 1200 1.5  28
A 2012 1300 1.4  26
B 2010 3000 0.8  6
B 2011 3200 0.9  6.5
B 2012 3300 1.2  8
C 2010 600 1.6  
C 2011 900 1.8 
C 2012 800 1.3
end  
save data1.dta,replace

clear all
input year index1 index2 index3
2009 30 56 65
2010 26 67 35
2011 38 61 23
2012 39 58 13
2013 23 58 66
end
save data2.dta,replace

clear all
input str20 company year liability ratings roa 
A 2009 800 3.2 0.03
A 2011 1100 2.5 0.04
A 2012 1200 6.4 0.02
B 2010 2000 2.8 -0.01
B 2011 2200 4.9  -.003
B 2012 2300 6.2  -.005
C 2010 300 1.8 0.08
C 2011 500 2.8 0.06
C 2012 600 2.3 0.065
end  
save data3.dta,replace

clear all
input str20 company year total_asset bm liability ratings roa
D 2011 1200 1.2 3200 0.3 -0.08
D 2012 1300 1.5 2800 0.6 -.003
D 2013 1500 1.6 3000 0.5 0.01
E 2016 3100 0.8 1200 1.6 0.02
E 2017 3600 0.6 1500 1.8 0.03
E 2018 3200 1.3 1800 1.6 0.01
F 2009 800 1.6  5000 3 0.02
F 2011 900 1.3  6000 2.8 0.03
F 2012 800 1.6  6600 2.6 0.06
F 2013 860 1.8  6800 3 0.03
end  
save data4.dta,replace

clear all
use data1.dta,replace
merge 1:1 company year using data3
keep if _merge == 3
drop _merge

append  using data4

save example.dta,replace

*Always check your datasets after merging or appending!!
*Don't forget to do data cleaning!!

*********************************
*Step 2: summary and output it
*********************************
use example.dta,clear

sum total_asset bm liability ratings

*install the command outreg2
*ssc install outreg2

capture erase sum.xls
capture erase sum.txt
set matsize 10000
outreg2 using sum.xls, replace sum(detail) keep( total_asset bm liability ratings) eqkeep( N mean sum sd min p25 p50 p75 max)  label

*********************************************
*step 3: calculate correlations and output it
*********************************************
use example.dta,clear

corr total_asset bm liability ratings

*install the command asdoc
*ssc install asdoc

* output using word file
capture erase  Myfile.doc
asdoc cor total_asset bm liability ratings

capture erase  Myfile.doc
asdoc cor total_asset bm liability ratings, label replace

capture erase  Myfile.doc
asdoc pwcorr total_asset bm liability ratings, star(all) label replace nonum

* output using excel files
capture erase  correlations.xlsx
putexcel set correlations.xlsx, modify
corr total_asset bm liability ratings
return list
matrix list r(C)
putexcel A1=matrix(r(C)), names

*find the correlations.xlsx in your working directory using "pwd" command
pwd

*****************************************
*step 4: regress and output using outreg2 
*****************************************

use example.dta,clear
egen firm_id = group(company)
xtset firm_id year

label var total_asset "Total assets"
label var bm "Book-to-Market ratio"
label var liability "Total liability"
label var ratings "Ratings"
label var roa "Return on assets"

*take leads or lags in panel data
/*take leads*/
sort company year
by company: gen total_asset_lead1=total_asset[_n+1]

/*take lags*/
sort company year
by company: gen bm_lag1=bm[_n-1] 


*regressions
capture erase myreg.txt
capture erase myreg.xls

reg total_asset_lead1 bm 
outreg2 using myreg.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 1)  addtext(control effect 1, Yes, control effect 2,Yes,control effect 3, Yes) label
reg total_asset_lead1 bm liability 
outreg2 using myreg.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 2)  addtext(control effect 1, Yes, control effect 2,Yes,control effect 3, Yes) label
reg total_asset_lead1 bm liability ratings
outreg2 using myreg.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 3)  addtext(control effect 1, Yes, control effect 2,Yes,control effect 3, Yes) label

*Add fix effects
capture erase myreg_fix.txt
capture erase myreg_fix.xls
*Fix year effect
reg total_asset_lead1 bm liability ratings i.year
outreg2 using myreg_fix.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 1)  addtext(Year fix effect, Yes, control effect 2,Yes,control effect 3, Yes) label
*Fix firm effect
reg total_asset_lead1 bm liability ratings i.firm_id
outreg2 using myreg_fix.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 2)  addtext(Firm fix effect, Yes, control effect 2,Yes,control effect 3, Yes) label

*Add Fix Year/Firm effects reghdfe
capture erase myreg_fix2.txt
capture erase myreg_fix2.xls
*Fix year effect
reghdfe total_asset_lead1 bm liability ratings,absorb(year)
outreg2 using myreg_fix2.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 1)  addtext(Year fix effect, Yes, control effect 2,Yes,control effect 3, Yes) label
*Fix firm effect
reghdfe total_asset_lead1 bm liability ratings ,absorb(firm_id)
outreg2 using myreg_fix2.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 2)  addtext(Firm fix effect, Yes, control effect 2,Yes,control effect 3, Yes) label


************************************************************
*step 5: regress and output using outreg2 and macro variables
************************************************************

use example.dta,clear
egen firm_id = group(company)
xtset firm_id year

label var total_asset "Total assets"
label var bm "Book-to-Market ratio"
label var liability "Total liability"
label var ratings "Ratings"
label var roa "Return on assets"

/*take leads*/
sort company year
by company: gen total_asset_lead1=total_asset[_n+1]
by company: gen liability_lead1=liability[_n+1]

***********************************
*your key independent variable X
***********************************
global my_var1 "bm"
*global my_var1 "roa"

************************
*your control variables
************************
global my_control1 "liability"
global my_control2 "liability ratings"

*Table 1
capture erase myreg1.txt
capture erase myreg1.xls
reg total_asset_lead1 $my_var1 
outreg2 using myreg1.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 1)  addtext(control effect 1, Yes, control effect 2,Yes,control effect 3, Yes) label
reg total_asset_lead1 $my_var1 liability 
outreg2 using myreg1.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 2)  addtext(control effect 1, Yes, control effect 2,Yes,control effect 3, Yes) label
reg total_asset_lead1 $my_var1 liability ratings
outreg2 using myreg1.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 3)  addtext(control effect 1, Yes, control effect 2,Yes,control effect 3, Yes) label

*Table 2
capture erase myreg2.txt
capture erase myreg2.xls
reg liability_lead1 $my_var1 
outreg2 using myreg2.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 1)  addtext(control effect 1, Yes, control effect 2,Yes,control effect 3, Yes) label
reg liability_lead1 $my_var1 ratings 
outreg2 using myreg2.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 2)  addtext(control effect 1, Yes, control effect 2,Yes,control effect 3, Yes) label
reg liability_lead1 $my_var1 ratings total_asset
outreg2 using myreg2.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 3)  addtext(control effect 1, Yes, control effect 2,Yes,control effect 3, Yes) label

*Table 3
capture erase myreg3.txt
capture erase myreg3.xls
reg total_asset_lead1 $my_var1 
outreg2 using myreg3.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 1)  addtext(control effect 1, Yes, control effect 2,Yes,control effect 3, Yes) label
reg total_asset_lead1 $my_var1  $my_control1
outreg2 using myreg3.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 2)  addtext(control effect 1, Yes, control effect 2,Yes,control effect 3, Yes) label
reg total_asset_lead1 $my_var1  $my_control2
outreg2 using myreg3.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 3)  addtext(control effect 1, Yes, control effect 2,Yes,control effect 3, Yes) label

