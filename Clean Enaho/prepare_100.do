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
local raw_tokeep p101 p102 p103 p104 p105a p105b d105b i105b p106 d106 i106      
local key_vars   conglome vivienda hogar
forvalues yy = 1997/2017 {
    di "year `yy'"
	di " "
	*Renames based on survey's official documentation (translating names using .doc files for 1997-1998)	
	if `yy' == 1997 {
	    use "Enaho/in/Raw Data/module 01/`yy'/`yy'.dta", clear
		rename s1con conglome
		rename s1viv vivienda
		rename s1hog hogar
		
		rename ubi      ubigeo
		rename resencue resultado
		
		rename abasagua p110
		rename serhigie p111
		rename tienfono p1141
		rename tiencelu p1142
		rename alumbra1 p1121
		
		rename tipvivie  p101
		rename matpared p102
		rename matpiso  p103
		rename tothabit p104
		rename tenenviv p105a
		rename alqmens1 p105b
		rename alqme1de d105b
		rename alqme1im i105b
		
		rename alqmens2 p106
		rename alqme2de d106
		rename alqme2im i106
		
		*TO WORK ON:----------
		rename fecentre date
		*----------------------
		}	
	else if `yy' == 1998 {
	    local use_vars `key_vars' `raw_tokeep' p110 p111 p1121 p1141 p1142 estrato dominio result*  ubigeo
	    use `use_vars' using "Enaho/in/Raw Data/module 01/`yy'/`yy'.dta", clear
		}
	else if `yy' == 2001 {
	    local use_vars `key_vars' `raw_tokeep' p110 p111 p1121 p1141 p1142 estrato dominio result*  ubigeo fecha
	    use `use_vars' using "Enaho/in/Raw Data/module 01/`yy'/`yy'.dta", clear
		}
	else {
	    local use_vars `key_vars' `raw_tokeep' p110 p111 p1121 p1141 p1142 estrato dominio result*  ubigeo fecent*
	    use `use_vars' using "Enaho/in/Raw Data/module 01/`yy'/`yy'.dta", clear
		}
	gen year = `yy'	
	if `yy'>= 1998 & `yy'  <= 2002 {
	    rename result01 result
		}
	*TO WORK ON:------------------------------------------	
	if `yy'== 1998 {
	    gen date = .
		}	
	if `yy' == 1999 | `yy' == 2000 | `yy' ==2002 {
	    rename fecent01 date
		}	
	if `yy'== 2001 {
	    rename fecha date
		}
	if `yy' >= 2003 {
	    rename fecent date
		}
	*---------------------------------------------------
	gen     water  =     (p110 == 1 | p110 == 2)
	replace water  = . if p110 == .	
	gen     sewage =     (p111 <= 3)
	replace sewage = . if p111 == .
	
	rename p1121 electricity 
		
	gen     phone =     (p1141==1 | p1142==1)
	replace phone = . if p1141==. | p1142==.
	
	*town_size variable "estrato" does not have stable levels across the full 1997-2017 period
	*solution: follow Aragon & Rud (AEJ:EP 2013) for 1997-2015 (note that they classify towns with 400 pop or less as "urban")
	*on 2016 coding of the variable changed, so must write code for 2016 and 2017, here we prioritize comparability across years
	
	if `yy' <= 2000 {
		rename estrato town_size
		recode town_size 1=5 2=4 3=3 4=2 5=1
	    }
	if `yy' >= 2001 & `yy' <= 2015 {
		rename estrato town_size
		recode town_size 1=5 2=5 3=4 4=4 5=3 6=3 7=2 8=1
	    }
	if `yy' >= 2016 {
		rename estrato town_size
		recode town_size 1=5 2=5 3=5 4=5 5=4 6=3 7=2 8=1
	    }
	*note that these categories don't necessarily hold outside 2002-2015 period 
	*    in 2016-2017 they do approximately, by design: the only difference is that "small urban" denotes pop < 2k (4k threshold not available) [TO FIX!]
	*    also, urban towns with less than 400 pop no longer exist (likely they are all classified as rural starting from 2016, but this is not explicit in the documentation)
	label define town_size 1 "Small rural" 2 "Large rural" 3 "Small urban (pop < 4k)" 4 " Medium urban (pop in [4k,20k])" 5 "Large urban (pop>20k)"
	label values town_size town_size
	
	gen urban = (town_size >= 3) if !missing(town_size)
	label define urban 1 "Urban" 0 "Rural"
	label values urban urban
	
	foreach var in `key_vars' ubigeo {
	    destring2 `var'
		}
	sort year `key_vars'
	
	keep `key_vars' date town_size ubigeo dominio urban year electricity phone result sewage water `raw_tokeep'
	save "Trash/tmp_`yy'.dta", replace
	}

*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
*2. Append
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  	
clear
forvalues yy=1997/2017{
	append using "Trash/tmp_`yy'.dta"
	}
compress	
forvalues yy=1997/2017{
	erase "Trash/tmp_`yy'.dta"
	}

*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
*3. Administrative region variables
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  	
tostring ubigeo, gen(district)
replace district = "0" + district if length(district) == 5
gen department   = substr(district,1,2)
gen province     = substr(district,1,4)

gen     dep_name = ""
replace dep_name = "AMAZONAS"      if department == "01"
replace dep_name = "ANCASH"        if department == "02"
replace dep_name = "APURIMAC"      if department == "03"
replace dep_name = "AREQUIPA"      if department == "04"
replace dep_name = "AYACUCHO"      if department == "05"
replace dep_name = "CAJAMARCA"     if department == "06"
replace dep_name = "CALLAO"        if department == "07"
replace dep_name = "CUSCO"         if department == "08"
replace dep_name = "HUANCAVELICA"  if department == "09"
replace dep_name = "HUANUCO"       if department == "10"
replace dep_name = "ICA"           if department == "11"
replace dep_name = "JUNIN"         if department == "12"
replace dep_name = "LA LIBERTAD"   if department == "13"
replace dep_name = "LAMBAYEQUE"    if department == "14"
replace dep_name = "LIMA"          if department == "15"
replace dep_name = "LORETO"        if department == "16"
replace dep_name = "MADRE DE DIOS" if department == "17"
replace dep_name = "MOQUEGUA"      if department == "18"
replace dep_name = "PASCO"         if department == "19"
replace dep_name = "PIURA"         if department == "20"
replace dep_name = "PUNO"          if department == "21"
replace dep_name = "SAN MARTIN"    if department == "22"
replace dep_name = "TACNA"         if department == "23"
replace dep_name = "TUMBES"        if department == "24"
replace dep_name = "UCAYALI"       if department == "25"

*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
*4. Labels
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
label var p101 "Type of dwelling"
label var p102 "Material (walls)"
label var p103 "Material (floor) "
label var p104 "Nr rooms"

replace   p105b=. if p105a!=1
label var p105b "Paid monthly rent (only tenants)"
label var d105b "Paid monthly rent (deflated)"
label var i105b "Paid monthly rent (imputed)"

label var p106 "Self reported asking monthly rent"
label var d106 "Self reported asking monthly rent (deflated)"
label var i106 "Self reported asking monthly rent (imputed)"

label var electricity "Has electricity"
label var phone "Has fixed or mobile phone"
label var sewage "has sewage"
label var water "Has water"

label var result "Resultado de la encuesta"

*recode missings (as in Aragon & Rud AEJ:EP)
recode p106  9999 = .
recode p105b 9999 = .
recode d105b 9999 = .

save "Trash/data_100.dta", replace
