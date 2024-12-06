clear 
******
*HW4**
******


// Load the data
import delimited "crime-iv.csv", clear
label variable recidivates "Convincted of a second crime"
label variable monthsinjail "Months in Jail"
label variable severityofcrime "Severity of Crime"

// Simple Regression
reg recidivates monthsinjail, robust
* Store regression
eststo regression_one 
esttab regression_one using reg1.tex, ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label ///
    title("Effect of Interaction Term on Sentence Length") ///
    nocons ///
    replace


//Balance Table
eststo clear 

global balanceopts "prehead(\begin{tabular}{l*{6}{c}}) postfoot(\end{tabular}) noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast) starlevels(* 0.1 ** 0.05 *** 0.01)"

estpost ttest severityofcrime, by(republicanjudge) unequal welch

esttab using balance_table.tex, ///
    cell("mu_1(f(3)) mu_2(f(3)) b(f(3) star)") ///
    wide ///
    label ///
    collabels("Democratic Judge" "Republican Judge" "Difference") ///
    noobs ///
    $balanceopts ///
    mlabels(none) ///
    eqlabels(none) ///
    replace ///
    mgroups(none) ///
    title("Balance Table: Cases by Judge Party Affiliation") ///
    note("* p<0.1, ** p<0.05, *** p<0.01")
	
//First Stage
eststo clear
reg monthsinjail republicanjudge severityofcrime, robust
eststo firststage
esttab firststage using firststage.tex, ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label ///
    title("First Stage: Effect of Judge Party on Sentence Length") ///
    nocons ///
    replace
	
//Reduced Form
eststo clear
reg recidivates republicanjudge severityofcrime, robust
eststo reducedform
esttab reducedform using reducedform.tex, ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label ///
    title("Reduced Form - Effect of Judge Party on Likelihood of Second Crime") ///
    nocons ///
    replace	

//2SLS
eststo clear
ivreg2 recidivates (monthsinjail = republicanjudge) severityofcrime, robust
eststo iv_reg
esttab iv_reg using iv_results.tex, ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label ///
    title("IV Results: Effect of Incarceration on Recidivism") ///
    stats(N F widstat r2 r2_a, fmt(0 2 2 3) ///
    labels("Observations" "F-statistic" "First Stage F-stat" "R-squared")) ///
    replace
	
	
//Subgroup analysis on potential defiers
eststo clear
reg monthsinjail republicanjudge if severityofcrime > 1, robust
eststo severity_g1
reg monthsinjail republicanjudge if severityofcrime <= 1, robust
eststo severity_le1

esttab severity_g1 severity_le1 using "severity_reg.tex", ///
    label ///
    b(3) se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    title("Effect of Republican Judges on Months in Jail by Crime Severity") ///
    nonumbers mtitles("Severity > 1" "Severity ≤ 1") ///
    addnote("Robust standard errors in parentheses" "*** p<0.01, ** p<0.05, * p<0.1")


//Testing the cycle of crime 
eststo clear
ivreg2 recidivates (monthsinjail = republicanjudge) severityofcrime if severityofcrime > 1, robust
eststo iv_severity_g1
ivreg2 recidivates (monthsinjail = republicanjudge) severityofcrime if severityofcrime <= 1, robust
eststo iv_severity_le1

esttab iv_severity_g1 iv_severity_le1 using "iv_severity_reg.tex", ///
    label ///
    b(3) se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    title("Effect of Months in Jail on Second Crime Likelihood by Crime Severity") ///
    nonumbers mtitles("Severity > 1" "Severity ≤ 1") ///
    addnote("Robust standard errors in parentheses" "*** p<0.01, ** p<0.05, * p<0.1")

