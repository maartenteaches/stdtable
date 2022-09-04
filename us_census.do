use "D:\Mijn documenten\projecten\loglin\posted\data\usa_00004.dta", clear
keep if inrange(birthyr,1880,1979)
keep if inrange(year - birthyr , 30, 65)
keep if (sex==1 & sex_sp == 2 ) | (sex == 2 & sex_sp == 1) | sex_sp == .

gen byte ed =  cond(educ <=  1, 1 , ///
               cond(educ <=  5, 2 , ///
               cond(educ ==  6, 3 , ///
               cond(educ <=  9, 4 , ///
               cond(educ <= 11, 5, .)))))
gen byte ped = cond(educ_sp <=  1, 1 , ///
               cond(educ_sp <=  5, 2 , ///
               cond(educ_sp ==  6, 3 , ///
               cond(educ_sp <=  9, 4 , ///
               cond(educ_sp <= 11, 5, .)))))
gen byte hed = cond(sex == 1, ed, ped)
gen byte wed = cond(sex == 2, ed, ped)

label define ed 1 "lt grade 5"  ///
                2 "grade 5 -11" ///
                3 "high school" ///
                4 "1-3 years of college" ///
                5 "4+ yers of college"
label value hed wed ed
label variable hed "husband's education"
label variable wed "wife's education"

gen int coh = floor(birthyr/5)*5
stdtable hed wed [pw= hhwt], by(birthyr) raw replace log

exit
