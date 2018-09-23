*Input: ciuo_code and ciiu_code variables in string format

*1. Low-level ciiu groups (21 categories, the standard in "UN Doc ISIC REV 4.pdf")
gen g_ciiu = .
	*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
	replace g_ciiu = 1 if ciiu_code == "01" | ciiu_code == "02" | ciiu_code == "03" 
	
	replace g_ciiu = 2 if ciiu_code == "05" | ciiu_code == "06" | ciiu_code == "07"
	replace g_ciiu = 2 if ciiu_code == "08" | ciiu_code == "09"
	
	replace g_ciiu = 3 if ciiu_code == "10" | ciiu_code == "11" | ciiu_code == "12"
	replace g_ciiu = 3 if ciiu_code == "13" | ciiu_code == "14" | ciiu_code == "15"
	replace g_ciiu = 3 if ciiu_code == "16" | ciiu_code == "17" | ciiu_code == "18"
	replace g_ciiu = 3 if ciiu_code == "19" | ciiu_code == "20" | ciiu_code == "21"
	replace g_ciiu = 3 if ciiu_code == "22" | ciiu_code == "23" | ciiu_code == "24"
	replace g_ciiu = 3 if ciiu_code == "25" | ciiu_code == "26" | ciiu_code == "27"
	replace g_ciiu = 3 if ciiu_code == "28" | ciiu_code == "29" | ciiu_code == "30"
	replace g_ciiu = 3 if ciiu_code == "31" | ciiu_code == "32" | ciiu_code == "33"

	replace g_ciiu = 4 if ciiu_code == "35"
	
	replace g_ciiu = 5 if ciiu_code == "36" | ciiu_code == "37" | ciiu_code == "38"
	replace g_ciiu = 5 if ciiu_code == "39"
	
	replace g_ciiu = 6 if ciiu_code == "41" | ciiu_code == "42" | ciiu_code == "43"
	
	replace g_ciiu = 7 if ciiu_code == "45" | ciiu_code == "46" | ciiu_code == "47"
	
	replace g_ciiu = 8 if ciiu_code == "49" | ciiu_code == "50" | ciiu_code == "51"
	replace g_ciiu = 8 if ciiu_code == "52" | ciiu_code == "53"

	replace g_ciiu = 9 if ciiu_code == "55" | ciiu_code == "56"
	
	replace g_ciiu = 10 if ciiu_code == "58" | ciiu_code == "59" | ciiu_code == "60"
	replace g_ciiu = 10 if ciiu_code == "61" | ciiu_code == "62" | ciiu_code == "63"
	
	replace g_ciiu = 11 if ciiu_code == "64" | ciiu_code == "65" | ciiu_code == "66"
	
	replace g_ciiu = 12 if ciiu_code == "68"
	
	replace g_ciiu = 13 if ciiu_code == "69" | ciiu_code == "70" | ciiu_code == "71"
	replace g_ciiu = 13 if ciiu_code == "72" | ciiu_code == "73" | ciiu_code == "74"
	replace g_ciiu = 13 if ciiu_code == "75" 

	replace g_ciiu = 14 if ciiu_code == "77" | ciiu_code == "78" | ciiu_code == "79"
	replace g_ciiu = 14 if ciiu_code == "80" | ciiu_code == "81" | ciiu_code == "82"
	
	replace g_ciiu = 15 if ciiu_code == "84"
	
	replace g_ciiu = 16 if ciiu_code == "85"
	
	replace g_ciiu = 17 if ciiu_code == "86" | ciiu_code == "87" | ciiu_code == "88"
	
	replace g_ciiu = 18 if ciiu_code == "90" | ciiu_code == "91" | ciiu_code == "92"
	replace g_ciiu = 18 if ciiu_code == "93"
	
	replace g_ciiu = 19 if ciiu_code == "94" | ciiu_code == "95" | ciiu_code == "96"
	
	replace g_ciiu = 20 if ciiu_code == "97" | ciiu_code == "98"
	
	replace g_ciiu = 21 if ciiu_code == "99"
	*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
label define g_ciiu 1 "A: Agriculture/Fishing" 2 "B: Mining" 3 "C: Manufacturing" 4 "D: Energy" 5 "E: Water/Trash" 6 "F: Construction" 7 "G: Commerce" 8 "H: Transportation" 9 "I: Restaurants/Hotels" 10 "J: Telecom" 11 "K: Finance" 12 "L: Real Estate" 13 "M: Professional services/Research" 14 "N: Private Admin" 15 "O: Public Admin" 16 "P: Teaching" 17 "Q: Health" 18 "R: Art" 19 "S: Other services" 20 "T: Housework" 21 "U: Foreign Org."
label values g_ciiu g_ciiu		

*2. High-level ciiu groups (10 categories, based Table 4.1 in "UN Doc ISIC REV 4.pdf")		

gen g_hl_ciiu = .
	*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
	replace g_hl_ciiu =  1 if g_ciiu == 1
	replace g_hl_ciiu =  2 if g_ciiu == 2 | g_ciiu == 3 | g_ciiu == 4 | g_ciiu == 5
	replace g_hl_ciiu =  3 if g_ciiu == 6
	replace g_hl_ciiu =  4 if g_ciiu == 7 | g_ciiu == 8 | g_ciiu == 9
	replace g_hl_ciiu =  5 if g_ciiu == 10
	replace g_hl_ciiu =  6 if g_ciiu == 11
	replace g_hl_ciiu =  7 if g_ciiu == 12
	replace g_hl_ciiu =  8 if g_ciiu == 13 | g_ciiu == 14
	replace g_hl_ciiu =  9 if g_ciiu == 15 | g_ciiu == 16 | g_ciiu == 17
	replace g_hl_ciiu = 10 if g_ciiu == 18 | g_ciiu == 19 | g_ciiu == 20 | g_ciiu == 21
	*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
label define g_hl_ciiu 1 "I: Agriculture/Fishing" 2 "II: Mining/Manufacturing/Utilities" 3 "III: Construction" 4 "IV: Commerce/Transportation/Restaurants" 5 "V: Telecom" 6 "VI: Finance" 7 "VII: Real Estate" 8 "VIII: Professional/Research/Private Admin" 9 "IX: Public Admin/Teaching/Health" 10 "X: Other services"
label values g_hl_ciiu g_hl_ciiu		

*3. High-level ciuo groups (based on Lavado, Martinez and Yamada "promesa incumplida" 2014 wp (Table XX))
gen g_ciuo = .
	*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
	replace g_ciuo = 1 if ciuo_code == "11" | ciuo_code == "12" | ciuo_code == "13" 
	replace g_ciuo = 1 if ciuo_code == "14" | ciuo_code == "21" | ciuo_code == "22" 
	replace g_ciuo = 1 if ciuo_code == "23" | ciuo_code == "24" | ciuo_code == "25"
	replace g_ciuo = 1 if ciuo_code == "26" | ciuo_code == "27" | ciuo_code == "28"

	replace g_ciuo = 2 if ciuo_code == "25" | ciuo_code == "29" | ciuo_code == "31"
	replace g_ciuo = 2 if ciuo_code == "32" | ciuo_code == "33" | ciuo_code == "34"
	replace g_ciuo = 2 if ciuo_code == "36" | ciuo_code == "37" | ciuo_code == "38"
	
	replace g_ciuo = 3 if ciuo_code == "41" | ciuo_code == "42" | ciuo_code == "43"
	replace g_ciuo = 3 if ciuo_code == "44" | ciuo_code == "45" | ciuo_code == "46"
	replace g_ciuo = 3 if ciuo_code == "51" | ciuo_code == "73"
	
	replace g_ciuo = 4 if ciuo_code == "52" | ciuo_code == "53" | ciuo_code == "54"
	replace g_ciuo = 4 if ciuo_code == "55" | ciuo_code == "56" | ciuo_code == "57"
	replace g_ciuo = 4 if ciuo_code == "58" | ciuo_code == "61" | ciuo_code == "62"
	replace g_ciuo = 4 if ciuo_code == "63" | ciuo_code == "64" | ciuo_code == "71"
	replace g_ciuo = 4 if ciuo_code == "72" | ciuo_code == "73" | ciuo_code == "74"
	replace g_ciuo = 4 if ciuo_code == "75" | ciuo_code == "76" | ciuo_code == "77"
	replace g_ciuo = 4 if ciuo_code == "78" | ciuo_code == "81" | ciuo_code == "82"
	replace g_ciuo = 4 if ciuo_code == "83" | ciuo_code == "84" | ciuo_code == "85"
	replace g_ciuo = 4 if ciuo_code == "87" | ciuo_code == "88" | ciuo_code == "91"
	replace g_ciuo = 4 if ciuo_code == "92" | ciuo_code == "93" | ciuo_code == "94"
	replace g_ciuo = 4 if ciuo_code == "95" | ciuo_code == "96" | ciuo_code == "97"
	replace g_ciuo = 4 if ciuo_code == "98" 
	*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  	
label define g_ciuo 1 "Cognitive/Non routine" 2 "Manual/Non routine" 3 "Cognitive/routine" 4 "Manual/routine"
label values g_ciuo g_ciuo


