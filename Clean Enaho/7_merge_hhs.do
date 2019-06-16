use "Trash/data_sumaria.dta", clear
merge 1:1 year conglome vivienda hogar using "Trash/data_100.dta", nogen
merge 1:1 year conglome vivienda hogar using "Trash/data_ethnicity.dta", nogen

save "Trash/data_house.dta", replace

