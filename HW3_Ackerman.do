clear
clear matrix
capture cd "C:\My documents\UNC teaching\Labor\PSID\Workfiles"
capture cd "/Users/robertackerman/Desktop/School/Labor Econ I/HW"
log using "HW3_Ackerman.log", replace

use "nsw.dta"
set more off
pause on

*1 test means for experimental group
foreach var in age educ nodegree married black hisp re74 re75  {
        ttest `var', by(treated)
}
*1 regress re78 on treated age age^2...
gen agesq=age^2
reg re78 treated age agesq educ black hisp married nodegree re74 re75

*2 generate d
gen d=1 if sample==1
replace d=0 if sample==3

*2 test means for psid comparison group
foreach var in age educ nodegree married black hisp re74 re75  {
        ttest `var', by(d)
}
*3 score set 1
probit d age agesq educ black hisp married nodegree
predict scoreset1

*3 score set 2
probit d age agesq educ black hisp married nodegree re74 re75
predict scoreset2

*3 plot d re75
graph twoway (scatter d re75), xtitle('Real Earnings 1975') ytitle('Experimental Sample Indicator')
pause

*4 compare distributions using summary statistics
sum scoreset1 if d==0, d
sum scoreset1 if d==1, d

sum scoreset2 if d==0, d
sum scoreset2 if d==1, d

*5 histograms by exper/psid group
hist scoreset1, start(0.0) width(0.05) by(d,col(1))
pause
histogram scoreset2, start(0.0) width(0.05) by(d,col(1))
pause

*6 nearest neighbor no replacement
drop if treated==1

psmatch2 d age agesq educ black hisp married nodegree, out(re78) common noreplace
psmatch2 d age agesq educ black hisp married nodegree re74 re75, out(re78) common noreplace

*7 nearest neighbor replacment
psmatch2 d age agesq educ black hisp married nodegree, out(re78) common 
psmatch2 d age agesq educ black hisp married nodegree re74 re75, out(re78) common 

gen quartiles1=.
replace quartiles1=1 if scoreset1>=0 & scoreset1<.25
replace quartiles1=2 if scoreset1>=.25 & scoreset1<.5
replace quartiles1=3 if scoreset1>=.5 & scoreset1<.75
replace quartiles1=4 if scoreset1>=.75 & scoreset1<1

psmatch2 d age agesq educ black hisp married nodegree if quartiles1==1, out(re78) common 
pstest re78, both
psmatch2 d age agesq educ black hisp married nodegree if quartiles1==2, out(re78) common 
pstest re78, both
psmatch2 d age agesq educ black hisp married nodegree if quartiles1==3, out(re78) common 
pstest re78, both
psmatch2 d age agesq educ black hisp married nodegree if quartiles1==4, out(re78) common 
pstest re78, both


gen quartiles2=.
replace quartiles2=1 if scoreset2>=0 & scoreset2<.25
replace quartiles2=2 if scoreset2>=.25 & scoreset2<.5
replace quartiles2=3 if scoreset2>=.5 & scoreset2<.75
replace quartiles2=4 if scoreset2>=.75 & scoreset2<1

psmatch2 d age agesq educ black hisp married nodegree re74 re75 if quartiles2==1, out(re78) common 
pstest re78, both
psmatch2 d age agesq educ black hisp married nodegree re74 re75 if quartiles2==2, out(re78) common 
pstest re78, both
psmatch2 d age agesq educ black hisp married nodegree re74 re75 if quartiles2==3, out(re78) common 
pstest re78, both
psmatch2 d age agesq educ black hisp married nodegree re74 re75 if quartiles2==4, out(re78) common 
pstest re78, both

*8 bootstrap se
psmatch2 d age agesq educ black hisp married nodegree re74 re75, out(re78)  common
set seed 1
bootstrap r(att), reps (10): psmatch2 d age agesq educ black hisp married nodegree re74 re75, out(re78)  common
set seed 1
bootstrap r(att), reps (100): psmatch2 d age agesq educ black hisp married nodegree re74 re75, out(re78)  common

*9 regression-adjusted estimator
psmatch2 d age agesq educ black hisp married nodegree re74 re75, out(re78) common 
reg re78 age agesq educ black hisp married nodegree re74 re75 d [fweight=_weight]

*10 gaussian kernel
psmatch2 d age agesq educ black hisp married nodegree re74 re75, kernel out(re78) k(normal) bw(0.02) common 
psmatch2 d age agesq educ black hisp married nodegree re74 re75, kernel out(re78) k(normal) bw(0.2) common 
psmatch2 d age agesq educ black hisp married nodegree re74 re75, kernel out(re78) k(normal) bw(2) common 

*/
*11 local linear
psmatch2 d age agesq educ black hisp married nodegree re74 re75, llr out(re78) bw(0.02) common 
psmatch2 d age agesq educ black hisp married nodegree re74 re75, llr out(re78) bw(0.2) common 
psmatch2 d age agesq educ black hisp married nodegree re74 re75, llr out(re78) bw(2) common 


log close





















