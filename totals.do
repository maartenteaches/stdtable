clear all
use "http://www.maartenbuis.nl/software/homogamy.dta", clear

egen tot = total(freq), by(marcoh)
egen row = total(freq), by(marcoh racem)
egen col = total(freq), by(marcoh racef)
gen percrow = logit(row/tot)
gen perccol = logit(col/tot)
keep racem racef perccol percrow marcoh
reshape long perc, i(racem racef marcoh) j(gender) string

decode racem, gen(string)

separate perc, by(racef)
 
 sort gender marcoh
 
twoway line perc? marcoh ,  by(gender)  ///
	ylab(`=logit(.001)' "0.1"  ///
	     `=logit(.01)' "1"     ///
		 `=logit(.05)' "5"     ///
		 `=logit(.1)' "10"     ///
		 `=logit(.25)' "25"    ///
		 `=logit(.5)' "50"     ///
		 `=logit(.75)' "75"    ///
		 `=logit(.9)' "90" , angle(0)) || ///
	scatter perc marcoh if marcoh == 2010 , mlabel(string) mlabpos(3) msymbol(i) legend(off) xlab(1950(10)2010, val) xscale(range(1950 2017))