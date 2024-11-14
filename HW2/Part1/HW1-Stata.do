
***********************************
* HW1
***********************************

* Set path

import delimited "assignment1-research-methods.csv", clear

* Run regression: 
reg calledback eliteschoolcandidate malecandidate

* Store regression
eststo regression_one 

* Output using LaTeX

global tableoptions "bf(%15.2gc) sfmt(%15.2gc) prehead(\begin{tabular}{l*{14}{c}}) postfoot(\end{tabular}) se label noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast)  starlevels(* 0.1 ** 0.05 *** 0.01) replace r2"
esttab regression_one using HW1-Table.tex, $tableoptions keep(eliteschoolcandidate malecandidate) title("Effect of Elite College Education on Job Callback")
