/*******************************************************************************
						 Main do-file							   
*******************************************************************************/
* Initial commands
clear
set more off
set mem 800m

* Set reproducibility options
set seed 1234
version 18

* Set project global(s)	
display "`c(username)'"

* Add file paths
if "`c(username)'" == "wb636611" {
    global dropbox "C:\Users\wb631166\OneDrive - WBG\Desktop\Taxes\G2Px"
	global github 	"C:\WBG\GitHub\Devolve-G2PX"
}
if "`c(username)'" == "gabri" {
    global dropbox "C:\Users\gabri\OneDrive\Gabriel\Jobs\DIME\Devolve-G2PX"
	global github 	"C:\Users\gabri\Documents\Github\World Bank\Devolve"
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
if (0) do "${code}\01-cleaning-data.do"
if (0) do "${code}\02-processing-data.do"
if (0) do "${code}\03-analyzing-data.do"
	


* End of do-file!	