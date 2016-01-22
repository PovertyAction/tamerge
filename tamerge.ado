/*----------------------------------------*
 |file:    tamerge.ado                    |
 |authors: nate barker                    |
 |         christopher boyer              |
 |         innovations for poverty action |
 |version: v1.0.0						  |
 |date:    2016-01-14                     |
 *----------------------------------------*
  description:
    this file merges data from SurveyCTO text audit files with the data set in 
	memory.
*/

cap program drop tamerge
program define tamerge, rclass

	version 13

	syntax varname, media(str) [stats groupnames enum(str) prefix(str) replace]

	/* the syntax variables represent the following:
	     varname - the name of the text_audit variable in the dataset in memory.
	     media - the name of the folder path where the text audit files are stored. 
	     stats - print summary stats by enumerator.
	     prefix - change the stub that is appended to the start of the variable audit times.
	     replace - replace the 
	*/

	// ***program checks***
	local tavar `varlist'

	// check ta variable 
	parse_tavar `tavar'
	
	// check if media folder exists
	parse_media `media'

	// set cleaned locals
	local path `r(location)'

	// create temporary files
	tempfile full_data audit_data
	qui save `full_data'
		
	// transpose
	qui levelsof `tavar', loc(talevels)
	loc tacount: word count `talevels'

	// This loop will run through every reported instance of a file containing the audit data
	forvalues j = 1/`tacount' {
		qui loc tafile: word `j' of `talevels'
		qui tempfile audit`j' 
		
		// This file location will be wherever your audits are stored
		cap qui import delimited using "`path'/`tafile'", clear
		if _rc == 601 {
			di "Audit `path'/`tafile' not found, skipping this audit"
			exit
		}
		
		/* Here, I am stripping the group name, which is perhaps the most annoying part, since different cells
		have different numbers of groups. 
		
		First, I split the variable every time there is a "/" (so for example,
		there would be a total of 6 variables if the varname is prefaced by 5 group names). First, I split the
		variable, and determine how many variables I have created through this split.
		
		qui replace fieldname = subinstr(fieldname, "[", "", .)
		qui replace fieldname = subinstr(fieldname, "]", "", .) 
		*/
		replace fieldname = reverse(fieldname)
		qui split fieldname, p(/) limit(1)
		gen shortname = reverse(fieldname1)
		qui keep shortname totaldurationseconds
		
		/*
		qui unab fieldvars: fieldname*
		qui loc fieldcount: word count `fieldvars'
		
		/* Now, I make a variable called field name, which will have the value of interest, the variable name. 
		In every instance, the "last" value in my split will be the variable name. For example, if for a 
		particular variable, there are six fieldnames, fieldname1 - fieldname5 will be the group names, and
		fieldname6 the variable name. 

		I therefore start at the max (`fieldcount') and assign fieldname thevalue associated with
		fieldname`i' if there is a nonmissing value there. I then work backwards until
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
		*/
		local nobs = _N 

		forvalues i = 1/`nobs' {
			local lbl`i' = shortname[`i']
		}

		drop shortname
		xpose, clear

		forvalues i = 1/`nobs' {
			rename v`i' `lbl`i''
		}

		qui gen `tavar' = "`tafile'"
		qui order `tavar', first
		
		qui save `audit`j''
	}

	/* Now, I begin with the first audit file, and loop through all of them, appending them to the existing 
	dta file. The resulting file has all of the audit files as separate observations, with all of the audit
	information in a single dataset 

	With the way this code is written, this dataset is separate from your main dta file. Every variable will
	be the number of seconds to answer that question in the survey. You could merge this back into your main
	dataset; it will require merging 1:1 on your audit identifier variable, and renaming all of the variables
	in your audit dataset. */

	cap qui use `audit1', clear
	if _rc == 601 {
		clear
	}

	forvalues j = 2/`tacount' {
		/* This cap again is for instances where the media file cannot be found (eg when SurveyCTO
		Sync fails to download all of the files */
		cap qui append using `audit`j'', force
	}

	cap drop _var*
	qui ds `tavar', not
	foreach var of varlist `r(varlist)' {
		rename `var' ta_`var'
	}

	qui save `audit_data'

	use `full_data', clear
	qui merge 1:1 `tavar' using `audit_data'
	qui drop _merge
end

cap program drop parse_tavar
// program to check that specified variable is a SurveyCTO text audit field
program parse_tavar, sclass
	cap confirm str var `0'
	if _rc {
		di as err "`0' is not a string variable."
		ex 198
	}

	if "`:char `0'[Odk_type]'" != "text audit" {
		split `0', p("_") gen(stub)
		qui levelsof stub1, loc(stub1)
		foreach level of stub {
			if `stub' != "media/TA" & `stub' != . {
				di as err "`0' is not a SurveyCTO text audit variable."
				ex 190
			}
		}
	}
end
cap program drop parse_media
// program to check that media folder exists in the specified location
program parse_media, rclass

	// normalize file path and reverse string
	local rpath = reverse(subinstr("`0'", "\", "/", .))

	// grab last directory in path
	gettoken rfolder rpath : rpath, parse("/")

	local folder = reverse("`rfolder'")
	local path = reverse("`path'")

	// if it's the media folder
	if "`folder'" != "media" {
		// confirm the media folder exists
		qui cap confirm file "`0'/media/nul"
		// if no folder
		if _rc {
			// throw error
			di as err "media folder not found in specified location."
			ex 190
		}
		// reset path to original
		local path = "`0'"
	}

	return local location "`path'"
end
/*
// program to summarize text audit data
program summarize_ta, rclass
	foreach var of varlist ta_* {
		qui summ `var', det
		loc mean = r(mean)
		loc sd = r(sd)
		qui ttest `var' `enum'
		loc tval = 
		loc pval = 
		postfile
	}
end


// program to summarize text audit data by enumerator
program summarize_ta_by_enum, rclass
	* 1. Individual questions, by surveyor (much longer or much shorter)
	qui levelsof `id_surveyor', loc(surveyor_levels)
	foreach var of varlist ta_* {
		qui summ `var', det
		if r(N)!=0 {
			loc med = r(p50)
			loc sd = r(sd)
			loc mean = r(mean)
			foreach i in `surveyor_levels' {
				qui summ `var' if `id_surveyor'==`i', det
				loc med_`i' = r(p50)
				loc sd_`i' = r(sd)
				loc mean_`i' = r(mean)
				if `mean_`i'' > (`mean' + 2*`sd') {
					display "Surveyor `i' spends much longer on question `var' than average"
				}
				else if `mean_`i'' < (`mean'+2*`sd') {
					display "Surveyor `i' spends much less time on question `var' than average"
				}
			}
		}
	}

	* 2. Looking at average section length by surveyor
	// Creating each section to look at individually
	* Health, under-5 card
	foreach var of varlist ta_c_* {
		loc 1 `1' `var'
	}
	display "`1'"
	* Groups, health information, cda visits
	foreach var of varlist ta_b_* {
		loc 2 `2' `var'
	}
	display "`2'"
	* Anthropometric measures
	foreach var of varlist ta_anthro_* {
		loc 3 `3' `var'
	}
	display "`3'"
	* Nutrition and food recall
	foreach var of varlist ta_n?_* ta_n??_* {
		loc 4 `4' `var'
	}
	display "`4'"
	* Activities and games (including inter-NDA)
	foreach var of varlist ta_d_* {
		loc 5 `5' `var'
	}
	display "`5'"
	* Developmental/disability
	foreach var of varlist ta_f_* {
		loc 6 `6' `var'
	}
	display "`6'"
	* Maternal recall
	foreach var of varlist ta_g_* {
		loc 7 `7' `var'
	}
	display "`7'"
	* Surveyor observations
	foreach var of varlist ta_h_* {
		loc 8 `8' `var'
	}
	display "`8'"
	* Mental health
	foreach var of varlist ta_e_* {
		loc 9 `9' `var'
	}
	display "`9'"

	// Getting total time per section
	forvalues i=1/9 {
		egen section`i'_time = rowtotal(``i''), m
	}
	// Getting average section times by surveyor, comparing to overall mean
	qui levelsof `id_surveyor', loc(surveyor_levels)
	forvalues i=1/9 {
		qui summ section`i'_time, det
		loc mean = r(mean)
		loc sd = r(sd)
		loc med = r(p50)
		foreach j in `surveyor_levels' {
			qui summ section`i'_time if `id_surveyor'==`j', det
			loc mean_`j' = r(mean)
			loc sd_`j' = r(sd)
			loc med_`j' = r(p50)
			if `mean_`j'' > (`mean'+2*`sd') {
				display "Surveyor `j' has much longer time in section `i' than average"
			}
			else if `mean_`j'' < (`mean'-2*`sd') {
				display "Surveyor `j' has much shorter time in section `i' than average"
			}
		}
	}
end
*/