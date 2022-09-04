cscript "frames" adofiles stdtable
frame
frames dir

use bench\homogamy.dta

// if frame does not exist, it will be created
stdtable meduc feduc, by(coh, base(1920)) replace(std) tol(1e-15)

frame dir
assert `"`r(changed)'"' == `"0 1"'
assert `"`r(frames)'"'  == `"default std"'

frame change std
assert _N == 252
assert c(k) == 4
ds 
assert `"`r(varlist)'"' == `"meduc feduc coh std"'
sum std, meanonly
assert reldif( r(max)    , 2984) < 1E-8
assert         r(min)   == 0
assert reldif( r(mean)   , 331.5555555555555 ) <  1E-8
assert         r(N)     == 252

frame change default

// need an additional replace suboption if frame already exists
rcof "noi stdtable meduc feduc, by(coh, base(1920)) replace(std) tol(1e-15)" == 110

// replace data in existing frame
stdtable meduc feduc if coh==1920, replace(std, replace) tol(1e-15)
frame change std
assert _N == 36
assert c(k) == 3
ds
assert `"`r(varlist)'"' == `"meduc feduc std"'
sum std, meanonly
assert         r(max)   == 500
assert reldif( r(min)    , 2.041743995036359 ) <  1E-8
assert reldif( r(mean)   , 55.55555555555556 ) <  1E-8
assert         r(N)     == 36

frame change default

// replace data in current frame
stdtable meduc feduc if coh==1920, replace(default, replace) tol(1e-15)
assert _N == 36
assert c(k) == 3
ds
assert `"`r(varlist)'"' == `"meduc feduc std"'
sum std, meanonly
assert         r(max)   == 500
assert reldif( r(min)    , 2.041743995036359 ) <  1E-8
assert reldif( r(mean)   , 55.55555555555556 ) <  1E-8
assert         r(N)     == 36