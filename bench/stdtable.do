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

// check the estimates
stdtable row col [fw=pop], raw replace tol(1e-15)
assert reldif( std[1],  41.68814025497085 ) < 1e-8
assert reldif( std[2],  26.98103877707983 ) < 1e-8
assert reldif( std[3],  15.93382795234896 ) < 1e-8
assert reldif( std[4],  11.09300294857296 ) < 1e-8
assert reldif( std[5],  4.303990067027365 ) < 1e-8
assert reldif( std[6],  100               ) < 1e-8
assert reldif( std[7],  23.63312284905826 ) < 1e-8
assert reldif( std[8],  30.04496236032567 ) < 1e-8
assert reldif( std[9],  19.90730706589843 ) < 1e-8
assert reldif( std[10],  20.63449316772626 ) < 1e-8
assert reldif( std[11],  5.780114556991383 ) < 1e-8
assert reldif( std[12],  100               ) < 1e-8
assert reldif( std[13],  17.31724256851035 ) < 1e-8
assert reldif( std[14],  18.41036937574834 ) < 1e-8
assert reldif( std[15],  33.24295964115039 ) < 1e-8
assert reldif( std[16],  22.00343053117528 ) < 1e-8
assert reldif( std[17],  9.025997883415632 ) < 1e-8
assert reldif( std[18],                100 ) < 1e-8
assert reldif( std[19],  13.13168752487267 ) < 1e-8
assert reldif( std[20],  18.14771206694555 ) < 1e-8
assert reldif( std[21],  23.18129542039885 ) < 1e-8
assert reldif( std[22],  33.79601060586852 ) < 1e-8
assert reldif( std[23],  11.74329438191442 ) < 1e-8
assert reldif( std[24],                100 ) < 1e-8
assert reldif( std[25],  4.229806802587857 ) < 1e-8
assert reldif( std[26],  6.415917419900591 ) < 1e-8
assert reldif( std[27],  7.734609920203362 ) < 1e-8
assert reldif( std[28],  12.47306274665697 ) < 1e-8
assert reldif( std[29],  69.14660311065121 ) < 1e-8
assert reldif( std[30],                100 ) < 1e-8
assert reldif( std[31],                100 ) < 1e-8
assert reldif( std[32],  100 ) < 1e-8
assert reldif( std[33],  100 ) < 1e-8
assert reldif( std[34],                100 ) < 1e-8
assert reldif( std[35],                100 ) < 1e-8
assert reldif( std[36],                500 ) < 1e-8

// Compare estimates based on IPF (stdtable) with estimates using poisson
clear
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
