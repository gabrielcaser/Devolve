/*******************************************************************************
						 Main do-file							   
*******************************************************************************/
* Initial commands
clear
set more off
set mem 800m

* Set reproducibility options
set seed 1234
version 15

* Set project global(s)	
display "`c(username)'"

* Add file paths

if "`c(username)'" == "gabri" {
    global dropbox       "C:\Users\gabri\Dropbox\Survey_DevolveICMS"
	global github 	     "C:\Users\gabri\Documents\Github\World Bank\Devolve"
	global overleaf_figs "C:\Users\gabri\Dropbox\Apps\Overleaf\Devolve_SEFAZ_RS\RGS-survey data\Figures\Figures_Gabriel"
}

* Set globals for sub-folders 
global code 	"${github}\Code"
global outputs 	"${github}\Outputs"

* Define the path to the packages folder
sysdir set PLUS "${github}\Code\ado" 

* Install packages  
local user_commands	ietoolkit iefieldkit winsor sumstats estout keeporder grc1leg2  asdoc shp2dta spmap asdoc labutil
foreach command of local user_commands {
   capture which `command'
   if _rc == 111 {
	   ssc install `command'
   }
}

* Run do files 
* Switch to 0/1 to not-run/run do-files
if (1) do "${code}\01-cleaning-data.do"
if (1) do "${code}\02-processing-data.do"
if (1) do "${code}\03-analyzing-data.do"
if (0) do "${code}\04-extra-plots.do"



* End of do-file!	