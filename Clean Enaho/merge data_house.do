global ccc "/Users/Sebastian/Documents/Papers/Mines SSB/00_Data"
cd "$ccc"

*Household datasets
**********************
use "Trash/data_sumaria.dta", clear
merge 1:1 year conglome vivienda hogar using "Trash/data_100.dta", nogen
save "Trash/data_house.dta", replace

