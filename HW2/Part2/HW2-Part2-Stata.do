******
*HW2**
******

* Load data
import delimited "vaping-ban-panel.csv", clear

* Convert to panel
xtset stateid year

* Create a dummy variable to indicate the year when the treatment started. 
gen post = 0
replace post = 1 if year >= 2021

* Create a dummy variable to identify the state exposed to the treatment. 
bysort stateid: egen treated = max(vapingban)

* Create an interaction between time and treated. We will call this interaction `did'.
gen did = post*treated

* Use a regression to evaluate the parallel trends requirement
xtreg lunghospitalizations treated i.year if year <= 2021
*ssc install outreg2, replace
outreg2 using pretrends_test_reg.tex, replace tex ///
    keep(treated) ///
    nocons bdec(3) sdec(3) ///
    title("\textbf{Pre-trends Test: Effect on Lung Hospitalizations}") ///
    ctitle("\textbf{Lung Hospitalizations}") ///
    addnote("\textbf{Notes:} Model include state and year fixed effects. ")
	

* Create visual test of parallel trends

didregress (lunghospitalizations) (did), group(stateid) time(year)
estat trendplots
graph export "trend_plot.png", replace width(2000)



* DID with year and state fixed effects 
reg lunghospitalizations i.treated##i.post i.year i.stateid
* Test if state fixed effects are jointly zero, store results
testparm i.stateid
local f_test = string(r(F), "%9.2f")
local p_val = string(r(p), "%9.3f")

* Export with F-test results
outreg2 using did_twfe_reg.tex, replace tex ///
    keep(1.treated 1.post 1.treated#1.post) ///
    nocons bdec(3) sdec(3) ///
    title("\textbf{Effect of Vaping Ban on Lung Hospitalizations}") ///
    addnote("\textbf{Notes:} Model include state and year fixed effects.")

* Count number of state fixed effects
codebook stateid

