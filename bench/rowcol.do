cscript "check row and col options" adofiles stdtable

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

// row and col option should do nothing if ncol == nrow
tempfile tofill
stdtable row col [fw=pop] , raw replace
rename std std1
save `tofill'
stdtable row col [fw=_freq] , raw row replace
rename std std2
merge 1:1 row col using `tofill'
assert _merge == 3
drop _merge
save `tofill', replace
stdtable row col [fw=_freq] , raw col replace
rename std std3
merge 1:1 row col using `tofill'
assert _merge == 3
drop _merge
save `tofill', replace
assert reldif(std1,std2) < 1e-6
assert reldif(std1,std3) < 1e-6

// row and col matter when ncol != nrow
// open data
clear
input byte(support ed) int(freq)
1  1  1507   
1  2  1529   
1  3   845   
1  4  4880   
0  1  1172 
0  2   775 
0  3   413 
0  4  2220   
end

label var support "receiving tangible social support"
label var ed      "respondent's education"
label var freq    "frequency"

label define support 0 "no" 1 "yes"
label val support support

label define ed 1 "< secondary" ///
                2 "secondary"   ///
                3 "other post"  ///
                4 "post-sec" 
label value ed ed

preserve
stdtable support ed [fw=freq], raw replace row
assert   std == 100 if ed == .      // rowtotals are 100
assert _freq == 100 if ed == .      // raw is also row percentage, so rowtotal = 100 


restore

preserve
stdtable support ed [fw=freq], raw replace col
assert   std == 100 if support == . // coltotals are 100
assert _freq == 100 if support == . // raw rowtotals are also 100
restore

rcof "noi stdtable support ed [fw=freq], row col" == 198

use bench\homogamy.dta, clear
preserve
stdtable meduc feduc, by(coh, baseline(1970)) raw row replace tol(1e-15)
assert   std == 100 if feduc == .      // rowtotals are 100
assert _freq == 100 if feduc == .      // raw is also row percentage, so rowtotal = 100 
restore

preserve
stdtable meduc feduc, by(coh, baseline(1970)) raw col replace tol(1e-15)
assert   std == 100 if meduc == .      // coltotals are 100
assert _freq == 100 if meduc == .      // raw is also col percentage, so coltotal = 100 
restore