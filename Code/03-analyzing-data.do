* Analyzing Data

*********************** MORE COMPLEX FIGURES THAT I HAVE NOT REPLICATED YET **************
* "Percent of Yes Responses by Variable"
* "Other participants in the program that you know?-Other"
* "Requirements Devolve program"
* "Daily Payment Methods Used for Purchases"
******************************************************************************************

* Loads Dataset
use "${dropbox}\data\final\devolve_survey_constructed.dta", clear // 1039 obs

* Figures
    * Loop over selected variables for barplots with label as title and export graph as JPG
    local vars know_devolve ///
               participates_devolve ///
               program_discovery ///
               reason_money_accounts ///
               deposit_frequency ///
               quarterly_deposit ///
               usage_increases ///
               unused_funds ///
			   purchases_last_week
			   
	local vars hh_bank_account	   

    foreach var of local vars {
        preserve
            * Exceptions by variable
            if "`var'" == "participates_devolve" {
                drop if participates_devolve == 3
            }
            
            * Get label for title
            local title : variable label `var'

            * Extract file name from label (text between parentheses)
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
			
			//* Collapse to frequencies in order to drop categories below 1%
			//contract `var'
			//egen total_sum = total(_freq) if `var' != .
            //gen percent = (_freq / total_sum) * 100
			//drop if percent < 1

			* Plotting
            graph bar (percent), over(`var', sort(1) descending) horizontal nofill missing ///
                bar(1, color(navy)) ///
                ytitle("Percentage") ///
                title("`title'", size(medium)) ///
                blabel(bar, format(%9.0f) position(outside)) ///
                note("Note: Number of valid observations = `N'. Categorie '.d' meaning is 'Don't know'. ") ///
                ylabel(, noticks nogrid nolabels)
			
			graph export "${github}/Outputs/Figures/F_`fname'.png", replace width(2200)					
        restore
    }
