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

* Creating labels
iecodebook 

* Save cleaned .dta file
save "${onedrive}\data\intermediary\devolve_survey_clean.dta", replace


