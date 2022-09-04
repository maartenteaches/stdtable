cd "d:/mijn documenten/projecten/track_mobility/cceast/work"
clear all
use "cceast00.dta"
mvdecode  museum perf music read lib pmuseum pperf pmusic pread plib, mv(-8=.\-7=.\-2=.)
recode museum perf music read lib pmuseum pperf pmusic pread plib (5/6=4)
keep museum perf music read lib pmuseum pperf pmusic pread plib weight
compress
keep if !missing(museum, perf, music, read, lib, pmuseum, pperf, pmusic, pread, plib)

cd "d:\mijn documenten\projecten\stata\stdtable\1.0.0"

label define cons 0 "never" ///
                 1 "< 1 / year" ///
                 2 "1, 2 / year" ///
                 3 "> 2 / year" ///
                 4 "> 1 / month"
label value museum perf music read lib pmuseum pperf pmusic pread plib cons

foreach var in museum perf music read lib {
	rename `var' cons`var'
	rename p`var' pcons`var'
}
gen id = _n
reshape long cons pcons, i(id) j(cult) string

run stdtable.ado
Contract_w cult cons pcons [iw=weight]


saveold culture, version(11) replace

stdtable pcons cons [iw=_freq], replace by(cult) raw

tabplot pcons cult [iw=std],                ///
    by(cons, compact cols(5) note(""))     ///
    showval(format(%9.0f))                ///
    xtitle(offspring's cultural consumption)  ///
    ytitle(parent's cultural consumption) ///
    xlab(,angle(35)) name(std1,replace)
tabplot pcons cult [iw=_freq],              ///
    by(cons, compact cols(5) note(""))     ///
    xtitle(offspring's cultural consumption)  ///
    ytitle(parent's cultural consumption) ///
    xlab(,angle(35)) name(raw, replace)

use culture, replace
tab pmuseum [iweight=weight], matcell(row)
tab museum [iweight=weight], matcell(col)

stdtable pmuseum museum [iw=weight], replace baserow(row) basecol(col)
gen form = 1
rename pmuseum row
rename museum col
tempfile tofill
save `tofill'

local i = 2
foreach var in perf music read lib {
	use culture, clear
	stdtable p`var' `var' [iw=weight], replace raw baserow(row) basecol(col)
	gen form = `i++'
	rename p`var' row
	rename `var' col
	append using `tofill'
	save `tofill', replace
}

label define col 0 "never" ///
                 1 "< 1 / year" ///
                 2 "1, 2 / year" ///
                 3 "> 2 / year" 
label value row col col

label define form 1 "museum" ///
                  2 "performing" ///
                  3 "music"      ///
                  4 "read"       ///
                  5 "library"
label value form form 

tabplot row form [iw=std],                ///
    by(col, compact cols(4) note(""))     ///
    showval(format(%9.0f))                ///
    xtitle(offspring's cultural consumption)  ///
    ytitle(parent's cultural consumption) ///
    xlab(,angle(35)) name(std2, replace)

exit
