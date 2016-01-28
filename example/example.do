/*-------------------------------*
 |file:    example.do            |
 |project: tamerge.ado           |
 |author:  christopher boyer     |
 |date:    2016-01-28            |
 *-------------------------------*/
 
/* an example of how to use tamerge to import and analyze text audit 
   data... */

clear
version 13

cd "D:\Box Sync\cboyer\stata\develop\tamerge\example\"

// run odkmeta to generate import do-file from SurveyCTO survey data
odkmeta using "odkmeta_import.do", csv("Sample Form - Auditing.csv") ///
                                   survey("survey.csv") ///
								   choices("choices.csv") ///
								   replace

// import SurveyCTO data into Stata using odkmeta-generated do-file.
run odkmeta_import.do

/*  call tamerge specifying the name of the variable corresponding to 
  the SCTO text audit file, the location of the media folder, and, optionally,
  a filename for saving the merged dta file and the variable corresponding to
  the surveyor for an analysis summary */
tamerge text_audit, media(".") save("merged.dta") stats(surveyor)
   
 
