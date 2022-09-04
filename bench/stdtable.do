cscript "general checks of stdtable" adofiles stdtable

// open data
tabi 1414 521 302  643   40 \ ///
      724 524 254  703   48 \ ///
      798 648 856 1676  108 \ ///
      756 914 771 3325  237 \ ///
      409 357 441 1611 1832, replace 
label define occ 1 "upper nonmanual" ///
                 2 "lower nonmanual" ///
                 3 "upper manual" ///
                 4 "lower manual" ///
                 5 "farm"
label value row col occ
label var row "Father's occupation"
label var col "Son's occupation"

// Compare estimates based on IPF (stdtable) with estimates using poisson
stdtable row col [fw=pop], raw replace tol(1e-15)

gen foo = 20
poisson foo i.row i.col, exposure(_freq)
predict double mu

assert reldif(std,mu) < 1e-6 if !missing(row,col)

// format of saved variables 
// (default format is %9.3g)
keep row col _freq
stdtable row col [fw=_freq], replace raw
assert "`:format std'" == "%9.3g"

// specified format
keep row col _freq
stdtable row col [fw=_freq], replace raw format(%5.0f)
assert "`:format std'" == "%5.0f"

// weights
keep row col _freq
stdtable row col [fw=_freq], replace raw
rename std std2
tempfile temp
save `temp'

expand _freq
stdtable row col, replace
merge 1:1 row col using `temp'

assert reldif(std,std2) < 1e-6

// if
keep row col _freq
expand _freq
set seed 123456
gen byte touse = runiform() < .80
preserve
stdtable row col if touse, replace
rename std std2
save `temp', replace
restore
keep if touse
stdtable row col, replace
merge 1:1 row col using `temp'

assert reldif(std,std2)< 1e-6

// This should not converge
tabi 10 5 \ 0 5, replace 
rcof "noi stdtable row col [fw=pop], iter(1600)" == 430
