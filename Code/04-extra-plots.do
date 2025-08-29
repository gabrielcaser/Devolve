* This do-file creates extra plots for the analysis

* Load dataset
use "${dropbox}\data\final\devolve_survey_constructed.dta", clear // 1039 obs

* List here the prefixes you want to run
local vars_cat other_beneficiaries payment_method



foreach var_cat of local vars_cat {

    preserve
        * Keep only id and the variables with the prefix
        keep id_entrevista `var_cat'_*

        * (Optional/defensive) If any of these variables are string "1"/"0", uncomment below:
        * ds `cat'_*, has(type string)
        * local strvars `r(varlist)'
        * if "`strvars'" != "" destring `strvars', replace ignore(" ")

        * Create total of “Yes” per row within the group (missing counts as 0)
        egen n_valid_answers = rowtotal(`var_cat'_*)
        drop if n_valid_answers == 0
        drop n_valid_answers

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
        * Creating titles
        if "`var_cat'" == "other_beneficiaries" {
            local title = "Who are the other participants in the program that you know?"
        }
        else if "`var_cat'" == "payment_method" {
            local title = "Payment methods do you use to make purchases on a daily basis?"
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
