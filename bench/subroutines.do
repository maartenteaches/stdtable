cscript "subroutines" adofiles stdtable
run stdtable.ado

use bench\homogamy.dta
gen byte touse = 1

// ------------------------------ Parseby
Parseby, touse(touse)
assert `"`r(by)'"'       == ""
assert `"`r(baseline)'"' == ""

Parseby coh, touse(touse)
assert `"`r(by)'"'       == `"coh"'
assert `"`r(baseline)'"' == ""

Parseby coh, touse(touse) baseline(1920)
assert `"`r(by)'"' == `"coh"'
assert r(baseline) == 1920

decode coh, gen(cohstring)
Parseby cohstring, touse(touse) baseline("1920-1929")
assert `"`r(by)'"'       == `"cohstring"'
assert `"`r(baseline)'"' == `"1920-1929"'

rcof "noi Parseby coh , touse(touse) baseline(1929)" == 2000
rcof "noi Parseby , touse(touse) baseline(1929)" == 198

replace touse = 0 if coh == 1920
rcof "noi Parseby coh, touse(touse) baseline(1920)" == 2000


// ---------------------- Contract_w
// pweights
use bench\homogamy.dta, clear
Contract_w meduc feduc coh [iw=weight], nomiss
tempfile temp
save `temp'
use bench\homogamy.dta, clear
collapse (sum) weight, by(meduc feduc coh)
drop if missing(meduc,feduc,coh)
merge 1:1 meduc feduc coh using `temp'
assert reldif(weight,_freq) < 1e-6 
