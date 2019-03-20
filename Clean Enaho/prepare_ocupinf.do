*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
*1. Clean data
*-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

use "Enaho/in/Raw Data/ocupinf/ocupinf 2004_2017.dta", clear
drop mes
save "Trash/data_ocupinf.dta", replace
