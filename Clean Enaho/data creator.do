clear all
set more off
global ccc_dofiles "/Users/Sebastian/Documents/Papers/Mines SSB/00_Data/Programs/Data Hogares/Clean Raw"
global ccc_out     "/Users/Sebastian/Documents/Papers/Mines SSB/00_Data/Enaho/out"
global ccc_root    "/Users/Sebastian/Documents/Papers/Mines SSB/00_Data"

*Runtime: around 1.2 minutes

timer on 1

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

foreach i in 1 2 3 5{
	qui do "$ccc_dofiles/prepare_`i'00.do"
	di     "prepare module `i'00 qui DONE"
	}
	
qui do "$ccc_dofiles/prepare_sumaria.do"
di     "prepare modulo sumaria DONE"

qui do "$ccc_dofiles/merge data_house.do"
qui do "$ccc_dofiles/merge data_person.do"
di "merge qui DONE"
drop _merge
save "$ccc_out/1997-2017.dta", replace

*Take out the trash (uncomment line in loop)
cd     "$ccc_root"
local trash_files: dir "Trash" files "*.dta"
foreach file of local trash_files{
	erase "Trash/`file'"
	}
timer off 1
timer list
