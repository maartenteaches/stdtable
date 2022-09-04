use "C:\Users\Admin\Desktop\usa_00005.dta", clear
keep if year >= 1880
gen hrace = cond(sex==1, race, race_sp)
gen wrace = cond(sex==2, race, race_sp)
replace hrace = . if hrace > 5
replace wrace = . if wrace > 5

gen coh = floor((year - age)/10)*10
contract hrace wrace coh
label define race 1 "white"   ///
                  2 "black"   ///
                  3 "native"  ///
                  4 "Chinese" ///
                  5 "Japanese"
label value hrace wrace race

cd "d:\mijn documenten\projecten\stata\stdtable\1.0.0"
stdtable hrace wrace [fw=_freq], by(coh) replace
