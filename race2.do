clear all
cd "D:\Mijn documenten\projecten\stata\stdtable\1.0.0\"
use usa_00008.dta
keep if age < 60 
keep if year - birthyr_sp < 60

gen byte race = racesing if racesing < 4
gen byte race_sp = racesing_sp if racesing_sp< 4
keep if !missing(race, race_sp)

gen byte hrace = cond(sex==1, race, race_sp)
gen byte wrace = cond(sex==2, race, race_sp)
label variable hrace "husband's race"
label variable wrace "wife's race"

label define race 1 "white"    ///
                  2 "black"    ///
                  3 "native"   
label value hrace wrace race

replace birthyr = year - age if inlist(birthyr,0, 9999)
gen hbirthyr = cond(sex==1, birthyr, birthyr_sp) if birthyr_sp < 9999
gen int coh = floor(hbirthyr/10)*10
keep if inrange(coh,1820,1980)
local labs ""
forvalues i = 1820(10)1980 {
	local labs `"`labs' `i' "`i's""'
}
label define coh `labs'
label value coh coh
label variable coh "husband's birth cohort (decade)"

keep hrace wrace coh
contract hrace wrace coh, zero

label data "husband's and wife's race in the USA from the census and ACS 1880-2014"
notes : Steven Ruggles, Katie Genadek, Ronald Goeken, Josiah Grover, and Matthew Sobek. Integrated Public Use Microdata Series: Version 6.0 [Machine-readable database]. Minneapolis: University of Minnesota, 2015. 
notes : downloaded on 29 March 2016 from www.ipums.org
notes : married persons aged 18-60, unweighted

saveold interracial, version(11) replace

use interracial, clear
stdtable hrace wrace [fw=_freq] , by(coh) replace 

tabplot hrace coh [iw=std],                ///
    by(wrace, compact cols(3) note(""))     ///
	xtitle("birth cohort" "wife's race") ///
    xlab(1(2)18,angle(35) labsize(vsmall)) name(std1,replace)
