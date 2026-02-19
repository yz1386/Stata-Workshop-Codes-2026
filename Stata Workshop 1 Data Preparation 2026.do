
********************************************************************************************
* Stata workshop 1 data preparation @author: Dr. You Zhou, Leeds University Business School
********************************************************************************************
/*1.Check working directory*/

*print working directory*
pwd

*change directory/print working directory*
cd

/*2.Set working directory*/
*cd "M:\stata"

/*3.Export/ Import data*/
clear all
input str20 company year total_asset bm return
A 2010 1000 1.2 0.01
A 2011 1200 1.5 0.02
A 2012 1300 1.4 0.03
B 2010 3000 0.8 0.02
B 2011 3200 0.9 0.01
B 2012 3300 1.2 0.02
C 2010 600 1.6 0.06
C 2011 900 1.8 0.03
C 2012 800 1.3 0.08
end  

*Export data
export excel using "example_data", sheet("Sheet1") firstrow(variables) replace

*Import data
clear all
import excel example_data.xlsx, sheet("Sheet1") firstrow

*clear all
*import excel "M:\stata\example_data.xlsx", sheet("Sheet1") firstrow


/*4.Check all variables*/
describe 

sum 

corr 

/*Check selected variables*/
describe total_asset bm

sum total_asset bm return

corr total_asset bm return

/*5.Explain functions and commands*/
help corr

/*6.install a new Stata package: ssc install + package name*/
ssc install unique

*count the number of unique companies in your sample
unique company

*count the number of unqie date(year) in your sample
unique year

