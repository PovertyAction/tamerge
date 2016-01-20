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

cap program drop tamerge;
program define tamerge, rclass
	version 13

	// check sxpose is installed (required)
	cap which sxpose()
	if _rc {
		ssc install sxpose
		di "SSC package sxpose required."
		di "  Attempting to install sxpose..."
		if _rc == 631 {
			di as err "You are not connected to the internet"
			di as err "Please connect to the internet, then run tamerge or type {cmd:ssc install sxpose}"
	}

	syntax varname, media(str) [stats(enum) prefix(str) replace]

	/* the syntax variables represent the following:
	     varname - the name of the text_audit variable in the dataset in memory.
	     media - the name of the folder path where the text audit files are stored. 
	     stats - print summary stats by enumerator.
	     prefix - change the stub that is appended to the start of the variable audit times.
	     replace - replace the 
	*/

	// ***program checks***

	// check ta variable 
	parse_tavar `varname'

	// check if media folder exists
	parse_media `media'

	// check enum variable
	parse_enum `enum'

	// set cleaned locals
	local media = `r(location)'
	local tavar = `varname'

	// create temporary files
	tempfile full_data audit_data
	save `full_data'

	// transpose
	qui levelsof `tavar', loc(talevels)
	loc tacount: word count `talevels'

	// This loop will run through every reported instance of a file containing the audit data
	forvalues j = 1/`tacount' {
		qui loc tafile: word `j' of `talevels'
		qui tempfile audit`j' 
		
		// This file location will be wherever your audits are stored
		cap qui insheet using "`media'\\`tafile", clear
		if _rc == 601 {
			di "Audit `tafile' not found, skipping this audit"
			exit
		}
		
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
		
		qui sxpose, clear force firstnames
		
		foreach var of varlist _all {
			qui destring `var', replace
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

	save `audit_data'

	use `full_data', clear
	merge 1:1 `tavar' using `audit_data'
end

// program to check that specified variable is a SurveyCTO text audit field
program parse_tavar, sclass
	if `:list sizeof 0' != 1 {
		di as err "`0' is not a variable in data set."
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

// program to check that media folder exists in the specified location
program parse_media, rclass

end

program parse_enum

end