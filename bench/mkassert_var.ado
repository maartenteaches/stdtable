program define mkassert_var
	syntax varname(numeric), [tol(string)]
	if "`tol'" == "" local tol "1e-8"
	forvalues i = 1/`=_N' {
		local todisplay = "assert reldif( `varlist'[`i'], `: display %18.0g `varlist'[`i']' ) < `tol'" 
		di `"`todisplay'"'
	}
end
