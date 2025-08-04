* Description: This Stata script is used to clean and prepare survey data for analysis.
** It imports data from Excel files, destrings variables, generates summary statistics,
** and merges datasets from different months.

* Authors: Josefina Silva (Original) and Gabriel Caser dos Passos (Updated)

* TODO:

*-------------------------------------------------------------------------------
* Cleaning Data:
*-------------------------------------------------------------------------------

* Import Excel file
import excel "${onedrive}\data\raw\Base Final BM Programa Devolve ICMS RS Coleta.xlsx", ///
	sheet("Consulta1") firstrow clear

* Save raw .dta file
save "${onedrive}\data\raw\devolve_survey_raw.dta", replace

* Change variable types
destring, replace

* Check for duplicates
duplicates report id_entrevista
isid id_entrevista

* Recoding dummy variables
foreach dum_var of varlist gravacao idade1 idade2 telefone consent copiaconsent copiaconsenta DEV01 DEV02 NFI01 CCD06 CCD08 NFG01 NFG02 INU01 INU03 INU04 {
	replace `dum_var' = 0  if `dum_var' == 2
	replace `dum_var' = .d if `dum_var' == 666
	replace `dum_var' = .r if `dum_var' == 999
	replace `dum_var' = .i if `dum_var' == 777
}

* Creating labels and changing types
** droping old labels
label drop _all
foreach var of varlist _all {
	label variable `var' ""
}

** applying labels creates on the excel file using DIME standards
//iecodebook template using "${github}\documentation\variables_codebook.xlsx" // creates template to changes format and labels
iecodebook apply using "${github}\documentation\variables_codebook.xlsx"

* Save cleaned .dta file
save "${onedrive}\data\intermediary\devolve_survey_clean.dta", replace


