* Analyzing Data - This program produces the figures 

*********************** MORE COMPLEX FIGURES THAT I HAVE NOT REPLICATED YET **************
* "Percent of Yes Responses by Variable"
* "Other participants in the program that you know?-Other"
* "Requirements Devolve program"
* "Daily Payment Methods Used for Purchases"
* "Financial Institutions "
* "Financial Institutions-Other"
* "Reason(s) do you not include your CPF number" p. 37
* "Reason(s) do you not include your CPF-Other"  p. 38 NFI04a1_Other
* "Reason(s) do you not include your CPF-Other"  p. 40 NFI04b1_Other
* "Reason(s) do you not include your CPF number" p. 41


******************************************************************************************

* Loads Dataset
use "${dropbox}\data\final\devolve_survey_constructed.dta", clear // 1039 obs

* Figures
    * Loop over selected variables for barplots with label as title and export graph as JPG
    #d ;
	local vars know_devolve 
               participates_devolve 
               program_discovery 
               reason_money_accounts 
               deposit_frequency 
               quarterly_deposit 
               usage_increases 
               unused_funds 
			   purchases_last_week 
			   hh_bank_account 
			   store_receipt 
			   reason_no_receipt 
			   consumption_receipt 
			   type_cpf
			   freq_cpf 
			   cpf_invoice_freq
			   freq_cpf_na 
			    
			   ;
	#d cr 
	
	local vars monthly_purchases_cat //card_devolve

    foreach var of local vars {
        preserve
            * Exceptions by variable
            if "`var'" == "participates_devolve" {
                drop if participates_devolve == 3
            }
            
            * Get label for title
            local title : variable label `var'

            * Extract file name from label (text between parentheses) to save files with the names used on onverleaf
            local fname = ""
            if strpos("`title'", "(") & strpos("`title'", ")") {
                local fname = substr("`title'", strpos("`title'", "(")+1, strpos("`title'", ")")-strpos("`title'", "(")-1)
                * Remove the parentheses and content from the title for display
                local title = subinstr("`title'", "(" + "`fname'" + ")", "", .)
                * Remove any trailing/leading spaces
                local title = strtrim("`title'")
            }
            else {
                local fname = "`var'"
            }
			
			* Getting number of observations
			drop if `var' == . 
            count if !missing(`var') | `var' == .d
            local N : display r(N)
			
            * Define sort option based on variable
            if inlist("`var'", "freq_cpf", "freq_cpf_na", "consumption_receipt", "deposit_frequency", "monthly_purchases_cat") {
                local sortopt = ""
            }
			else {
				local sortopt = "sort(1) descending"
			}

            * Plotting
            graph bar (percent), over(`var', `sortopt') horizontal nofill missing ///
                bar(1, color(navy)) ///
                ytitle("Percentage") ///
                title("`title'", size(medium)) ///
                blabel(bar, format(%9.0f) position(outside)) ///
                note("Note: Number of valid observations = `N'.") ///
                ylabel(, noticks nogrid nolabels) ///
				ysize(6) xsize(10)

            graph export "${github}/Outputs/Figures/F_`fname'.png", replace width(2000)					
        restore
    }
