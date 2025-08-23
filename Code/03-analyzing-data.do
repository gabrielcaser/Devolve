* Analyzing Data - This program produces the figures 

*********************** MORE COMPLEX FIGURES THAT I HAVE NOT REPLICATED YET **************
* "Percent of Yes Responses by Variable" p.12
* "Other participants in the program that you know?-Other" p.13
* "Requirements Devolve program" p.17
* "Daily Payment Methods Used for Purchases" p.24
* "Financial Institutions " p.27
* "Financial Institutions-Other" p.28
* "Reason(s) do you not include your CPF number" p. 37
* "Reason(s) do you not include your CPF-Other"  p. 38 NFI04a1_Other
* "Reason(s) do you not include your CPF-Other"  p. 40 NFI04b1_Other
* "Reason(s) do you not include your CPF number" p. 41
* "Issues with Using the Devolve-ICMS Citizen Card" p. 51
* "Problems using Citizen Card-Other" p. 52
* "Perceived ICMS Tax Rate on Purchases in Rio Grande do Sul" p. 59 icms_rate2
* "Perceived ICMS Tax Rate on Purchases in Rio Grande do Sul" p. 60 icms_label_with_counts
* "Reasons not participating Nota Fiscal Program-Other" p. 71 other_NFG02Aa
* "Days Unable to Enter Home Due to Floods" p. 78
* "Type of Assistance Received for Flood Recovery" p. 80
* "Kind of assistance after the floods-Other" p. 81
* "Reasons for not collecting the card because of..." p. 90
* "Reasons not collecting the card-Other" p. 91
* "Types of problems in Devolve card among beneficiaries" p. 113


******************************************************************************************

******************************* SOME FIGURES RECEIVED DIFFERENT FILE NAMES ***************
* "Graph_Top_Municipalities_Respondents_live" = F_DEM01

* Loads Dataset
use "${dropbox}\data\final\devolve_survey_constructed.dta", clear // 1039 obs

* Figures
* Loop over selected variables for barplots
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
           monthly_purchases_cat
           card_devolve
           cpf_receipt_freq
           spend_value
           use_citizen_card
           main_use_card
           problem_card
           inequality_brazil
           tax_collection
		   tax_revenue_preference
		   tax_essential_goods
		   cpf_on_invoice_rule
		   increase_tax_on_food
		   tax_on_foodreturned
		   tax_food_all
		   tax_perfumes_makeup
		   nota_fiscal_program
		   participate_nfg
		   reason_nfg
		   flood_impact
		   flood_impact2
		   displaced_rains
		   flood_aid
		   gender
		   age_div
		   municipality_top5
		   income_div
		   household_size
		   get_card
		   stores_nearby
		   card_use_worry
		   worry_unauthorized_card
		   send_information
		   send_information_method
		   usage_increases
		   payment_method_cash
		   hh_bank_account
           knows_participant
           ;
#d cr 


* Defining globals to personalize figures

** Vars that will be grouped 
global grouped_vars usage_increases payment_method_cash hh_bank_account

** Vars that will have sample restricted
global restricted_sample_vars reason_money_accounts problem_card tax_collection ///
						   tax_essential_goods icms_rate_rgs increase_tax_on_food ///
						   tax_on_foodreturned tax_food_all tax_perfumes_makeup ///
                           reason_money_accounts usage_increases purchases_last_week
						   

local vars usage_increases payment_method_cash hh_bank_account

foreach var of local vars {
    preserve
    * Exceptions by variable
    if "`var'" == "participates_devolve" {
        drop if participates_devolve == 3
    }
    
    * Get label for title
    local title : variable label `var'

    * Extract file name from label (text between parentheses) to save files with the names used on onverleaf
    local file_name = ""

    local file_name = substr("`title'", strpos("`title'", "(")+1, strpos("`title'", ")")-strpos("`title'", "(")-1)
    * Remove the parentheses and content from the title for display
    local title = subinstr("`title'", "(" + "`file_name'" + ")", "", .)
    * Remove any trailing/leading spaces
    local title = strtrim("`title'")
	local file_name = "F_" + "`file_name'" 
    
    * Getting number of observations
	if inlist("`var'", "municipality_top5") { // string vars
	 drop if `var' == "."
	 count if !missing(`var') | `var' == ".d"
	}
	else {
	 drop if `var' == . 
	 count if !missing(`var') | `var' == .d
	}

    local N : display r(N)
    
    * Define variables for which sort option is not needed
	#d ;
    global nosort_vars freq_cpf freq_cpf_na consumption_receipt
                       deposit_frequency monthly_purchases_cat use_citizen_card
					   inequality_brazil tax_collection tax_revenue_preference
					   tax_essential_goods cpf_on_invoice_rule increase_tax_on_food
					   tax_on_foodreturned tax_food_all tax_perfumes_makeup
					   household_size stores_nearby card_use_worry
					   worry_unauthorized_card
					   ;
	#d cr
	
    * Define sort option based on variable
    if strpos("${nosort_vars}", "`var'") {
        local sortopt = ""
    }
    else {
        local sortopt = "sort(1) descending"
    }

    * Plotting
	** Grouped plot
    if strpos("${grouped_vars}", "`var'") {
        graph bar (percent), over(`var') ///
            by(income_div, cols(1) title("`title' (by group)", size(medium)) note("Note: Number of valid observations = `N'.")) ///
            horizontal nofill asyvars ///
            bar(2, color(navy)) ///
            bar(1, color(midblue))  ///
            bar(3, color(ltblue))  ///
            bar(4, color(gs12)) ///
            bar(5, color(gs14)) ///
            ytitle("Percentage")  ///   <- era ytitle(); mude para X por ser horizontal
            ylabel(none, noticks) ///  <- oculta todos os rótulos do eixo Y
            blabel(bar, format(%9.1f) position(outside)) ///
            ysize(6) xsize(10)

        graph export "${github}/Outputs/Figures/`file_name'_grouped.png", replace width(2150)
        graph export "${overleaf_figs}/`file_name'_grouped.png", replace width(2150)
    }

    ** Standard plots
    if strpos("${restricted_sample_vars}", "`var'") {
        * Plot for restricted_sample_vars
        if inlist("`var'", "purchases_last_week") {
            local var_restriction hh_bank_account
            local add_title "(no bank)"
            local restriction_value 4
        }
        else if inlist("`var'", "reason_money_accounts","usage_increases") {
            local var_restriction participate_nfg
            local add_title "(nfg=1)"
            local restriction_value 1
        }
        else {
            local var_restriction participates_devolve
            local add_title "(devolve=1)"
            local restriction_value 1
        }
        count if (!missing(`var') | `var' == .d) & `var_restriction' == `restriction_value'
        local N_partsample : display r(N)
        
        graph bar (percent) if `var_restriction' == 1, over(`var', `sortopt') horizontal nofill missing ///
            bar(1, color(navy)) ///
            ytitle("Percentage") ///
            title("`title' `add_title'", size(medium)) ///
            blabel(bar, format(%9.1f) position(outside)) ///
            note("Note: Number of valid observations = `N_partsample'. Sample restricted to `var_restriction' == `restriction_value'.") ///
            ylabel(, noticks nogrid nolabels) ///
            ysize(6) xsize(10)
        graph export "${github}/Outputs/Figures/`file_name'_partsample.png", replace width(2150)
        graph export "${overleaf_figs}/`file_name'_partsample.png", replace width(2150)
    }
    * Plot for full sample
    graph bar (percent), over(`var', `sortopt') horizontal nofill missing ///
        bar(1, color(navy)) ///
        ytitle("Percentage") ///
        title("`title'", size(medium)) ///
        blabel(bar, format(%9.1f) position(outside)) ///
        note("Note: Number of valid observations = `N'.") ///
        ylabel(, noticks nogrid nolabels) ///
        ysize(6) xsize(10)
    graph export "${github}/Outputs/Figures/`file_name'.png", replace width(2150)
    graph export "${overleaf_figs}/`file_name'.png", replace width(2150)

    restore
}
