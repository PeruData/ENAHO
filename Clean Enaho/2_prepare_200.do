*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - 
*1. Clean
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
local key_vars conglome vivienda hogar
forvalues yy = 1997/2018{
	*Renames based on survey's official documentation (translating names using .doc files for 1997-1998)	
	if `yy' == 1997 {
	    local use_vars_97 s2con s2viv s2hog codperso edad edadtiem parentes miembro sexo
	    use `use_vars_97' using "Enaho/in/Raw Data/module 02/`yy'/`yy'.dta", clear
		
	    rename s2con conglome
		rename s2viv vivienda
		rename s2hog hogar
		
		replace edad = 0 if edadtiem == 2
		rename edad     p208a
		rename parentes p203
		rename miembro  p204
		rename sexo     p207
		}
	else {
	    local use_vars `key_vars' codperso p203 p204 p207 p208* ubigeo 
	    use `use_vars' using "Enaho/in/Raw Data/module 02/`yy'/`yy'.dta", clear
		}
	gen year=`yy'
	
	if `yy' <= 2000 {
	    gen p208a1 = .
		gen p208a2 = .
		}

	gen year_born = year - p208a 
	
	rename  p203 place
	replace place = . if place==0
	
	rename p204 ismember
	recode ismember 2=0
	
	rename p207 isfemale
	recode isfemale 2=1 1=0
	label define isfemale 0 "Male" 1 "Female"
	label values isfemale isfemale 

	
	rename  p208a  age
		
	if `yy' == 2018 {
	    gen born_here   = .
		gen born_ubigeo = .
		}
	else {
	    rename  p208a1 born_here 
        rename  p208a2 born_ubigeo
	    }
	
	
	gen 	     g_cohort =  1  if year_born>=1951 & year_born<=1960
	replace      g_cohort =  2  if year_born>=1961 & year_born<=1970
	replace 	 g_cohort =  3  if year_born>=1971 & year_born<=1980
	replace 	 g_cohort =  4  if year_born>=1981 & year_born<=1990
	replace 	 g_cohort =  5  if year_born>=1991 & year_born<=2000
	replace 	 g_cohort =  6  if year_born>=2001 & year_born<=2010
	replace      g_cohort = -99 if g_cohort == . & age != .
	label define g_cohort 1 "1950s" 2 "1960s" 3 "1970s" 4 "1980s" 5 "1990s" 6 "2000s", replace
	label values g_cohort g_cohort 

	gen 		 g_age = 1 if age>=16 & age<=24
	replace 	 g_age = 2 if age>=25 & age<=34
	replace      g_age = 3 if age>=35 & age<=44
	replace 	 g_age = 4 if age>=45 & age<=54
	replace 	 g_age = 5 if age>=55 & age<=65
	label define g_age 1 "18-24" 2 "25-34" 3 "34-45" 4 "45-54" 5 "55-65", replace
	label values g_age g_age 
	
    foreach var in conglome vivienda hogar codperso born_ubigeo {
	    destring `var', force replace //manually verified that non-numeric data points are irrelevant
		}
	replace born_ubigeo=. if born_ubigeo<10101 | born_ubigeo==806001 | born_ubigeo== 999999
	
	keep year year_born `key_vars' codperso age born_here born_ubigeo isfemale place g_age g_cohort
	save "Trash/tmp_`yy'.dta", replace
	}
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
*2. Append
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
clear
forvalues yy = 1997/2018 {
	append using "Trash/tmp_`yy'.dta"
    }
keep if !missing(codperso)
compress	
forvalues yy = 1997/2018 {
	erase "Trash/tmp_`yy'.dta"
    }

*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
*3. Labels
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
label var place       "Relation with head"
label var age         "Age in years"
label var born_ubigeo "District where born"


save "Trash/data_200.dta", replace
