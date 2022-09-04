clear all
use "http://www.maartenbuis.nl/software/homogamy.dta", clear

stdtable racem racef [fw=freq], ///
    by(marcoh, base(2010)) row raw replace

format _freq std %5.0f

gen marcoh1 = marcoh - 2 
gen marcoh2 = marcoh + 2 
gen y = -7

twby racem racef , compact left xoffset(.4)                           ///
    title("Raw row percentages and row percentages standardized"      ///
          "to marginal distributions of marriage cohort 2010-2017") : ///
    twoway bar _freq marcoh1 , barwidth(4) scheme(s1color)         || ///
           bar std   marcoh2 , barwidth(4)                            ///
           legend(order(1 "raw" 2 "standardized"))                    ///
           ytitle(row percentages)                                    ///
           xlab(1950 "1950-1959"                                      ///
                1960 "1960-1969"                                      ///
                1970 "1970-1979"                                      ///
                1980 "1980-1989"                                      ///
                1990 "1990-1999"                                      ///
                2000 "2000-2009"                                      ///
                2010 "2010-2017", angle(30))                          ///
           yscale(off range(0 105)) ytitle("") ylab(none)          || ///
           scatter y marcoh1 ,                                        ///
           msymbol(i) mlab(_freq) mlabpos(0) mlabcolor(black)      || ///
           scatter std marcoh2 ,                                      ///
           msymbol(i) mlab(std) mlabpos(12) mlabcolor(black) 
                