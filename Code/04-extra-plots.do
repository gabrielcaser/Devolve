* Description - This do-file creates a few extra plots for the slides

* Load dataset
use "${dropbox}\data\final\devolve_survey_constructed.dta", clear // 1039 obs

* List here the prefixes you want to run
local vars_cat other_beneficiaries payment_method bank_account reason_not_cpf reason_da_not_cpf problem_card aid card_collection

foreach var_cat of local vars_cat {

    preserve
        * Keep only id and the variables with the prefix
        keep id_entrevista `var_cat'_*

        * Create total of “Yes” per row within the group (missing counts as 0)
        egen n_missing = rowmiss(`var_cat'_*)
        drop if n_missing > 0
        drop n_missing

        * Number of valid observations for the group
        local n_obs = _N

        * Reshape group to long format
        reshape long `var_cat'_, i(id_entrevista) j(category) string

        * Keep only where the answer is "Yes" (==1)
        keep if `var_cat'_ == 1

        * Clean category name (replace "_" with space and capitalize)
        replace category = proper(subinstr(category, "_", " ", .))

        * Count by category
        contract category

        * Percentage (2 decimal places), over the group denominator
        gen percentage = round(_freq / `n_obs' * 100, 0.01)

        * Plot
        * Creating titles and personalizing
        if "`var_cat'" == "other_beneficiaries" {
            local title = "Who are the other participants in the program that you know?"
        }
        else if "`var_cat'" == "payment_method" {
            local title = "Payment methods do you use to make purchases on a daily basis?"
        }
        else if "`var_cat'" == "bank_account" {
            local title = "Financial Institution you have an account with?"
        }
        else if inlist("`var_cat'", "reason_not_cpf", "reason_da_not_cpf") {
            if "`var_cat'" == "reason_not_cpf" {
                local title = "Reasons for not including your CPF number when asked"
            }
            else if "`var_cat'" == "reason_da_not_cpf" {
                local title = "Reasons for not including your CPF number when not asked"
            }
            replace category = "Don't know the number" if category == "Number"
            replace category = "Not interested in invoices" if category == "Interest"
            replace category = "Data Privacy" if category == "Information"
            replace category = "Don't know the benefits" if category == "Benefits"
        }
        else if "`var_cat'" == "problem_card" {
            local title = "Types of problems with the Devolve card"
            replace category = "Not accepted at the store" if category == "Na"
            replace category = "Transfers are delayed or don't arrive" if category == "Transfer"
            replace category = "Don't know how much money in the card" if category == "Money"
            replace category = "Don't know the PIN" if category == "Password"
            replace category = "Don't know" if category == "Dk"
        }
        else if "`var_cat'" == "aid" {
            local title = "Type of assistance received for flood recovery"
        }
        else if "`var_cat'" == "card_collection" {
            local title = "Reasons for not collecting the Devolve-ICMS Citizen Card"
            replace category = "Didn't know could participate" if category == "P"
            replace category = "Didn't know the program" if category == "Dp"
            replace category = "Location" if category == "L"
            replace category = "Work" if category == "W"
            replace category = "Kids" if category == "K"
            replace category = "Distance" if category == "D"
            replace category = "Money for transport" if category == "T"
        }
        else {
            local title = "`var_cat'"
        }
        graph bar percentage, over(category, sort(1) descending) ///
            horizontal nofill missing ///
            bar(1, color(navy)) ///
            ytitle("Percentage") ///
            title("`title'", size(medium)) ///
            blabel(bar, format(%9.1f) position(outside)) ///
            note("Note: Number of valid observations = `n_obs'.") ///
            ylabel(, noticks nogrid nolabels) ///
            ysize(6) xsize(10)
        
        graph export "${github}/Outputs/Figures/F_`var_cat'_categories.png", replace width(2150)
        if "${save_overleaf}" == "yes" {
            graph export "${overleaf_figs}/F_`var_cat'_categories.png", replace width(2150)
        }
    restore
}

* Density plot
twoway (kdensity monthly_purchases if hh_bank_account == 1, color(blue) lpattern(solid)) ///
       (kdensity monthly_purchases if hh_bank_account == 4, color(red) lpattern(dash)), ///
       legend(order(1 "Has Bank Account" 2 "No Bank Account")) ///
       title("Monthly Purchases Distribution by Bank Account Ownership") ///
       xtitle("Monthly Purchases") ytitle("Density") ///
       note("Smoothed density curves for monthly purchases distribution by bank account ownership")
       graph export "${github}/Outputs/Figures/F_monthly_purchases_density.png", replace width(2150)
       if "${save_overleaf}" == "yes" {
           graph export "${overleaf_figs}/F_monthly_purchases_density.png", replace width(2150)
       }