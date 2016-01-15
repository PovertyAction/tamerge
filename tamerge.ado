/*----------------------------------------*
 |file:    tamerge.ado                    |
 |authors: nate barker                    |
 |         christopher boyer              |
 |         innovations for poverty action |
 |version: v1.0							  |
 |date:    2016-01-14                     |
 *----------------------------------------*
  description:
    this file merges data from SurveyCTO text audit files with the data set in 
	memory.
*/

cap program drop tamerge;
program define tamerge
version 13

syntax varname, media(str)

// this program requires sxpose to be installed
cap which sxpose
if _rc!=0 {
	ssc install sxpose
	if _rc==631 {
		di "You are not connected to the internet. Please connect to install"
		di "this command, sxpose, before continuing"
}

// the name of the folder path where your text audit files are stored.
loc media_location `media'

// the name of the text_audit variable in the dataset in memory here.
loc auditvar `varname'

tempfile full_data audit_data
save `full_data'

// transpose
di "TRANSPOSING THE AUDIT FILES"
qui levelsof `auditvar', loc(audit_levels)
loc audit_count: word count `audit_levels'

// This loop will run through every reported instance of a file containing the audit data
forvalues j = 1/`audit_count' {
	qui loc aud: word `j' of `audit_levels'
	qui tempfile audit`j' 
	
	// This file location will be wherever your audits are stored
	qui insheet using "`media_location'\\`aud'", clear
	
	/* Here, I am stripping the group name, which is perhaps the most annoying part, since different cells
	have different numbers of groups. 
	
	First, I split the variable every time there is a "/" (so for example,
	there would be a total of 6 variables if the varname is prefaced by 5 group names). First, I split the
	variable, and determine how many variables I have created through this split. */
	
	qui replace fieldname = subinstr(fieldname, "[", "", .)
	qui replace fieldname = subinstr(fieldname, "]", "", .)
	qui split fieldname, p(/)
	qui drop fieldname
	qui unab fieldvars: fieldname*
	qui loc fieldcount: word count `fieldvars'
	
	/*
	Now, I make a variable called field name, which will have the value of interest, the variable name. 
	In every instance, the "last" value in my split will be the variable name. For example, if for a 
	particular variable, there are six fieldnames, fieldname1 - fieldname5 will be the group names, and
	fieldname6 the variable name. I therefore start at the max (`fieldcount') and assign fieldname the
	value associated with fieldname`i' if there is a nonmissing value there. I then work backwards until
	1, only filling in the values when the value is nonmissing. */
	qui gen fieldname = ""
	
	foreach i of numlist `fieldcount'(-1)1 {
		qui replace fieldname = fieldname`i' if mi(fieldname)
	}
	
	qui cap drop fieldname??
	qui drop fieldname? firstappearedsecondsintosurvey
	qui order fieldname, first
	
	/* Here, I change formats. Previously, column 1 is the varname, and column 2 is the associated value.
	However, by using sxpose, the variable fieldname now becomes the varname in Stata, and the value in
	column 2 becomes the accompanying value. This now represents one observation in the dataset rather
	than several. */
	
	qui sxpose, clear force firstnames
	
	foreach var of varlist _all {
		qui destring `var', replace
	} 
	qui gen `auditvar' = "`aud'"
	qui order `auditvar', first
	
	qui save `audit`j''
}

di "APPENDING THE VARIOUS AUDIT FILES TO EACH OTHER"
/* Now, I begin with the first audit file, and loop through all of them, appending them to the existing 
dta file. The resulting file has all of the audit files as separate observations, with all of the audit
information in a single dataset 

With the way this code is written, this dataset is separate from your main dta file. Every variable will
be the number of seconds to answer that question in the survey. You could merge this back into your main
dataset; it will require merging 1:1 on your audit identifier variable, and renaming all of the variables
in your audit dataset. 
*/

qui use `audit1', clear

forvalues j = 2/`audit_count' {
	qui append using `audit`j'', force
}

cap drop _var*
qui ds `auditvar', not
foreach var of varlist `r(varlist)' {
	rename `var' ta_`var'
}

save `audit_data'

use `full_data', clear
merge 1:1 `auditvar' using `audit_data'

end
