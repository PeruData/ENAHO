*Individual datasets
**********************

use "Trash/data_200.dta", clear
merge 1:1 year conglome vivienda hogar codperso using "Trash/data_300.dta",   nogen
merge 1:1 year conglome vivienda hogar codperso using "Trash/data_500.dta",   nogen

merge m:1 year conglome vivienda hogar using "Trash/data_house.dta", nogen
sort  year conglome vivienda hogar codperso
order year conglome vivienda hogar, first
save "Trash/data_person.dta", replace

