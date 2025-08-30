* This do-file creates a few extra plots for the slides

*********************** MORE COMPLEX FIGURES THAT I HAVE NOT REPLICATED YET **************
* OK "Percent of Yes Responses by Variable" p.12
* "Other participants in the program that you know?-Other" p.13
* "Requirements Devolve program" p.17
* OK "Daily Payment Methods Used for Purchases" p.24
* OK "Financial Institutions " p.27
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

* Load dataset
use "${dropbox}\data\final\devolve_survey_constructed.dta", clear // 1039 obs

* List here the prefixes you want to run
local vars_cat other_beneficiaries payment_method bank_account reason_not_cpf reason_da_not_cpf

//local vars_cat payment_method

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
        graph export "${overleaf_figs}/F_`var_cat'_categories.png", replace width(2150)
    restore
}
