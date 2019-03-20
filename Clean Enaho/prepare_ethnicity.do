cap program drop clean_ethnicity
program define clean_ethnicity
	gen     new_ethnicity = .
	replace new_ethnicity = 2 if ethnicity == 5
	replace new_ethnicity = 1 if ethnicity == 6
	replace new_ethnicity = 0 if ethnicity != . & new_ethnicity ==.
	drop ethnicity
	rename new_ethnicity ethnicity
	end
	
	
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
*1. Clean yearly
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
	
forvalues yy = 2004/2006 {
    use "Enaho/in/Raw Data/module 85/`yy'/enaho01b-`yy'-3.dta", clear
	gen year = `yy'
	rename p46 ethnicity
	tabmiss ethnicity
	qui clean_ethnicity 
	keep year conglome vivienda hogar ethnicity	
    save "Trash/tmp_`yy'.dta", replace
	} 

forvalues yy = 2007/2011 {
    use "Enaho/in/Raw Data/module 85/`yy'/enaho01b-`yy'-2.dta", clear
	gen year = `yy'
	rename p46 ethnicity
	clean_ethnicity
	keep year conglome vivienda hogar ethnicity	
	save "Trash/tmp_`yy'.dta", replace
	}
	
forvalues yy = 2012/2017 {
    use "Enaho/in/Raw Data/module 05/`yy'/`yy'.dta", clear
	keep if p203 == 1
	gen year = `yy'
	rename p558c ethnicity
	clean_ethnicity
	keep year conglome vivienda hogar ethnicity	
	save "Trash/tmp_`yy'.dta", replace
	}

*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
*2. Append
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
	
clear
forvalues yy = 2004/2017 {
    append using "Trash/tmp_`yy'.dta"
	}

foreach var in conglome vivienda hogar {
    destring `var', force replace //manually verified that non-numeric data points are irrelevant 
	}
save "Trash/data_ethnicity.dta", replace

