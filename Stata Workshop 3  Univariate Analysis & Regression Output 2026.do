
*Stata Workshop 3  Univariate Analysis & Regression Output 2026  @author: Dr. You Zhou, Leeds University Business School

*********************************
*note 1: prepare examples data
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

*******************************************
*note 2: take leads and lags for panel data
*******************************************
use example.dta,clear

*please always sort your data properly before take leads or lags!!!
*take lags
sort company year 
by company: gen total_asset_lag1 = total_asset[_n-1]
by company: gen bm_lag1 = bm[_n-1]
by company: gen ratings_lag1 = ratings[_n-1]
by company: gen liability_lag1 = liability[_n-1]


*take leads 
by company: gen total_asset_lead1 = total_asset[_n+1]
by company: gen bm_lead1 = bm[_n+1]
by company: gen ratings_lead1 = ratings[_n+1]
by company: gen liability_lead1 = liability[_n+1]
		

******************************
*note 3: drop  missing values
******************************

clear all
input str20 company year total_asset bm liability ratings roa
D 2011 1200 1.2 3200 0.3 -0.08
D 2012 1300 1.5 2800 0.6 -.003
D 2013 1500 1.6 . 0.5 0.01
E 2016 3100 0.8 1200 1.6 0.02
E 2017 . 0.6 1500 1.8 0.03
E 2018 3200 1.3 1800 1.6 0.01
F 2009 800 1.6  5000 3 0.02
F 2011 900 .  6000 2.8 0.03
F 2012 800 1.6  6600 . 0.06
F 2013 860 1.8  6800 3 0.03
end  

*install packages for rmiss2
findit rmiss2

*Run the code "findit rmiss2". Then, click "dm31 from http://www.stata.com/stb/stb26"
*Select(click here to install)-> installation complete.

*count the number of missing value in each row for certain columns
egen number_of_miss1=rmiss2(total_asset bm ratings liability)


*be very careful to use this command !!! (Please understand the importance and priority of your data columns first, then drop missing values.)
*keep if number_of_miss == 0

egen number_of_miss2=rmiss2(total_asset )

keep if number_of_miss2 == 0


******************************
*note 4: percentile rankings
******************************
use example.dta,clear

*method 1
sum bm, detail
gen bm_rank1 = 1 if bm <=  1.2 
replace bm_rank1 = 2 if bm > 1.2 & bm <=  1.35 
replace bm_rank1 = 3 if bm > 1.35 & bm <= 1.6
replace bm_rank1 = 4 if bm > 1.6 & bm != .

*method 2
ssc install quantiles
quantiles bm, gen(bm_rank2) n(4)

*method 3
ssc install egenmore
egen bm_rank3 = xtile(bm), nq(4)

*percentile rank by group
*This is more practical to use in panel data
*for example, rank companies in each year based on certain firm characteristic (e.g., bm)

*method 2 by group
bysort year: quantiles bm, gen(bm_rank2a) n(4)

*method 3 by group
egen bm_rank3a = xtile(bm), by(year) nq(4)

*be careful to use method 2 and method 3 since they may give different results in small samples
*Please always check your ranking variables after running commands

*******************************************
*note 5: t-tests and output specific values
*******************************************

*1. test equality of mean
clear all
use example.dta,clear

*1.1 one sample t-test
ttest total_asset = 0

*1.2 two sample t-test of the high-bm sample and the low-bm sample
egen bm_rank = xtile(bm), by(year) nq(2)

ttest total_asset = 0 if bm_rank ==1
ttest total_asset = 0 if bm_rank ==2

ttest total_asset, by(bm_rank)

*see t-test outputs
return list

*store t-test outputs
gen v1 = r(t)
gen v2 = r(p)
keep v1 v2
duplicates drop v1 ,force
list

*output to excel
capture erase ttest_statistics.xlsx
export excel using "ttest_statistics.xlsx", sheet("use") firstrow(variables) replace


*2. test equality of meadian -> ( you could choose 2.1 the Wicloxon signed rank test or  2.2 the sign test)
clear all
use example.dta,clear

*2.1 find the median value first

*find the median value first
*see the 50th Percentile (median) of total_asset

sum total_asset,detail


*2.1.1 Wicloxon signed rank test (one sample)

signrank total_asset = 0

*two sample test of median
egen bm_rank = xtile(bm), by(year) nq(2)

sum total_asset if bm_rank ==1

signrank total_asset = 0 if bm_rank ==1

sum total_asset if bm_rank ==1


signrank total_asset = 0 if bm_rank ==2

ranksum total_asset, by(bm_rank)

return list
gen v1 = r(z)
keep v1 
duplicates drop v1 ,force
list
capture erase test_statistics.xlsx
export excel using "test_statistics.xlsx", sheet("use") firstrow(variables) replace

*more details see
help signrank

*2.1.2 Sign test could also be used to test the equality of meadian
clear all
use example.dta,clear

signtest total_asset = 0

return list

*more details see
help signtest


***********************
*note 6: one-way anova 
***********************

ssc install egenmore

use example.dta,clear
egen size_rank = xtile(total_asset), nq(4)
oneway bm size_rank , tabulate


*********************************
*note 7: regress and output specific values
*********************************

use example.dta,clear

reg total_asset bm liability ratings

*see regression outputs
return list

matrix list r(table) 

ereturn list

matrix list e(b)  

matrix list e(V)  
 
display  e(r2)

display  e(F)

* store regression outputs as data in memory

matrix t = r(table)

matrix list t

gen v1 = t[1,1]

gen v2 = e(r2)

gen v3 = e(F)

keep v1 v2 v3 

duplicates drop v1 ,force

list

*output to excel
export excel using "reg_statistics.xlsx", sheet("use") firstrow(variables) replace


****************************************
*note 8: regress and output using outreg2
*****************************************

*install outreg2
ssc install outreg2,replace

*see the user manual of outreg2
help outreg2


* an example to use

use example.dta,clear
egen firm_id = group(company)
xtset firm_id year
label var total_asset "Total assets"
label var bm "Book-to-Market ratio"
label var liability "Total liability"
label var ratings "Ratings"
label var roa "Return on assets"

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
reg total_asset $my_var1 
outreg2 using myreg1.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 1)  addtext(control effect 1, Yes, control effect 2,Yes,control effect 3, Yes) label
reg total_asset $my_var1 liability 
outreg2 using myreg1.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 2)  addtext(control effect 1, Yes, control effect 2,Yes,control effect 3, Yes) label
reg total_asset $my_var1 liability ratings
outreg2 using myreg1.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 3)  addtext(control effect 1, Yes, control effect 2,Yes,control effect 3, Yes) label

*Table 2
capture erase myreg2.txt
capture erase myreg2.xls
reg liability $my_var1 
outreg2 using myreg2.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 1)  addtext(control effect 1, Yes, control effect 2,Yes,control effect 3, Yes) label
reg liability $my_var1 ratings 
outreg2 using myreg2.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 2)  addtext(control effect 1, Yes, control effect 2,Yes,control effect 3, Yes) label
reg liability $my_var1 ratings total_asset
outreg2 using myreg2.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 3)  addtext(control effect 1, Yes, control effect 2,Yes,control effect 3, Yes) label


*Table 3
capture erase myreg3.txt
capture erase myreg3.xls
reg total_asset $my_var1 
outreg2 using myreg3.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 1)  addtext(control effect 1, Yes, control effect 2,Yes,control effect 3, Yes) label
reg total_asset $my_var1  $my_control1
outreg2 using myreg3.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 2)  addtext(control effect 1, Yes, control effect 2,Yes,control effect 3, Yes) label
reg total_asset $my_var1  $my_control2
outreg2 using myreg3.xls, addstat(Adjusted R-squared, e(r2_a))  tstat bdec(2) tdec(2) rdec(2) parenthesis(tstat) append ctitle(title 3)  addtext(control effect 1, Yes, control effect 2,Yes,control effect 3, Yes) label


*****************************************
*note 9: regress and output using estout
*****************************************

* install estout
ssc install estout, replace

*see http://repec.org/bocode/e/estout/estout.html
*see the user manual of estout
help estout  

* an example to use
clear all
use example.dta,clear
egen firm_id = group(company)
xtset firm_id year
label var total_asset "Total assets"
label var bm "Book-to-Market ratio"
label var liability "Total liability"
label var ratings "Ratings"

global my_var1 "bm"
*global my_var1 "roa"

capture erase example.csv
eststo: reg total_asset $my_var1 
eststo: reg total_asset $my_var1 liability 
eststo: reg total_asset $my_var1 liability ratings
estout, cells(b(fmt(a3)) t(fmt(2) par)) stats(r2 N, fmt(3 0))
esttab using example.csv ,cells(b(fmt(a3)) t(fmt(2) par)) stats(r2 N, fmt(3 0))
