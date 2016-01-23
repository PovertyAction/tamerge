{smcl}
{* *! version 1.0.0 Christopher Boyer 2016-01-19}{...}
{title:Title}

{phang}
{cmd:tamerge} {hline 2} Merge data from SurveyCTO text audit files with SurveyCTO Stata data set in memory.

{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:tamerge}
{it:{help varname}}{cmd:,}
{opt media(medialocation)}
[{it:options}]

{* Using -help odbc- as a template.}{...}
{* 36 is the position of the last character in the first column + 3.}{...}
{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{p2coldent:* {opt media(medialocation)}}location of the {it: media folder} created by SurveyCTO that
contains the text audit data

{syntab:Options}
{synopt:{opt prefix(stub)}}replace default {it: ta} prefix with {it: stub}.{p_end}
{synopt:{opt save(dtaname)}}write merged data set to a local dta file named {it: dtaname}.{p_end}
{synopt:{opt stats(enumerator)}}display summary statistics for audit variables and test for differences across {it: enumerator}.{p_end}
{synopt:{opt replace}}overwrite existing {it:{help filename}}{p_end}
{synoptline}
{p2colreset}{...}
{* Using -help heckman- as a template.}{...}
{p 4 6 2}* {opt media()} is required.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:tamerge} merges SurveyCTO text audit data stored in .csv files in the media folder with the 
data set in memory based on file mapping contained in variable {it: varname}. 

{marker remarks}{...}
{title:Remarks}

{pstd}
Blah, blah, blah....

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{cmd:media(}{it:medialocation}{cmd:)} blah, blah, blah.

{dlgtab:Options}

{phang}
{cmd:prefix(}{it:stub}{cmd:)} blah, blah, blah.

{phang}
{cmd:save(}{it:dtaname}{cmd:)} blah, blah, blah.

{phang}
{cmd:stats(}{it:enumerator}{cmd:)} blah, blah, blah.

{phang}
{cmd:replace} blah, blah, blah.

{marker examples}{...}
{title:Examples}


{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd}
Nate Barker of Innovations for Poverty Action wrote the original do-file 
on which {cmd:tamerge} is based and provided valuable assitance in all aspects of testing
and deployment. All credit for {cmd:tamerge}'s success should go to him.


{marker author}{...}
{title:Author}

{pstd}Christopher Boyer{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/matthew-white/odkmeta/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}


