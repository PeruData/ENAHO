global ccc "/Users/Sebastian/Documents/Papers/Mines SSB/00_Data"
cd "$ccc"

*This is similar to "destring", but handles bugged cases properly (value = . for these cases)
cap program drop destring2
program define destring2
    syntax anything
	local type: type `anything'
	if substr("`type'",1,3) == "str" {
	    gen `anything'_new = real(`anything')
	    drop `anything'
	    rename `anything'_new `anything'
		}
    end
	
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
*1. Clean
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
local key_vars conglome vivienda hogar	
forvalues yy = 1997/2017 {
	*Renames based on survey's official documentation (translating names using .doc files for 1997-1998)	
	if `yy' == 1997 {
	    local use_vars_97 con viv hog p300n niveduca anoaprob leeescri
	    use `use_vars_97' using "Enaho/in/Raw Data/module 03/`yy'/`yy'.dta", clear
	    rename con   conglome
		rename viv   vivienda
		rename hog   hogar
		rename p300n codperso
		
		rename niveduca p301a
		rename anoaprob p301b
		rename leeescri p302
		
		gen    p301c =  p301b
		}
	
	else { 
	    local use_vars `key_vars' codperso p301a p301b p301c p302
	    use `use_vars'  using "Enaho/in/Raw Data/module 03/`yy'/`yy'.dta", clear	
		}
	gen year=`yy'
	
	*Harmonize levels of p301a so that it is comparable across years
	if `yy' == 1997 {
	    *recode to 1998 (and onward) codes
	    gen     new_var = p301a 
	    replace new_var = 4     if p301a == 3 & p301b == 5
		replace new_var = 5     if p301a == 4 & p301b != 5
		replace new_var = 6     if p301a == 4 & p301b == 5
		replace new_var = 7     if p301a == 5
		replace new_var = 8     if p301a == 6
		replace new_var = 9     if p301a == 7
		replace new_var = 10    if p301a == 8
		replace new_var = .     if p301a == 9
		drop p301a
		rename new_var p301a	
		}
	if `yy' == 1998 | `yy' == 1999 {
		replace p301a = . if p301a == 99
		}
	if `yy' == 2000 {
	    gen     new_var = p301a 
		*get rid of the "bachillerato" category, unique for this year
		forvalues i = 7/11{
		    local new_value = `i' - 1
			replace new_var = `new_value' if p301a == `i'
			}
		replace new_var = . if p301a == 99
		drop p301a
		rename new_var p301a	
		}
	gen     elite = (p301a==11)
	replace elite = . if p301a == .
	foreach var in p301a p301b p301c p302 {
		capture destring `var', replace
		capture recode `var' 99=.
	    }

	recode p302 9=. 2=0
	rename p302 literacy
    
	cap label drop p301a
	label define p301a 1 "Sin educ" 2 "Inicial" 3 "Prim incomp" 4 "Prim complete" 5 "Sec incomp" 6 "Sec complete" 7 "Tert no univ incom" 8 "Tert no univ complete" 9 "Tert univ incom" 10 "Tert univ comp" 11 "Postgrad"
	label values p301a p301a
    
	*Estimates of years (Aragon & Rud)
	*tmp_years are years on last (possibly uncompleted) level
	egen    tmp_years = rowmax(p301b p301c)
	gen     educ      = .
	replace educ      = tmp_years    if  p301a==3 & tmp_years<6
	replace educ      = 6            if (p301a==3 & tmp_years>=6 & tmp_years!=.) | p301a==4
	replace educ      = 6+tmp_years  if  p301a==5 & tmp_years<=5
	replace educ      = 11           if (p301a==5 & tmp_years>=5 & tmp_years!=.) | p301a==6
	replace educ      = 11+tmp_years if  p301a>=7 & p301a!=. & tmp_years!=.
	
	*Categorical variable
	gen 	     g_educ = 1 if p301a== 1 | p301a==2  | p301a==3
	replace      g_educ	= 2 if p301a== 4 | p301a==5
	replace 	 g_educ	= 3 if p301a== 6 | p301a==7  | p301a==9
	replace 	 g_educ	= 4 if p301a== 8 | p301a==10 | p301a==11
	label define g_educ 1 "None or primary incomplete" 2 "Primary complete or secondary incomplete" 3 "Secondary complete or tertiary incomplete" 4 "Tertiary complete" 
	label values g_educ g_educ 
	
	*Alternative categorical variable (Fernandez & Messina, JDE)
	gen 	     g_educ_FM = 1 if p301a== 1 | p301a==2  | p301a==3 | p301a == 4
	replace      g_educ_FM = 2 if p301a== 5
	replace 	 g_educ_FM = 3 if p301a== 6 
	replace 	 g_educ_FM = 4 if p301a== 7 | p301a == 9
	replace 	 g_educ_FM = 5 if p301a== 8 | p301a==10 | p301a==11
	label define g_educ_FM 1 "Primary or less" 2 "Secondary incomplete" 3 "Secondary complete" 4 "Tertiary incomplete"  5 "Tertiary complete"
	label values g_educ_FM g_educ_FM 
     
	foreach var in `key_vars' codperso {
	    destring2 `var'
		}

	keep year `key_vars' codperso educ g_educ g_educ_FM elite
	
	save "Trash/tmp_`yy'.dta", replace
	}

*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
*2. Append
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
clear
forvalues yy=1997/2017{
	append using "Trash/tmp_`yy'.dta"
    }
keep if !missing(codperso)
compress
forvalues yy=1997/2017{
	erase "Trash/tmp_`yy'.dta"
    }

*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
*3. Labels
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
label var educ   "Years of education"
label var g_educ "Educational group"
save "Trash/data_300.dta", replace
