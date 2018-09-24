*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
*1. Clean
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - 
*Missing values for certain month-years are 100% by design 
*Do Manski bounds on these

*These variables' names are stable across 1997-2017
local key_vars conglome vivienda hogar
local use_vars_97_17 gashog1d gashog2d gru11hd gru21hd gru31hd gru41hd gru51hd gru61hd gru71hd gru81hd ingmo1hd inghog2d mieperho pobreza
forvalues yy=1997/2017{
	*Renames based on survey's official documentation (translating names using .doc files for 1997-1998)	
	if `yy' == 1997 {    
	    local use_vars_97 con viv hog  linea97 linpe97 factorho `use_vars_97_17'
	    use `use_vars_97' using "Enaho/in/Raw Data/module 34/`yy'/`yy'.dta", clear	
		*use "Enaho/in/Raw Data/module 34/`yy'/`yy'.dta", clear	
	    rename con      conglome
		rename viv      vivienda
		rename hog      hogar		
		}
	local use_vars `key_vars' fac* linea linpe mieperho `use_vars_97_17'
	if `yy' >= 1998 {
        use `use_vars' using "Enaho/in/Raw Data/module 34/`yy'/`yy'.dta", clear	
		}
	*Sometimes linea/linpe variables have names codified with a structure "linea`yy'" 
	rename linea* linea
	rename linpe* linpe
	gen year=`yy'
	
	foreach var in `key_vars' {
	    destring2 `var'
		}
	sort year `key_vars'
	
	keep year `key_vars' `use_vars_97_17' linea linpe fac*
	save "Trash/tmp_`yy'.dta", replace
	}

*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
*2. Append
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
clear
forvalues yy=1997/2017{	
	append using "Trash/tmp_`yy'.dta"
	}	

*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
*3. Generate household-level variables
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

gen poor     = (pobreza == 1)
gen poor_ext = (pobreza <= 2)
gen no_poor  = (pobreza == 3)

*Based on Aragon & Rud (AEJ:EP 2013)

gen y_raw = ingmo1hd/mieperho/3 if year <=2002
gen y     = inghog2d/mieperho/3 if year <=2002
gen exp   = gashog2d/mieperho/3 if year <=2002

replace y_raw = ingmo1hd/mieperho/12 if year >= 2003
replace y     = inghog2d/mieperho/12 if year >= 2003
replace exp   = gashog2d/mieperho/12 if year >= 2003

gen y_rel   =   y/linea
gen exp_rel = exp/linea

*Consumption by type	
*Type 1: food 
*Type 2: clothes
*Type 3: home rent, fuel and utilities
*Type 4: funiture and home maintenance
*Type 5: healthcare
*Type 6: transport and communication
*Type 7: leisure, education and cultural activities

egen exp_1 = rowtotal(gru11hd) 
egen exp_2 = rowtotal(gru21hd)
egen exp_3 = rowtotal(gru31hd)
egen exp_4 = rowtotal(gru41hd)
egen exp_5 = rowtotal(gru51hd)
egen exp_6 = rowtotal(gru61hd)
egen exp_7 = rowtotal(gru71hd)

*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
*4. Variable Labels
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
label var exp_1 "expenditures on food "
label var exp_2 "expenditures on clothes"
label var exp_3 "expenditures on household maintenance and rent"
label var exp_4 "expenditures on furnishes"
label var exp_5 "expenditures on health services and goods"
label var exp_6 "expenditures on transport and comms"
label var exp_7 "expenditures on leisure"

label var poor     "Is poor"
label var poor_ext "Is extremely poor"

label var linea "Linea total"
label var linpe "Linea de alimentos"

label var y_raw "Raw monetary HH income per capita (monthly, current PEN)"
label var y     "Net HH income per capita (monthly, current PEN)"
label var exp   "Total expenditures per capita (monthly, current PEN)"

label var y_rel   "HH pc income relative to poverty line"
label var exp_rel "Expenditure relative to poverty line"

label var linea "Poverty line"
label var linpe "Extreme poverty line"

compress

*cleaning 

forvalues yy=1997/2017{
	erase "Trash/tmp_`yy'.dta"
    }
save "Trash/data_sumaria.dta", replace


