*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
*1. Clean
*TO DO: RECOVER FIRM SIZE VARIABLE P517D
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
*On factors:
	*------------------------------------------------------------------------------------------
	*SPSSs[anterior] have these (throughout 1997-2017)
		*factorem         = "factor of labor module - 1993 Census" (1997)
		*fac_empl         = "factor of labor module - 1993 Census" (1998, 1999)
		*factor           = "factor of summary module" (2000-2006)
		*fac500           = "factor of labor module - 1993 Census" (2000-2006)
		*fac500a7/fac500a = "factor of labor module - 2007 Census" (2001-2006) (often missing) 
	*------------------------------------------------------------------------------------------
	*DBFs[anetior until 2004 then actualizada] have these: (1997, 2000-2017)
	    *factorem         = "factor of labor module - 1993 Census" (1997)
		*factor           = "factor of summary module"
		*fac500           = "factor of labor module - 1993 Census"
		*fac500a7/fac500a = "factor of labor module - 2007 Census" (often missing)
		*missing factors: 1998 and 1999
    *------------------------------------------------------------------------------------------
	
*missing ocu500: 1998, 1999 and 2000
local key_vars conglome vivienda hogar
forvalues yy = 1997/2017 {
    di "doing `yy'"
	*Renames based on survey's official documentation (translating names using .doc files for 1997-1998)	
	if `yy' == 1997 {
	    local use_vars_97 con viv hog codpers2 factorem ocupa ocprinci ocpciiuu ocpcateg ocphorto indpago ingdliq ingindep ingsecun
	    use `use_vars_97' using "Enaho/in/Raw Data/module 05/`yy'/`yy'.dta", clear
	    rename con      conglome
		rename viv      vivienda
		rename hog      hogar
		rename codpers2 codperso
		
		rename factorem fac500
		rename ocupa    ocu500
		
		rename ocprinci p505	
		rename ocpciiuu p506	
		rename ocpcateg p507	
		rename ocphorto p513t	
		rename indpago  p523
		rename ingdliq  p524a1
		rename ingindep p530a
		rename ingsecun p538a1
		*1997's survey does not distinguish between dependent/independent secondary income, 
		*solution:   create empty independent var (else problems later in the code). 
		*WARNING: Do not attempt to analyze secondary occupation earnings along this margin for year 1997.
		gen p541a = .
		}
	local use_questions p505* p506* p507 p513t p523 p524a1 p530a p538a1 p541a
	if `yy' == 1998 | `yy' == 1999 {
        use `key_vars' codperso `use_questions' using "Enaho/in/Raw Data/module 05/`yy'/`yy'.dta", clear	
		gen ocu500 =.
		gen fac500=.
		}
	if `yy' == 2000 {
        use `key_vars' codperso fac* `use_questions' using "Enaho/in/Raw Data/module 05/`yy'/`yy'.dta", clear	
		gen ocu500 =.
		}
	if `yy'>=2001 {
		use `key_vars' codperso fac* ocu500 `use_questions' using "Enaho/in/Raw Data/module 05/`yy'/`yy'.dta", clear	
		}
	gen year=`yy'
	
	*Harmonizes sample weight variables
		if `yy' == 2011  {
			rename fac500a7 fac500a
			}
		if `yy' == 2001 | `yy' == 2002 | `yy' == 2003 {
			rename fac500a7_x fac500a
			drop *_x *_y
			}
	foreach var in `key_vars' codperso {
	    cap decode `var',replace
	    destring `var', force replace //manually verified that non-numeric data points are irrelevant
		}
	keep year `key_vars' codperso fac* ocu500 `use_questions'
	save "Trash/tmp_`yy'.dta", replace
	}

*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
*2. Append
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  	
clear
forvalues yy = 1997/2017 {
	append using "Trash/tmp_`yy'.dta", force 
	}
keep if !missing(codperso)	
compress
forvalues yy=1997/2017{
	erase "Trash/tmp_`yy'.dta"
	}

*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
*3. Calculate Labor Variables
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

*merging variables of ocupation and activities
	*Debug:
	local bugged_vars p524a1 p530a p538a1 p541a 
    foreach var in `bugged_vars' {
	    replace `var' = . if `var' == 999999  | `var' == 99999
		}
	*3.1 Monthly monetary income (this exludes income "in kind")  
	*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
        *2.1.1 Labor Market Income
		*For independent workers, income (p530a) always monthly
		*For dependent workers, income (p524a1) may be daily, weekly, bi-weekly or monthly (p523 indicates frequency)
		
		*Primary Dependent income to monthly (multipliers taken from Aragon & Rud, AEJ:EP 2013)
			gen y_pri_dep = 0 if !missing(p524a1) & !missing(p523)
			*Daily (assume 260 payments each year, so 260/12 payments each month)
				replace y_pri_dep   = p524a1 * 260/12 if p523 == 1
			*Weekly (assume 52 payments each year, so 52/12 payments each month)	
				replace y_pri_dep   = p524a1 * 52/12  if p523 == 2
			*Bi-Weekly ("quincenal" in spanish, assume 2 each month)
				replace y_pri_dep   = p524a1 * 2      if p523 == 3
			*Monthly
				replace y_pri_dep   = p524a1 * 1      if p523 == 4			
		rename p530a y_pri_indep
		egen y_pri = rowtotal(y_pri_dep y_pri_indep)  if  !missing(y_pri_dep) | !missing(y_pri_ind)
		rename p538a1  y_sec_dep
		rename p541a   y_sec_ind
		egen y_sec = rowtotal(y_sec_dep y_sec_ind) 
		egen y_mkt = rowtotal(y_pri y_sec)  
				
	*3.2 Market work hours (weekly)
	*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
		rename p513t mkt_work_pri
				
	*3.3 Hourly income (as in 3.1, monthly work is hourly work times 52/12)
	*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
		gen y_pri_h = y_pri/(mkt_work_pri*4)
		
	*3.4 Job characteristics
	*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
		*3.4.1 Self-employed dummy
		gen    self_employed = (p507 == 1 | p507 == 2) if p507 !=.
		
		*3.4.2 Get "ciiu_code" variable [used for groups based on UN's "REV 4" document]
		gen p506r4_str = string(p506r4)
		replace p506r4_str = "0" + p506r4_str if length(p506r4_str) ==3
		gen ciiu_code =  substr(p506r4_str, 1, 2)
		*This imputes the variable for years 1997-2006 using 2007-2016 data and old-coded variable
		preserve
		    keep if year>2006
			*TO DO: robustness to alternative conversion algorithm, current is mode (min mode if many modes)
		    egen     ciiu_code_mode = mode(ciiu_code), by(p506) minmode
		    destring ciiu_code_mode, replace
		    collapse ciiu_code_mode, by(p506)
			tostring ciiu_code_mode, replace
			rename   ciiu_code_mode ciiu_code
			keep ciiu_code p506
			tempfile temp
			save `temp', replace
		restore
		preserve
		    keep if year<=2006
			drop ciiu_code
			merge m:1 p506 using `temp', nogen
			save `temp', replace
		restore
		keep if year>2006
		append using `temp'
		drop if codperso == .
        replace ciiu_code = "" if ciiu_code == "."
		replace ciiu_code = "0" + ciiu_code if length(ciiu_code) == 1
				
		*3.4.3  Get "ciuo_code" variable [used for groups based on Lavado's wp (PEA series, Table XX)], note that Lavado's codes are not guaranteed to work before 2004
		gen ciuo_code     =  substr(string(p505), 1, 2)
		replace ciuo_code = "" if ciuo_code == "."
		
		*3.4.4 Create groups using (2.4.2) and (2.4.3)'s output
		qui do "$ccc_dofiles/prepare_500_ciuo_ciiu.do"
		
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
*3. Variable Labels
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  


label var ocu500        "Labor force (PEA) category"
label var ciiu_code     "Industry ciiu - principal activ"
label var ciuo_code     "Ocupation code (ISCO)"
label var g_ciiu        "Groups for industry code (ISIC) - low level aggregate"
label var g_hl_ciiu     "Groups for industry code (ISIC) - high level aggregate"
label var g_ciuo        "Groups for occupation code (ISCO)"
label var mkt_work_pri  "Weekly hours working on primary occupation"
label var self_employed "Dummy for self-employment"
label var y_pri         "Monetary income on primary occupation (monthly, current PEN)"
label var y_pri_h       "Monetary income on primary occupation (hourly, current PEN)"
label var y_sec         "Monetary income on secondary occupation (monthly, current PEN)"
label var y_mkt         "Monetary labor market incom (monthly, current PEN)"

compress
keep year `key_vars' codperso fac* g_ciiu g_hl_ciiu g_ciuo mkt_work_pri ocu500 self_employed y_pri y_pri_h y_sec y_mkt p523 p524a1
save "$ccc/Trash/data_500.dta", replace
