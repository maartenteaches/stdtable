cscript "subroutines" adofiles stdtable
use bench\homogamy.dta
matrix base = J(1,5,10)
stdtable meduc feduc, baserow(base) basecol(base) tol(1e-15) replace
assert reldif(std,10) < 1e-6 if feduc == . & meduc < .
assert reldif(std,10) < 1e-6 if meduc == . & feduc < .
assert reldif(std,50) < 1e-6 if feduc == . & meduc == .

use bench\homogamy.dta, clear
matrix base = J(1,5,10)
stdtable meduc feduc, baserow(base) basecol(base) by(coh) tol(1e-15) replace
assert reldif(std,10) < 1e-6 if feduc == . & meduc < .
assert reldif(std,10) < 1e-6 if meduc == . & feduc < .
assert reldif(std,50) < 1e-6 if feduc == . & meduc == .
