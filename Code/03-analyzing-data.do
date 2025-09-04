* Analyzing Data - This program most of the figures presented in slides 

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
           cpf_invoice_freq_2
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
           payment_method_cash_2
		   hh_bank_account
           hh_bank_account_2
           hh_bank_account_3
           knows_participant
           bank_account_caixa
           PAG03a_Other_encoded
           INU04a_Other_encoded
           CCD09_Other_encoded
           DEV02a_Other_encoded
           CCD07_Other_encoded
           NFG02Aa_Other_encoded
           NFI04a1_Other_encoded
           NFI04b1_Other_encoded
           program_eligilibility
           icms_rate2_div
           icms_rate_rgs
           municipality_top5_flood_aid
           displaced_rains_days_cat
           ;
#d cr 

* Defining globals to personalize figures

** Vars that will be grouped 
global grouped_income_vars        usage_increases payment_method_cash hh_bank_account bank_account_caixa cpf_invoice_freq
global grouped_age_vars           hh_bank_account_2 reason_no_receipt freq_cpf_na
global grouped_participation_vars payment_method_cash_2
global grouped_gender_vars        hh_bank_account_3
global grouped_cash_vars          cpf_invoice_freq_2
global grouped_vars ${grouped_income_vars} ${grouped_age_vars} ${grouped_participation_vars} ${grouped_gender_vars} ${grouped_cash_vars}

** Vars that will have sample restricted
global restricted_sample_vars reason_money_accounts problem_card tax_collection ///
						   tax_essential_goods icms_rate_rgs increase_tax_on_food ///
						   tax_on_foodreturned tax_food_all tax_perfumes_makeup ///
                           usage_increases purchases_last_week


* Duplicating vars that will produce more than one grouped plot, mantendo os labels originais
gen hh_bank_account_2     = hh_bank_account // for age grouped plot
gen hh_bank_account_3     = hh_bank_account // for gender grouped plot
gen payment_method_cash_2 = payment_method_cash // for participation grouped plot
gen cpf_invoice_freq_2    = cpf_invoice_freq  // for cash grouped plot

label variable hh_bank_account_2 "`:     variable label hh_bank_account'"
label variable hh_bank_account_3 "`:     variable label hh_bank_account'"
label variable payment_method_cash_2 "`: variable label payment_method_cash'"
label variable cpf_invoice_freq_2 "`:    variable label cpf_invoice_freq'"

cap label define lblhh_bank_account     1 "Yes, you have" 2 "Yes, other person have" 3 "Yes, you and other family members have" 4 "No, neither you nor anyone" .d "Don't know"
cap label define lblpayment_method_cash 1 "Yes" 0 "No"
cap label define lblcpf_invoice_freq    1 "Always" 2 "Sometimes" 3 "Rarely" 4 "Never" .d "Don't know"

label values hh_bank_account_2     lblhh_bank_account
label values hh_bank_account_3     lblhh_bank_account
label values payment_method_cash_2 lblpayment_method_cash
label values cpf_invoice_freq_2    lblcpf_invoice_freq

* Loop
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
	if inlist("`var'", "municipality_top5", "municipality_top5_flood_aid") { // string vars
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
					   worry_unauthorized_card icms_rate2_div icms_rate_rgs
                       displaced_rains_days_cat
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
        if strpos("${grouped_income_vars}", "`var'") {
            local group_var income_div
            local group_label "income"
            local extra_note " Don't Know group was omitted."
        }
        else if strpos("${grouped_age_vars}", "`var'") {
            local group_var age_div
            local group_label "age"
            local extra_note ""
        }
        else if strpos("${grouped_participation_vars}", "`var'") {
            local group_var participates_devolve
            local group_label "participation"
            local extra_note ""
        }
        else if strpos("${grouped_gender_vars}", "`var'") {
            local group_var gender
            local group_label "gender"
            local extra_note ""
        }
        else if strpos("${grouped_cash_vars}", "`var'") {
            local group_var payment_method_cash
            local group_label "cash"
            local extra_note ""
        }

        graph bar (percent), over(`var') ///
            by(`group_var', cols(1) title("`title' (by `group_label')", size(medium)) ///
               note("Note: Number of valid observations = `N'.`extra_note'")) ///
            horizontal nofill asyvars ///
            bar(1, color(navy)) ///
            bar(2, color(midblue))  ///
            bar(3, color(ltblue))  ///
            bar(4, color(gs12)) ///
            bar(5, color(gs14)) ///
            ytitle("Percentage")  ///  
            ylabel(none, noticks) /// 
            blabel(bar, format(%9.1f) position(outside)) ///
            ysize(6) xsize(10)

        graph export "${github}/Outputs/Figures/`file_name'_`group_label'.png", replace width(2150)
        if "${save_overleaf}" == "yes" {
            graph export "${overleaf_figs}/`file_name'_`group_label'.png", replace width(2150)
        }
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

        * Counting number of observations for the restricted sample
        count if (!missing(`var') | `var' == .d) & `var_restriction' == `restriction_value'
        local N_partsample : display r(N)

        * Plotting
        graph bar (percent) if `var_restriction' == 1, over(`var', `sortopt') horizontal nofill missing ///
            bar(1, color(navy)) ///
            ytitle("Percentage") ///
            title("`title' `add_title'", size(medium)) ///
            blabel(bar, format(%9.1f) position(outside)) ///
            note("Note: Number of valid observations = `N_partsample'. Sample restricted to `var_restriction' == `restriction_value'.") ///
            ylabel(, noticks nogrid nolabels) ///
            ysize(6) xsize(10)
        graph export "${github}/Outputs/Figures/`file_name'_partsample.png", replace width(2150)
        if "${save_overleaf}" == "yes" {
            graph export "${overleaf_figs}/`file_name'_partsample.png", replace width(2150)
        }
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
    if "${save_overleaf}" == "yes" {
        graph export "${overleaf_figs}/`file_name'.png", replace width(2150)
    }

    restore
}
