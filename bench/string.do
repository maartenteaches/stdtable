cscript "string variables in stdtable" adofiles stdtable

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
rename std std2

decode row, gen(rowstring)
decode col, gen(colstring)
tempfile temp
save `temp'


stdtable rowstring colstring [fw=_freq], raw replace tol(1e-15)

merge 1:1 rowstring colstring using `temp'
assert reldif(std2,std) < 1e-6
