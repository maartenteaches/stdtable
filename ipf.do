clear all
set rmsg on
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

gen foo = 20
poisson foo i.row i.col, exposure(pop)
predict mu
tabdisp row col, cell(mu)

preserve
contract row col [fw=pop]
reshape wide _freq, i(row) j(col)
restore

mata:
mata clear

mata set matastrict on

real matrix std_ipf(string scalar data   , 
                    string scalar rowname,
                    string scalar colname,
                    real   scalar tol    ,
                    real   scalar iter   ) {

	real matrix    muhat, muhat2
	real colvector r
	real rowvector c
	real scalar    i
 
	muhat  = st_matrix(data)
	r      = st_matrix(rowname)
	c      = st_matrix(colname)
	muhat2 = 0:*muhat
	i      = 1

	while(i < iter & mreldif(muhat2,muhat) > tol) {
		muhat2 = muhat
		muhat = muhat :* ( r :/ quadrowsum(muhat) )
		muhat = muhat :* ( c :/ quadcolsum(muhat) )
		i++
	}
	if (--i==iter & mreldif(muhat2,muhat) > tol) {
		exit(error(430))
	}
	else {
		return(muhat)
	}
}



end
