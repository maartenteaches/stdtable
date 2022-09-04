clear all
discard
set more off
set rmsg on

program define Parseby, rclass
	version 8
	syntax [varname(default=none numeric) ] [if], [BASEline(numlist max=1 integer)]
	
	if "`varlist'" == "" & "`baseline'" != "" {
		di as err "the baseline suboption can only be specified when specifying a variable in the main by() option"
		exit 198
	}
	if "`varlist'" == "" end

	if "`baseline'" != "" {
		marksample touse
		qui count if `varlist' == `baseline' & `touse' == 1
		if r(N) == 0 {
			di as err "the value `baseline' must occur in `varlist'"
			exit 2000
		}
		return scalar baseline = `baseline'
	}
	return local by "`varlist'"
end

*! version 1.0.0 21Mar2016 MLB
program define stdtable, rclass
	version 8
	syntax varlist(min=2 max=2) [if] [in] [fweight],                ///
       [raw replace by(string)                                      ///
       BASERow(namelist min=1 max=1) BASECol(namelist min=1 max=1)  ///
       TOLerance(real 1e-6) ITERate(integer `c(maxiter)') log       ///
       format(string) * ]

	marksample touse
	if "`weight'" != "" local wgt "[`weight'`exp']"

	if `tolerance' < 0 {
		di as err "negative numbers cannot be specified in tolerance()"
		exit 198
	}
	if `iterate' < 0 {
		di as err "negative numbers cannot be specified in iterate()"
		exit 198
	}
	if "`format'" == "" {
		local format "%9.3g"
	}
	else {
		capture display `format' 2
		if _rc error 120
	}

	Parseby `by'
	local by "`r(by)'"
	local baseline "`r(baseline)'"

	if "`baserow'" != "" & "`basecol'" == "" {
		di as err "basecol() needs to be specified when specifying baserow()"
		exit 198
	}
	if "`baserow'" == "" & "`basecol'" != "" {
		di as err "baserow() needs to be specified when specifying basecol()"
		exit 198
	}
	if "`baserow'" != "" & "`baseline'" != "" {
		di as err "baseline() cannot be specified when specifying baserow() and basecol()"
		exit 198
	}
	if "`baserow'" != "" {
		confirm matrix `baserow' `basecol'
	}


	tempvar mark tot basec baser freq muhat muhat_old marg reldifi
	tempname reldif 
	preserve
    contract `varlist' `by' `wgt', zero nomiss freq(`freq')
	
    sum `freq', meanonly
	if r(sum) == 0 error 2000

	gettoken r c : varlist

	if "`baseline'" != "" {
		sort `c'
		    by `c' : gen double `basec' = sum((`by' == `baseline') * `freq') 
		qui by `c' : replace    `basec' = `basec'[_N]
		sort `r'
		    by `r' : gen double `baser' = sum((`by' == `baseline') * `freq') 
		qui by `r' : replace    `baser' = `baser'[_N]
	}
	else if "`baserow'`basecol'" != "" {
		bys `r' : gen byte `mark' = _n == 1
		qui count if `mark'
		local kr = r(N)
		if rowsof(`baserow') != 1 {
			if colsof(`baserow') == 1 {
				matrix `baserow' = `baserow''
			}
			else {
				di as err "the matrix specified in baserow() needs to be a vector"
				exit 198
			}
		}
		if colsof(`baserow') != `kr' {
			di as err "there are `kr' values in `r', so baserow() needs a 1 by `kr' matrix"
			exit 198
		}
		tempname ones sumrow sumcol
		matrix `ones' = J(`kr',1,1)
		matrix `sumrow' = `baserow'*`ones'


		qui bys `c' : replace `mark' = _n == 1 
		qui count if `mark'
		local kc = r(N)
		if rowsof(`basecol') != 1 {
			if colsof(`basecol') == 1 {
				matrix `basecol' = `basecol''
			}
			else {
				di as err "the matrix specified in basecol() needs to be a vector"
				exit 198
			}
		}
		if colsof(`basecol') != `kc' {
			di as err "there are `kc' values in `c', so basecol() needs a 1 by `kc' matrix"
			exit 198
		}
		matrix `ones' = J(`kc',1,1)
		matrix `sumcol' = `basecol'*`ones'
		capture assert mreldif(`sumcol', `sumrow') < `tolerance' 
		if _rc{
			di as error "the sums of the matrices in basecol() and baserow() need to be equal"
			exit 198
		}
		quietly {
			tempvar id
			bys `by' `r' : gen        `id'    = _n==1
			by  `by'     : replace    `id'    = sum(`id')
						   gen double `baser' = `baserow'[1, `id']
			bys `by' `c' : replace    `id'    = _n==1
			by  `by'     : replace    `id'    = sum(`id')
						   gen double `basec' = `basecol'[1, `id']
		}
		drop `mark' `id'
	}
	else {
		bys `r' : gen byte `mark' = _n == 1 
		qui count if `mark'
		local k = r(N)
		qui bys `c' : replace `mark' = _n == 1
		qui count if `mark'
		if r(N) != `k' {
			di as err "standardization to all 100 margins is only defined for square tables"
			exit 198
		}
		drop `mark'
		gen double `basec' = 100
		gen double `baser' = 100
	}

	// estimate standardized counts
	gen double `muhat' = `freq'
	gen double `muhat_old' = 0
	qui gen double `marg' = .
	local i = 1

	qui gen double `reldifi' = reldif(`muhat',`muhat_old')
	sum `reldifi', meanonly
	scalar `reldif' = r(max)

	while `reldif' > `tolerance' & `i' < `iterate' {
		quietly {
			replace `muhat_old' = `muhat'	
			sort `by' `r'
			by `by' `r' : replace `marg' = sum(`muhat')
			by `by' `r' : replace `muhat' = `muhat' * `baser' / `marg'[_N]
			sort `by' `c'
			by `by' `c' : replace `marg' = sum(`muhat')
			by `by' `c' : replace `muhat' = `muhat' * `basec' / `marg'[_N]
			replace `reldifi' = reldif(`muhat',`muhat_old')
			sum `reldifi', meanonly
			scalar `reldif' = r(max)
		}
		if "`log'" != "" {
			di as txt "iteration :" as result `i++' ///
               as txt " relative improvement: " as result `reldif' 
		}
	}
	if `--i' == `iterate' & `reldif' > `tolerance' error 430

	quietly {
		// row totals
		bys `by' `r' : gen byte `mark' = (_n == 1) + 1
		expand `mark', gen(`tot')
		replace `c' = . if `tot' == 1 
		replace `muhat' = 0 if `tot' == 1
		bys `by' `r' (`c') : replace `tot' = sum(`muhat')
		replace `muhat' = `tot' if `c' == .
		if "`raw'" != "" {
			replace `freq' = 0 if `c' == .
			bys `by' `r' (`c') : replace `tot' = sum(`freq')
			replace `freq' = `tot' if `c' == .
		}
		drop `tot'

		// column totals
		bys `by' `c' : replace `mark' = (_n == 1) + 1
		expand `mark' , gen(`tot')
		replace `r' = . if `tot' == 1
		replace `muhat' = 0 if `tot' == 1
		bys `by' `c' (`r') : replace `tot' = sum(`muhat')
		replace `muhat' = `tot' if `r' == .
		if "`raw'" != "" {
			replace `freq' = 0 if `r' == .
			bys `by' `c' (`r') : replace `tot' = sum(`freq')
			replace `freq' = `tot' if `r' == .
		}
	}

	// display the result
	if "`raw'" != "" {
		local freqopt "`freq'"
	}
	if "`by'" != "" {
		local byopt "by(`by')"
	}
	tabdisp `r' `c' , `byopt' cellvar(`muhat' `freqopt') totals format(`format') `options'

	//
	if "`replace'" == "" {
		restore
	}
	else {
		if "`raw'" != "" {
			qui gen double _freq = `freq'
			label variable _freq "observed counts"
		}
		qui gen double std = `muhat'
		label variable std "standardized counts"
		restore, not
	}
end

use c:\temp\foo.dta, clear
label variable coh "cohort"
label variable mdeg "male degree"
label variable fdeg "female degree"
set traced 2
*set trace on
matrix base = J(1,5,10)
*profiler on
stdtable mdeg fdeg, by(coh, ) format(%9.2f) raw  baserow(base) basecol(base) replace
*profiler off
*profiler report
