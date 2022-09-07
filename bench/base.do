cscript "base option" adofiles stdtable
include bench\_total.do

use bench\homogamy.dta
matrix base = J(1,5,10)
stdtable meduc feduc, baserow(base) basecol(base) tol(1e-15) replace
assert reldif(std,10) < 1e-6 if feduc == `tot' & meduc  < `tot'
assert reldif(std,10) < 1e-6 if meduc == `tot' & feduc  < `tot'
assert reldif(std,50) < 1e-6 if feduc == `tot' & meduc == `tot'

use bench\homogamy.dta, clear
matrix base = J(1,5,10)
stdtable meduc feduc, baserow(base) basecol(base) by(coh) tol(1e-15) replace
assert reldif(std,10) < 1e-6 if feduc == `tot' & meduc  < `tot'
assert reldif(std,10) < 1e-6 if meduc == `tot' & feduc  < `tot'
assert reldif(std,50) < 1e-6 if feduc == `tot' & meduc == `tot'


