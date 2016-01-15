* Created on January 14, 2016 at 21:50:01 by the following -odkmeta- command:
* odkmeta using "import.do", csv("Sample Form - Auditing.csv") survey("survey.csv") choices("choices.csv")
* -odkmeta- version 1.1.0 was used.

version 9

* Change these values as required by your data.

* The mask of date values in the .csv files. See -help date()-.
* Fields of type date or today have these values.
local datemask MDY
* The mask of time values in the .csv files. See -help clock()-.
* Fields of type time have these values.
local timemask hms
* The mask of datetime values in the .csv files. See -help clock()-.
* Fields of type datetime, start, or end have these values.
local datetimemask MDYhms


/* -------------------------------------------------------------------------- */

* Start the import.
* Be cautious about modifying what follows.

local varabbrev = c(varabbrev)
set varabbrev off

* Find unused Mata names.
foreach var in values text {
	mata: st_local("external", invtokens(direxternal("*")'))
	tempname `var'
	while `:list `var' in external' {
		tempname `var'
	}
}

label drop _all

#delimit ;
* yesno;
label define yesno
	1 Yes
	0 No
;
#delimit cr

* Save label information.
label dir
local labs `r(names)'
foreach lab of local labs {
	quietly label list `lab'
	* "nassoc" for "number of associations"
	local nassoc `nassoc' `r(k)'
}

* Import ODK attributes as characteristics.
* - constraint message will be imported to the characteristic Odk_constraint_message.

insheet using "Sample Form - Auditing.csv", comma names case clear

* starttime
char starttime[Odk_name] starttime
char starttime[Odk_bad_name] 0
char starttime[Odk_long_name] starttime
char starttime[Odk_type] start
char starttime[Odk_or_other] 0
char starttime[Odk_is_other] 0

* endtime
char endtime[Odk_name] endtime
char endtime[Odk_bad_name] 0
char endtime[Odk_long_name] endtime
char endtime[Odk_type] end
char endtime[Odk_or_other] 0
char endtime[Odk_is_other] 0

* deviceid
char deviceid[Odk_name] deviceid
char deviceid[Odk_bad_name] 0
char deviceid[Odk_long_name] deviceid
char deviceid[Odk_type] deviceid
char deviceid[Odk_or_other] 0
char deviceid[Odk_is_other] 0

* subscriberid
char subscriberid[Odk_name] subscriberid
char subscriberid[Odk_bad_name] 0
char subscriberid[Odk_long_name] subscriberid
char subscriberid[Odk_type] subscriberid
char subscriberid[Odk_or_other] 0
char subscriberid[Odk_is_other] 0

* simid
char simid[Odk_name] simid
char simid[Odk_bad_name] 0
char simid[Odk_long_name] simid
char simid[Odk_type] simserial
char simid[Odk_or_other] 0
char simid[Odk_is_other] 0

* devicephonenum
char devicephonenum[Odk_name] devicephonenum
char devicephonenum[Odk_bad_name] 0
char devicephonenum[Odk_long_name] devicephonenum
char devicephonenum[Odk_type] phonenumber
char devicephonenum[Odk_or_other] 0
char devicephonenum[Odk_is_other] 0

* text_audit
char text_audit[Odk_name] text_audit
char text_audit[Odk_bad_name] 0
char text_audit[Odk_long_name] text_audit
char text_audit[Odk_type] text audit
char text_audit[Odk_or_other] 0
char text_audit[Odk_is_other] 0
char text_audit[Odk_appearance] p=100

* audio_audit
char audio_audit[Odk_name] audio_audit
char audio_audit[Odk_bad_name] 0
char audio_audit[Odk_long_name] audio_audit
char audio_audit[Odk_type] audio audit
char audio_audit[Odk_or_other] 0
char audio_audit[Odk_is_other] 0
char audio_audit[Odk_appearance] p=100; s=0; d=36000

* intronote
char intronote[Odk_name] intronote
char intronote[Odk_bad_name] 0
char intronote[Odk_long_name] intronote
char intronote[Odk_type] note
char intronote[Odk_or_other] 0
char intronote[Odk_is_other] 0
char intronote[Odk_label] Welcome to the sample auditing form. Please swipe forward to continue.  NOTE: You are being recorded.

* consent
char consent[Odk_name] consent
char consent[Odk_bad_name] 0
char consent[Odk_long_name] consent
char consent[Odk_type] select_one yesno
char consent[Odk_list_name] yesno
char consent[Odk_or_other] 0
char consent[Odk_is_other] 0
char consent[Odk_label] Would you like to continue?
char consent[Odk_required] yes

* begin group consented

* name
char consentedname[Odk_name] name
char consentedname[Odk_bad_name] 0
char consentedname[Odk_group] consented
char consentedname[Odk_long_name] consented-name
char consentedname[Odk_type] text
char consentedname[Odk_or_other] 0
char consentedname[Odk_is_other] 0
char consentedname[Odk_label] What is your name?
char consentedname[Odk_required] yes

* age
char consentedage[Odk_name] age
char consentedage[Odk_bad_name] 0
char consentedage[Odk_group] consented
char consentedage[Odk_long_name] consented-age
char consentedage[Odk_type] integer
char consentedage[Odk_or_other] 0
char consentedage[Odk_is_other] 0
char consentedage[Odk_label] How old are you?
char consentedage[Odk_constraint] .>3 and .<130
char consentedage[Odk_constraint_message] Please enter a valid age to continue.
char consentedage[Odk_required] yes

* confirmnote
char consentedconfirmnote[Odk_name] confirmnote
char consentedconfirmnote[Odk_bad_name] 0
char consentedconfirmnote[Odk_group] consented
char consentedconfirmnote[Odk_long_name] consented-confirmnote
char consentedconfirmnote[Odk_type] note
char consentedconfirmnote[Odk_or_other] 0
char consentedconfirmnote[Odk_is_other] 0
char consentedconfirmnote[Odk_label] Your name is \${name} and your age is \${age}. Thank you.

* end group consented

* Drop note variables.
ds, has(char Odk_type)
foreach var in `r(varlist)' {
	if "`:char `var'[Odk_type]'" == "note" ///
		drop `var'
}

* Date and time variables
capture confirm variable SubmissionDate, exact
if !_rc {
	local type : char SubmissionDate[Odk_type]
	assert !`:length local type'
	char SubmissionDate[Odk_type] datetime
}
local datetime date today time datetime start end
tempvar temp
ds, has(char Odk_type)
foreach var in `r(varlist)' {
	local type : char `var'[Odk_type]
	if `:list type in datetime' {
		capture confirm numeric variable `var'
		if !_rc {
			tostring `var', replace
			replace `var' = "" if `var' == "."
		}

		if inlist("`type'", "date", "today") {
			local fcn    date
			local mask   datemask
			local format %tdMon_dd,_CCYY
		}
		else if "`type'" == "time" {
			local fcn    clock
			local mask   timemask
			local format %tchh:MM:SS_AM
		}
		else if inlist("`type'", "datetime", "start", "end") {
			local fcn    clock
			local mask   datetimemask
			local format %tcMon_dd,_CCYY_hh:MM:SS_AM
		}
		generate double `temp' = `fcn'(`var', "``mask''")
		format `temp' `format'
		count if missing(`temp') & !missing(`var')
		if r(N) {
			display as err "{p}"
			display as err "`type' variable `var'"
			if "`repeat'" != "" ///
				display as err "in repeat group `repeat'"
			display as err "could not be converted using the mask ``mask''"
			display as err "{p_end}"
			exit 9
		}

		move `temp' `var'
		foreach char in `:char `var'[]' {
			mata: st_global("`temp'[`char']", st_global("`var'[`char']"))
		}
		drop `var'
		rename `temp' `var'
	}
}
capture confirm variable SubmissionDate, exact
if !_rc ///
	char SubmissionDate[Odk_type]

* Attach value labels.
ds, not(vallab)
if "`r(varlist)'" != "" ///
	ds `r(varlist)', has(char Odk_list_name)
foreach var in `r(varlist)' {
	if !`:char `var'[Odk_is_other]' {
		capture confirm string variable `var', exact
		if !_rc {
			replace `var' = ".o" if `var' == "other"
			destring `var', replace
		}

		local list : char `var'[Odk_list_name]
		if !`:list list in labs' {
			display as err "list `list' not found in choices sheet"
			exit 9
		}
		label values `var' `list'
	}
}

* Attach field labels as variable labels and notes.
ds, has(char Odk_long_name)
foreach var in `r(varlist)' {
	* Variable label
	local label : char `var'[Odk_label]
	mata: st_varlabel("`var'", st_local("label"))

	* Notes
	if `:length local label' {
		char `var'[note0] 1
		mata: st_global("`var'[note1]", "Question text: " + ///
			st_global("`var'[Odk_label]"))
		mata: st_local("temp", ///
			" " * (strlen(st_global("`var'[note1]")) + 1))
		#delimit ;
		local fromto
			{			"`temp'"
			}			"{c )-}"
			"`temp'"	"{c -(}"
			'			"{c 39}"
			"`"			"{c 'g}"
			"$"			"{c S|}"
		;
		#delimit cr
		while `:list sizeof fromto' {
			gettoken from fromto : fromto
			gettoken to   fromto : fromto
			mata: st_global("`var'[note1]", ///
				subinstr(st_global("`var'[note1]"), "`from'", "`to'", .))
		}
	}
}

local repeats `"`repeats' """'

local badnames
ds, has(char Odk_bad_name)
foreach var in `r(varlist)' {
	if `:char `var'[Odk_bad_name]' & ///
		("`:char `var'[Odk_type]'" != "begin repeat" | ///
		("`repeat'" != "" & ///
		"`:char `var'[Odk_name]'" == "SET-OF-`repeat'")) {
		local badnames : list badnames | var
	}
}
local allbadnames `"`allbadnames' "`badnames'""'

ds, not(char Odk_name)
local datanotform `r(varlist)'
local exclude SubmissionDate KEY PARENT_KEY metainstanceID
local datanotform : list datanotform - exclude
local alldatanotform `"`alldatanotform' "`datanotform'""'

compress

local dta `""Sample Form - Auditing""'
save `dta', replace
local dtas : list dtas | dta

capture mata: mata drop `values' `text'

set varabbrev `varabbrev'

* Display warning messages.
quietly {
	noisily display

	#delimit ;
	local problems
		allbadnames
			"The following variables' names differ from their field names,
			which could not be {cmd:insheet}ed:"
		alldatanotform
			"The following variables appear in the data but not the form:"
	;
	#delimit cr
	while `:list sizeof problems' {
		gettoken local problems : problems
		gettoken desc  problems : problems

		local any 0
		foreach vars of local `local' {
			local any = `any' | `:list sizeof vars'
		}
		if `any' {
			noisily display as txt "{p}`desc'{p_end}"
			noisily display "{p2colset 0 34 0 2}"
			noisily display as txt "{p2col:repeat group}variable name{p_end}"
			noisily display as txt "{hline 65}"

			forvalues i = 1/`:list sizeof repeats' {
				local repeat : word `i' of `repeats'
				local vars   : word `i' of ``local''

				foreach var of local vars {
					noisily display as res "{p2col:`repeat'}`var'{p_end}"
				}
			}

			noisily display as txt "{hline 65}"
			noisily display "{p2colreset}"
		}
	}
}
