******
*HW3**
******


// Load the data

import delimited "sports-and-education.csv", clear
label variable collegeid "An identifier for each of the 100 universities."
label variable ranked "Ranked"
label variable alumnidonations2018 "Alumni Donations"
label variable academicquality "Academic Quality"
label variable athleticquality "Athletic Quality"
label variable nearbigmarket "Near Big Market"
save "sports-and-education.csv", replace

// Balance Tables

* Starter code
global balanceopts "prehead(\begin{tabular}{l*{6}{c}}) postfoot(\end{tabular}) noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast) starlevels(* 0.1 ** 0.05 *** 0.01)"

* Create and export balance table with t-tests
estpost ttest academicquality athleticquality nearbigmarket, by(ranked) unequal welch

esttab using balance_table.tex, ///
    cell("mu_1(f(3)) mu_2(f(3)) b(f(3) star)") ///
    wide ///
    label ///
    collabels("Unranked" "Ranked" "Difference") ///
    noobs ///
    $balanceopts ///
    mlabels(none) ///
    eqlabels(none) ///
    replace ///
    mgroups(none) ///
    title("Balance Table: Ranked vs Unranked Colleges") ///
    note("* p<0.1, ** p<0.05, *** p<0.01")

// PSM

* We use logistic regression to predict the probability of being ranked
logit ranked academicquality athleticquality nearbigmarket
eststo propensity_model

* Generate propensity scores
predict propensity_score, pr

esttab propensity_model using propensity_results.tex, ///
    cells(b(star fmt(3)) se(fmt(3))) ///
    label ///
    title("Logistic Regression Results: Predicting College Rankings") ///
    collabels("Coefficient") ///
    stats(N r2_p, fmt(0 3) label("Observations" "Pseudo R-squared")) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    note("* p<0.1, ** p<0.05, *** p<0.01") ///
    replace

// Histogram

* Create histogram of propensity scores by treatment status
twoway (histogram propensity_score if ranked==1, color(red%30)) ///
       (histogram propensity_score if ranked==0, color(blue%30)), ///
       legend(label(1 "Treatment (Ranked)") label(2 "Control (Unranked)")) ///
       xtitle("Predicted Probability of Being Ranked") ///
       ytitle("Density") ///
       title("Distribution of Propensity Scores")
graph export "propensity_distribution.png", replace

	
// Group Observations into Blocks
sort propensity_score
gen block = floor(_n/4)
label variable block "Propensity Score Block"

// Treatment effect with block fixed effects
regress alumnidonations2018 ranked academicquality athleticquality nearbigmarket i.block
eststo block_effects

esttab block_effects using block_effects2.tex, ///
    cells(b(star fmt(3)) se(fmt(3))) ///
    label ///
    title("Effect of Rankings on Alumni Donations with Block Fixed Effects") ///
    stats(N r2_a F, fmt(0 3 2) label("Observations" "Adjusted R-squared" "F-statistic")) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    note("* p<0.1, ** p<0.05, *** p<0.01. This table presents OLS estimates of the effect of college rankings" ///
    "on alumni donations. Block fixed effects are included to control for propensity score quartiles." ///
    "Standard errors are in parentheses. Blocks are created by grouping every 4 observations" ///
    "based on predicted probability of being ranked from the propensity score model.") ///
    replace
