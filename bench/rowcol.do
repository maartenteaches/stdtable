cscript "check row and col options" adofiles stdtable
include bench\_total.do

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
preserve

// row and col option should only change one of the margins if ncol == nrow
tempfile tofill
stdtable row col [fw=pop] , raw replace
rename std std1
save `tofill'
restore
preserve
stdtable row col [fw=pop] , raw col replace
rename std std2
merge 1:1 row col using `tofill'
assert _merge == 3
assert reldif(std1,std2) < 1e-6 if col < .
assert reldif(std2, 20) < 1e-6 if col == `tot' & row != `tot'
assert reldif(std2,100) < 1e-6 if col == `tot' & row == `tot'
drop _merge
restore 
stdtable row col [fw=pop] , raw row replace
rename std std2
merge 1:1 row col using `tofill'
assert _merge == 3
drop _merge
assert reldif(std1,std2) < 1e-6 if row < .
assert reldif(std2, 20) < 1e-6 if row == `tot' & col != `tot'
assert reldif(std2,100) < 1e-6 if row == `tot' & col == `tot'

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
assert   std == 100 if ed == `tot'      // rowtotals are 100
assert _freq == 100 if ed == `tot'      // raw is also row percentage, so rowtotal = 100 


restore

preserve
stdtable support ed [fw=freq], raw replace col
assert   std == 100 if support == `tot' // coltotals are 100
assert _freq == 100 if support == `tot' // raw rowtotals are also 100
restore

rcof "noi stdtable support ed [fw=freq], row col" == 198

use bench\homogamy.dta, clear
preserve
stdtable meduc feduc, by(coh, baseline(1970)) raw row replace tol(1e-15)
assert   std == 100 if feduc == `tot'      // rowtotals are 100
assert _freq == 100 if feduc == `tot'      // raw is also row percentage, so rowtotal = 100 
restore

preserve
stdtable meduc feduc, by(coh, baseline(1970)) raw col replace tol(1e-15)
assert   std == 100 if meduc == `tot'      // coltotals are 100
assert _freq == 100 if meduc == `tot'      // raw is also col percentage, so coltotal = 100 
restore