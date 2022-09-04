cscript "by" adofiles stdtable

// ------------------------------------------- margins all 100
// check ipf against poisson, though not as easy for 0s, so remove those 
use bench\homogamy.dta
keep if coh > 1910
stdtable meduc feduc, by(coh) replace raw tol(1e-15)
gen foo = 20
poisson foo i.coh##(i.meduc i.feduc), exposure(_freq)
predict double mu
assert reldif(mu,std) < 1e-6 if !missing(meduc,feduc)

// --------------------------------------------- baseline category
use bench\homogamy.dta, clear
stdtable meduc feduc, by(coh, baseline(1970)) raw replace tol(1e-15)

// raw and standardized should be equal in reference group
assert reldif(_freq,std) < 1e-6 if coh==1970

// row totals should be equal across cohorts
bys meduc (feduc): gen double dif = reldif(std,std[_N]) if feduc == .
assert dif < 1e-6 if feduc == .

// column totals should be equal across cohorts
drop dif
bys feduc (meduc): gen double dif = reldif(std,std[_N]) if meduc == .
assert dif < 1e-6 if meduc == .

rcof "noi stdtable meduc feduc, by(coh, baseline(1970)) row" == 198
rcof "noi stdtable meduc feduc, by(coh, baseline(1970)) col" == 198

// string in by()
use bench\homogamy.dta, clear
decode coh, gen(cohstring)
stdtable meduc feduc, by(cohstring) replace tol(1e-15)
rename std std2
tempfile temp
save `temp'
use bench\homogamy.dta
stdtable meduc feduc, by(coh) replace tol(1e-15)
decode coh, gen(cohstring)
merge 1:1 meduc feduc cohstring using `temp'
assert reldif(std, std2) < 1e-6

use bench\homogamy.dta, clear
decode coh, gen(cohstring)
stdtable meduc feduc, by(cohstring, base("1920-1929")) replace tol(1e-15)
rename std std2
tempfile temp
save `temp'
use bench\homogamy.dta
stdtable meduc feduc, by(coh, base(1920)) replace tol(1e-15)
decode coh, gen(cohstring)
merge 1:1 meduc feduc cohstring using `temp'
assert reldif(std, std2) < 1e-6
