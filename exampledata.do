clear all
qui tabi 1414 521 302  643   40 \ ///
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
label var pop "count"
label data "mobility table from the USA collected in 1973"
note : source: Featherman, D.L. and R.M. Hauser (1978) Opportunity and change. New York: Academic.
saveold "d:\mijn documenten\projecten\stata\stdtable\1.0.0\mob.dta", replace version(11)


clear all
input city vaccinated death count
      1    0          0      278
      1    0          1      274
      1    1          0     3951
      1    1          1      200
      2    0          0      139
      2    0          1       19 
      2    1          0      197
      2    1          1        2
      3    0          0     1424
      3    0          1     1103
      3    1          0     8207 
      3    1          1      692
end
compress
label define city 1 "Sheffield" ///
                  2 "Leicester" ///
                  3 "Londen"
label value city city
note city : Sheffield: epidemic 1887-1888
note city : Leicester: epidemic 1892-1893
note city : London: Homerton Hospital 1873-1884 and Fullham Hospital 1880-1885

label define vaccinated 1 "vaccinated"   ///
                        0 "unvaccinated"
label value vaccinated vaccinated

label define death 1 "died" ///
                   0 "recovered"
label value death death

matrix marg = J(1,2,5000)
bys city : tab vaccinated death [fw=count]
stdtable vaccinated death [fw=count], by(city)  baserow(marg) basecol(marg)

label data "vaccination and survival in English cities, end of the 19th century"
note : source: Macdonell, W.R. (1902) "On the influence of previous vaccination in cases of smallpox", Biometrika, 1(3):375-383.

saveold "D:\mijn documenten\projecten\stata\stdtable\1.0.0\smallpox.dta", replace version(11)
