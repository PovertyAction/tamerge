# tamerge
A Stata command for merging SurveyCTO text audit data with imported Stata data sets.

## To Do 
- Add SMCL help file documentation.
- ~~Add checks to verify text audit variable.~~
- ~~Add checks to verify media location option.~~
- ~~Add `prefix` option.~~
- ~~Add `save` option.~~
- Add `groupnames` option for data sets that maintain SCTO group names.
- Add `stats` option for quick overview of enumerator performance.
- Optimize performance of the merge.
- ~~Add license information.~~
- Adjust progress display items (if needed).
- Create unit test examples.
- Overall make code more consistent with odkmeta, perhaps for eventual merger.

## Help File

<pre>
<b><u>Title</u></b>
<p>
    <b>tamerge</b> -- Merge data from SurveyCTO text audit files with SurveyCTO
        Stata data set in memory.
<p>
<a name="syntax"></a><b><u>Syntax</u></b>
<p>
        <b>tamerge</b> <i>varname</i><b>,</b> <b>media(</b><i>medialocation</i><b>)</b> [<i>options</i>]
<p>
    <i>options</i>                               Description
    -------------------------------------------------------------------------
    Main
    * <b>media(</b><i>medialocation</i><b>)</b>                location of the<i> media folder</i>
                                            created by SurveyCTO that
                                            contains the text audit data
<p>
    Options
      <b>prefix(</b><i>stub</i><b>)</b>                        replace default<i> ta</i> prefix with
                                            <i>stub</i>.
      <b>save(</b><i>dtaname</i><b>)</b>                       write merged data set to a local
                                            dta file named<i> dtaname</i>.
      <b>replace</b>                             overwrite existing <i>filename</i>
    -------------------------------------------------------------------------
    * <b>media()</b> is required.
<p>
<p>
<a name="description"></a><b><u>Description</u></b>
<p>
    <b>tamerge</b> merges SurveyCTO text audit data stored in .csv files in the
    media folder with the data set in memory based on file mapping contained
    in variable<i> varname</i>.
<p>
<a name="remarks"></a><b><u>Remarks</u></b>
<p>
    Blah, blah, blah....
<p>
<a name="options"></a><b><u>Options</u></b>
<p>
        +------+
    ----+ Main +-------------------------------------------------------------
<p>
    <b>media(</b><i>medialocation</i><b>)</b> blah, blah, blah
<p>
<a name="examples"></a><b><u>Examples</u></b>
<p>
<p>
<a name="acknowledgements"></a><b><u>Acknowledgements</u></b>
<p>
    Nate Barker of Innovations for Poverty Action wrote the original do-file
    on which <b>tamerge</b> is based and provided valuable assitance in all aspects
    of testing and deployment. All credit for <b>tamerge</b>'s success should go to
    him.
<p>
<p>
<a name="author"></a><b><u>Author</u></b>
<p>
    Christopher Boyer
<p>
    For questions or suggestions, submit a GitHub issue or e-mail
    researchsupport@poverty-action.org.
<p>
<p>
</pre>