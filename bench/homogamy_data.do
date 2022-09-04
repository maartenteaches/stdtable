clear all

use "c:\Mijn documenten\projecten\loglin\ZA4578_v1-0-0.dta"
cd "c:\mijn documenten\projecten\stata\stdtable\1.0.0\bench"
gen sp_schule = cond(inlist(V1046,1, 2),1,      ///
                cond(inlist(V1046,3, 6), 2, 3)) ///
                if !inlist(V1046, 0, 7, 97, 98, 99) & V1048 != 1
replace sp_schule = cond(inlist(V934, 1, 2), 1,     ///
                    cond(inlist(V934, 3, 6), 2, 3)) ///
                    if !inlist(V934, 0, 9, 97, 98, 99) & sp_schule == .

gen sp_ausb = cond(V1049==1 | V1050==1 | V1051==1 | V1054==1, 1,            ///
              cond(V1052==1 | V1053==1 | V1055==1 | V1056==1 | V1057==1 | V1060==1, 2, ///
              cond(V1058==1 | V1059==1, 3,  .)))

replace sp_ausb = cond(inlist(V935, 1, 5), 1, ///
                  cond(inlist(V935, 2, 3, 4, 6, 9), 2, ///
                  cond(inlist(V935, 7, 8), 3, .))) if sp_ausb == .
replace sp_ausb = cond(V938==1 | V939==1 | V940==1 | V943==1, 1, ///
                  cond(V941==1 | V942==1 | V944==1 | V945==1| V946==1 | V949==1, 2, ///
                  cond(V947==1 | V948==1, 3, .))) if sp_ausb == .

gen speduc = cond(inlist(sp_schule, 1, 2) & sp_ausb==1, 1, ///
             cond(sp_schule==1 & sp_ausb==2           , 2, ///
             cond(sp_schule==2 & sp_ausb==2           , 3, ///
             cond(sp_schule==3 & inlist(sp_ausb, 1, 2), 4, ///
             cond(sp_ausb == 3                        , 5, .)))))

gen schule = cond(inlist(V668, 1, 2), 1, ///
             cond(inlist(V668, 3, 6), 2, ///
             cond(inlist(V668, 4, 5), 3, .)))

gen ausb = cond(inlist(V671, 1,5), 1, ///
           cond(inlist(V671, 2, 3, 4, 6, 9), 2, ///
           cond(inlist(V671,7, 8), 3, .)))
replace ausb = 1 if (V675==1 | V676==1 | V677==1 | V680== 1) & ausb == .
replace ausb = 2 if (V678==1 | V679==1 | V681==1 | V682 ==1 | V683 == 1 ) & ausb == . 
replace ausb = 3 if (V684==1 | V685==1) & ausb == .

gen educ = cond(inlist(schule, 1, 2) & ausb==1, 1, ///
           cond(schule==1 & ausb==2           , 2, ///
           cond(schule==2 & ausb==2           , 3, ///
           cond(schule==3 & inlist(ausb, 1, 2), 4, ///
           cond(ausb == 3                     , 5, .)))))  

gen meduc = cond(V653==1, educ, speduc)
label variable meduc "husband's education"
gen feduc = cond(V653==2, educ, speduc)
label variable feduc "wife's education"
label define ed 1 "low" ///
                2 "lower voc." ///
                3 "medium voc." ///
                4 "higher voc." ///
                5 "university"
label value meduc feduc speduc ed 


gen age = V2 - V649 if V649 < 9997
keep if inrange(age,30,75)
gen coh = floor(V649/10)*10 if V649 < 9997
drop if inlist(coh, 1900, 1980)
label var coh "birth cohort of reporting individual"
label define coh 1910 "1910-1919" /// 
                 1920 "1920-1929" /// 
                 1930 "1930-1939" /// 
                 1940 "1940-1949" /// 
                 1950 "1950-1959" /// 
                 1960 "1960-1969" /// 
                 1970 "1970-1979" 
label value coh coh
  
rename V1739 weight
keep meduc feduc coh weight
compress

saveold homogamy, replace version(11)
