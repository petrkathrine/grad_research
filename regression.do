drop name 

destring notrural_shr poverty_shr pop, replace force

drop log_G1 log_G2 log_G3

gen isRep=0
replace isRep = 1 if id <= 16 | id == 75 | id ==  76 | id == 77 | id == 79 | id == 80 | id == 94
gen G_sum = G1 + G2
drop if G1 == . & G2 == . 

drop if Party_num == .
drop if President_num == .


gen logG1 = log(G1+1)
gen logG2 = log(G2+1)
gen logG_sum = log(G_sum+1)

gen President_shr = President_num/President_voters
gen Party_shr = Party_num/Party_voters

gen rural = 100 - notrural_shr

gen ifPartyEl
replace ifPartyEl = 1 if year == 2003 | year == 2007 | year == 2011 | year == 2016 | year == 2021
gen ifPresEl
replace ifPresEl = 1 if year == 2004 | year == 2008 | year == 2012 | year == 2018


//Description&Regression

cd "C:\Users\HP\Desktop\Диплом Катя\Диплом 2023\GraphsTables" C:\Users\HP\Desktop\Диплом Катя\Диплом 2023\GraphsTables
use "C:\Users\HP\Desktop\Диплом Катя\Диплом 2023\Code\merged.dta", clear

sort region year

tabulate isRep

eststo: summarize G1 G2 G3 income Party_num Party_shr notrural_shr poverty_shr pop i.isRep
esttab using table1.tex, mean sd min max label
estimates clear 

tabulate isRep, summarize(G1)

estpost tabstat G1 G2 G3 income Party_shr, by(isRep) stat(mean sd min max) long format
tabstat G1 G2 G3 income Party_shr, by(period) stat(mean sd min max) long format

tabstat G1 G2 G3 income President_shr, by(isRep) stat(mean sd min max) long format
tabstat G1 G2 G3 income President_shr, by(period) stat(mean sd min max) long format


histogram G1
histogram G2
histogram G3


histogram log_G1
histogram log_G2
histogram log_G3

correlate G1 G2 G3 Party_shr 
correlate G1 G2 G3 President_shr 


foreach var of varlist G1 G2 G_sum{
reg `var' President_shr income rural poverty_shr pop isRepublic, vce(robust) if year == 2008
}

//

foreach var of varlist G1 G2 G_sum {
reghdfe `var' Party_shr income rural poverty_shr pop, absorb(id period_party) vce(robust) 
}
foreach var of varlist G1 G2 G_sum{
reghdfe `var' President_shr income rural poverty_shr pop, absorb(id period_pres) vce(robust) 
}

//

foreach var of varlist logG1 logG2 logG_sum {
eststo: reghdfe `var' Party_shr income rural poverty_shr pop, absorb(id period_party) vce(robust) 
}

foreach var of varlist logG1 logG2 logG_sum{
eststo: reghdfe `var' President_shr income rural poverty_shr pop, absorb(id period_pres) vce(robust) 
}
esttab using logG_both.tex, se label replace

//
est clear

eststo: reghdfe logG1 Party_shr income poverty_shr pop, absorb(id period_party) vce(robust)
eststo: reghdfe logG1 Party_shr income rural poverty_shr pop, absorb(id period_party) vce(robust)
 
eststo: reghdfe logG2 Party_shr income poverty_shr pop, absorb(id period_party) vce(robust) 
eststo: reghdfe logG2 Party_shr income rural poverty_shr pop, absorb(id period_party) vce(robust) 

esttab using logG_both_Party.tex, se label replace

//
est clear

eststo: reghdfe logG1 President_shr income poverty_shr pop, absorb(id period_pres) vce(robust)
eststo: reghdfe logG1 President_shr income rural poverty_shr pop, absorb(id period_pres) vce(robust)
 
eststo: reghdfe logG2 President_shr income poverty_shr pop, absorb(id period_pres) vce(robust) 
eststo: reghdfe logG2 President_shr income rural poverty_shr pop, absorb(id period_pres) vce(robust) 

esttab using logG_both_President.tex, se label replace
//

гранты раздичие
As it was said before, there are two types of main grants - *names*. The first grant type is determined by the formula consisting income per capita and etc???, while the second one is less formalized and lacks a determined algorith of distribution.
 
лотации другого типа в 
Another variable is a grant of the another type. In some cases, the amount of grant of one type can be low because of high level of other type. Therefore, we add the variable L.logGRANT_-i. The anicipated effect is negative.
Moreover, we need to control for the previous year??? grants (logGRANT_1) to exclude the effect of situation when the amount of grants today is affected by the grants given in previuos year???. The predicted effect is negative at least for the grants of type 1.

описпние модели
The panel with fixed effects absorbs cross ??? of id and period to measure variance??? of average electoral support in every period. Robust assessing is used???

значение лагов
However, there is a high possibility that not only has the votings an influence on grants' amounts but vice versa too. Thus, it causes the acute problem of endogeneity. The solution is to introduce lagged variables indicating the political capital.
The four models are built for every cross selection??? of the grant types and the types of voting. The first one has no lagged variables. Then, the voting variable lags are gradually added to the next two models (L.VOTING, L2.VOTING). The last one consists one more lag of the opposite grant type logarithm (L2.logGRANT_-i). 

интерпрритация

1. logGRANT_1 and PRESIDENT: L.logGRANT_1 logGRANT_2 logINCOME POVERTY 
2. logGRANT_2 and PRESIDENT: L.logGRANT_2 logGRANT_1 L.PRESIDENT 
3. logGRANT_1 and PARTY: 
4. logGRANT_2 and PARTY

//

xtset
est clear
eststo: reghdfe logG1 l(1).logG1 logG2 President_shr logincome rural poverty_shr logpop, absorb(id#period_pres) vce(robust)
eststo: reghdfe logG1 l(1).logG1 logG2 l(1).President_shr logincome rural poverty_shr logpop, absorb(id#period_pres) vce(robust)
eststo: reghdfe logG1 l(1).logG1 logG2 l(1/2).President_shr logincome rural poverty_shr logpop, absorb(id#period_pres) vce(robust)
eststo: reghdfe logG1 l(1/2).logG1 logG2 l(1/2).President_shr logincome rural poverty_shr logpop, absorb(id#period_pres) vce(robust)
esttab, se label
esttab using logG1_President.tex, se label replace

est clear
eststo: reghdfe logG2 l(1).logG2 logG1 l(0).President_shr logincome rural poverty_shr logpop, absorb(id#period_pres) vce(robust)
eststo: reghdfe logG2 l(1).logG2 logG1 l(1).President_shr logincome rural poverty_shr logpop, absorb(id#period_pres) vce(robust)
eststo: reghdfe logG2 l(1).logG2 logG1 l(1/2).President_shr logincome rural poverty_shr logpop, absorb(id#period_pres) vce(robust)
eststo: reghdfe logG2 l(1/2).logG2 logG1 l(1/2).President_shr logincome rural poverty_shr logpop, absorb(id#period_pres) vce(robust)
esttab, se label
esttab using logG2_President.tex, se label replace


est clear
eststo: reghdfe logG1 l(1).logG1 logG2 l(0).Party_shr logincome rural poverty_shr logpop, absorb(id#period_party) vce(robust)
eststo: reghdfe logG1 l(1).logG1 logG2 l(1).Party_shr logincome rural poverty_shr logpop, absorb(id#period_party) vce(robust)
eststo: reghdfe logG1 l(1).logG1 logG2 l(1/2).Party_shr logincome rural poverty_shr logpop, absorb(id#period_party) vce(robust)
eststo: reghdfe logG1 l(1/2).logG1 logG2 l(1/2).Party_shr logincome rural poverty_shr logpop, absorb(id#period_party) vce(robust)
esttab, se label
esttab using logG1_Party.tex, se label replace


est clear
eststo: reghdfe logG2 l(1).logG2 logG1 Party_shr logincome rural poverty_shr logpop, absorb(id#period_party) vce(robust)
eststo: reghdfe logG2 l(1).logG2 logG1 l(1).Party_shr logincome rural poverty_shr logpop, absorb(id#period_party) vce(robust)
eststo: reghdfe logG2 l(1).logG2 logG1 l(1/2).Party_shr logincome rural poverty_shr logpop, absorb(id#period_party) vce(robust)
eststo: reghdfe logG2 l(1/2).logG2 logG1 l(1/2).Party_shr logincome rural poverty_shr logpop, absorb(id#period_party) vce(robust)
esttab, se label
esttab using logG2_Party.tex, se label replace
///
xi: xtabond2 logG2 l.logG2 Party_shr income rural poverty_shr pop i.year, gmm(Party_shr l.logG2, collapse) twostep nolevel iv(i.year income rural poverty_shr pop, eq(level))
xi: xtabond2 logG2 l.logG2 l(1).Party_shr income rural poverty_shr pop i.year if ifPartyEl ==1, gmm(l(1).Party_shr l.logG2, collapse) twostep nolevel
//

xtset id year
est clear
eststo: reghdfe logG1 logG2 Party_shr logincome rural poverty_shr logpop if ifPartyEl==1, absorb(id year) cluster(id)
eststo: reghdfe f.logG1 logG1 f.logG2 Party_shr f.logincome f.rural f.poverty_shr f.logpop if ifPartyEl==1, absorb(id year) cluster(id)
eststo: reghdfe f(2).logG1 logG1 f(2).logG2 Party_shr f(2).logincome f(2).rural f(2).poverty_shr f(2).logpop if ifPartyEl==1, absorb(id year) cluster(id)
eststo: reghdfe f(3).logG1 logG1 f(3).logG2 Party_shr f(3).logincome f(3).rural f(3).poverty_shr f(3).logpop if ifPartyEl==1, absorb(id year) cluster(id)
esttab, se label


test L1.Party_shr + L2.Party_shr = 0

//

1. ifPresEl
2. f.ifPresEl
3. l(1).ifPresEl##l(1)c.President_shr
4. ifPresEl l(1).ifPresEl##l(1)c.President_shr f.ifPresEl


est clear
eststo: reghdfe logG1 l.logG1 logG2 ifPresEl logincome rural poverty_shr logpop, absorb(id year_pres) vce(robust)
eststo: reghdfe logG1 l.logG1 logG2 f(1).ifPresEl logincome rural poverty_shr logpop, absorb(id year_pres) vce(robust)
eststo: reghdfe logG1 l.logG1 logG2 l(1).ifPresEl##l(1)c.President_shr logincome rural poverty_shr logpop, absorb(id year_pres) vce(robust)
eststo: reghdfe logG1 l.logG1 logG2 ifPresEl f(1).ifPresEl l(1).ifPresEl##l(1)c.President_shr logincome rural poverty_shr logpop, absorb(id year_pres) vce(robust)
esttab, se label
esttab using logG1_Pres.tex, se label replace

est clear
eststo: reghdfe logG2 l.logG2 logG1 ifPresEl logincome rural poverty_shr logpop, absorb(id year_pres) vce(robust)
eststo: reghdfe logG2 l.logG2 logG1 f(1).ifPresEl logincome rural poverty_shr logpop, absorb(id year_pres) vce(robust)
eststo: reghdfe logG2 l.logG2 logG1 l(1).ifPresEl##l(1)c.President_shr logincome rural poverty_shr logpop, absorb(id year_pres) vce(robust)
eststo: reghdfe logG2 l.logG2 logG1 ifPresEl f(1).ifPresEl l(1).ifPresEl##l(1)c.President_shr logincome rural poverty_shr logpop, absorb(id year_pres) vce(robust)
esttab, se label
esttab using logG2_Pres.tex, se label replace


est clear
eststo: reghdfe logG1 l.logG1 logG2 ifPartyEl logincome rural poverty_shr logpop, absorb(id year_party) vce(robust)
eststo: reghdfe logG1 l.logG1 logG2 f(1).ifPartyEl logincome rural poverty_shr logpop, absorb(id year_party) vce(robust)
eststo: reghdfe logG1 l.logG1 logG2 l(1).ifPartyEl##l(1)c.Party_shr logincome rural poverty_shr logpop, absorb(id year_party) vce(robust)
eststo: reghdfe logG1 l.logG1 logG2 ifPartyEl f(1).ifPartyEl l(1).ifPartyEl##l(1)c.Party_shr logincome rural poverty_shr logpop, absorb(id year_party) vce(robust)

esttab, se label
esttab using logG1_Party.tex, se label replace

est clear
eststo: reghdfe logG2 l.logG2 logG1 ifPartyEl logincome rural poverty_shr logpop, absorb(id year_party) vce(robust)
eststo: reghdfe logG2 l.logG2 logG1 f(1).ifPartyEl  logincome rural poverty_shr logpop, absorb(id year_party) vce(robust)
eststo: reghdfe logG2 l.logG2 logG1 l(1).ifPartyEl##l(1)c.Party_shr logincome rural poverty_shr logpop, absorb(id year_party) vce(robust)
eststo: reghdfe logG2 l.logG2 logG1 ifPartyEl f(1).ifPartyEl l(1).ifPartyEl##l(1)c.Party_shr logincome rural poverty_shr logpop, absorb(id year_party) vce(robust)

esttab, se label
esttab using logG2_Party.tex, se label replace



L.logG2 - прошлогодние дотации того же типа
logG1 - дотации другого типа в этот же год
l(0/1).ifPresEl - эффект от того, были выборы в этот год или прошлый
f(1).ifPresEl - эффект если выборы будут в следующем году
President_shr - влияние голосвания в на прошлых выборах или в этих, если выборы в этом году
f(1).ifPresEl##c.President_shr - эффект голосов прошлого периода, если выборы в следующем году
L.year_pres  - эффект выборного периода разных лет
//


// Check for republics only
est clear
eststo: reghdfe logG1 l.logG1 logG2 ifPresEl f(1).ifPresEl l(1).ifPresEl##l(1)c.President_shr##isRep logincome rural poverty_shr logpop, absorb(id year_pres) vce(robust)
eststo: reghdfe logG2 l.logG2 logG1 ifPresEl f(1).ifPresEl l(1).ifPresEl##l(1)c.President_shr##isRep logincome rural poverty_shr logpop, absorb(id year_pres) vce(robust)
eststo: reghdfe logG1 l.logG1 logG2 ifPartyEl f(1).ifPartyEl l(1).ifPartyEl##l(1)c.Party_shr##isRep logincome rural poverty_shr logpop, absorb(id year_party) vce(robust)
eststo: reghdfe logG2 l.logG2 logG1 ifPartyEl f(1).ifPartyEl l(1).ifPartyEl##l(1)c.Party_shr##isRep logincome rural poverty_shr logpop, absorb(id year_party) vce(robust)

esttab, se label
esttab using logG_isRep.tex, se label replace

//check for sum_G
est clear
eststo: reghdfe logG_sum l.logG_sum l(1).ifPresEl##l(1)c.President_shr logincome rural poverty_shr logpop, absorb(id year_pres) vce(robust)
eststo: reghdfe logG_sum l.logG_sum ifPresEl f(1).ifPresEl l(1).ifPresEl##l(1)c.President_shr logincome rural poverty_shr logpop, absorb(id year_pres) vce(robust)
eststo: reghdfe logG_sum l.logG_sum l(1).ifPartyEl##l(1)c.Party_shr logincome rural poverty_shr logpop, absorb(id year_party) vce(robust)
eststo: reghdfe logG_sum l.logG_sum ifPartyEl f(1).ifPartyEl l(1).ifPartyEl##l(1)c.Party_shr logincome rural poverty_shr logpop, absorb(id year_party) vce(robust)

esttab, se label
esttab using logG_sum.tex, se label replace

//

est clear
eststo:regress logG1 l(0/2).ifPartyEl
eststo:regress logG2 l(0/2).ifPartyEl

eststo:regress logG1 l(0/2).ifPresEl
eststo:regress logG2 l(0/2).ifPresEl
