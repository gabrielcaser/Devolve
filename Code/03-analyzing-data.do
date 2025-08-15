* Analyzing Data

* Loads Dataset
use "${dropbox}\data\final\devolve_survey_constructed.dta", clear 

* Figures
    * Loop over selected variables for barplots with label as title and export graph as JPG
    local vars know_devolve participates_devolve reason_money_accounts program_discovery

    foreach var of local vars {
        preserve
            gen total = 1
            collapse (count) total, by(`var')
            egen total_sum = total(total) if !missing(`var')
            gen percent = (total / total_sum) * 100
            gen percent_round = round(percent)
            sum total if !missing(`var'), meanonly
            local N : display %15.0fc r(sum)

            * Get label for title
            local title : variable label `var'

            * For program_discovery, drop small percentages and sort by percent
            if "`var'" == "program_discovery" {
                gen rank = -percent
                gsort rank
                drop if percent_round < 10
            }

            * Extract file name from label (text between parentheses)
            local fname = ""
            if strpos("`title'", "(") & strpos("`title'", ")") {
                local fname = substr("`title'", strpos("`title'", "(")+1, strpos("`title'", ")")-strpos("`title'", "(")-1)
            }
            else {
                local fname = "`var'"
            }

            graph hbar percent_round, over(`var', sort(percent_round) descending) ///
                bar(1, color(navy)) ///
                bar(2, color(blue)) ///
                blabel(bar, format(%10.0gc) position(outside)) ///
                ytitle("Percentage") ///
                title("`title'") ///
                note("N=`N'") ///
                ysize(6) xsize(10)

            graph export "${github}/Outputs/Figures/F_`fname'.png", replace
        restore
    }
	

*-------------------------------------------------------------------------------	
* Summary Stats Table 
*------------------------------------------------------------------------------- 
 	
	* Step 1: Post the summary stats for your selected variables
	
     estpost summarize  age  income 

    * Step 2: Export to LaTeX
	
    esttab using summary_stats.tex, ///
    cells("Count mean(fmt(0)) Mean(fmt(2)) Sd(fmt(2)) Min(fmt(2)) Max(fmt(2))") ///
    label replace ///
    title("Summary Statistics") ///
    booktabs
	
	 * Step 2: Export to Word
	
    esttab using summary_stats.rtf, ///
    cells("count mean(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") ///
    label replace ///
    title("Summary Statistics")
	
	* Percent distribution of gender
	
	asdoc tab gender, replace
	
	
    * Percent distribution of municipality
	
    asdoc tab municipality, replace append

*-------------------------------------------------------------------------------	
* Graphs
*------------------------------------------------------------------------------- 
 
 *Top 5 municipalities where respondents live 
 
    preserve
 
   * Summarize data by municipality
   
   contract municipality, freq(count)

   * Sort by frequency in descending order
   
    gsort -count municipality

   * Create a variable for top 5 and "Other"
   
    gen municipality_group = municipality
	
    replace municipality_group = "Other" if _n > 5
	
	* Collapse data for the grouped municipalities
	
    collapse (sum) count, by(municipality_group)

    * Sort by frequency for plotting
	
     gsort -count

     sort count
     gen order = _n
	 
	 
	  * Store total N in a local macro
	  
	  sum count if !missing(municipality_group), meanonly
      local N : display %15.0fc r(sum)
	 
   * Generate a horizontal barplot with labels
   
   graph hbar (sum) count, over(municipality, sort(order) descending) ///
    bar(1, color(navy)) ///
    blabel(bar, format(%10.0gc) position(outside)) ///
    ytitle("Number of Respondents") ///
    title("Top 5 Municipalities where Respondents live") ///
     note("N = `N'")  //
   
   
   restore
   
	*Geographical distribution of the respondents
	
	preserve
	
	* Convert shapefile to Stata format

	* Load and inspect the shapefile
	
 shp2dta using "C:\Users\wb631166\OneDrive - WBG\Desktop\Taxes\G2Px\Shapefile\RGDS.shp",database("meso_data") coordinates("meso_coord") genid(id) replace
use meso_data, clear
	
	
     * Load the shapefile data into memory
	 
     use "rgds_data_sub", clear
	 
	 keep if NM_UF=="Rio Grande do Sul"
	 
	 rename NM_MUN municipality
	 
	 replace municipality="Sant'ana do Livramento" if municipality=="Sant'Ana do Livramento"

    * Merge with your respondent data
	
     merge 1:1 municipality using "municipalities.dta"
	 
	 drop if _merge==2
	
	 drop _merge
	
	*Replace variable count
	
	replace count=0 if count==.

   *Create a color palette with specific colors for missing and   non-missing values
   
  spmap count using "rgds_coord.dta", id(id) /// 
    fcolor(Blues) /// 
    clmethod(custom) /// 
    clbreaks(0 1 2 5 6 7 8 9 10 200) ///  // Change this to your desired range and interval
    title("Geographical Distribution of Respondents") /// 
    legend(size(small))
     
	restore 
	
	
	*Age
	
	preserve
	
	*Generate age division variable 
	
	gen age_div=0
	
	replace age_div=1 if age>=45
	
	replace age_div=. if age==.
	
	label var age_div "Age Division"
	
	la de lblage_div 0 "Less than 45 years" 1 "More than 45 years" 
	
	label values age_div lblage_div

    * Generate a count of observations per age  
	
    gen total = 1
	
    collapse (count) total, by(age_div)

    * Calculate total sum  
	
    egen total_sum = sum(total)

    * Compute percentages 
	
    gen percent = (total / total_sum) * 100  
	
    gen percent_round = round(percent)
	
	
	* Store total N in a local macro
	  
	  sum total if !missing(age_div), meanonly
      local N : display %15.0fc r(sum)

    * Generate a bar plot  
	
    graph hbar percent_round, over(age_div, sort(percent_round) descending) ///
    bar(1, color(navy)) ///
    blabel(bar, format(%10.0gc) position(outside)) ///
    ytitle("Percentage") ///
    title("Age of Respondents") ///
    note("N =`N'")  //
	
	
    restore
	
	*Gender
	
	preserve

    * Generate a count of observations per age  
	
    gen total = 1
	
    collapse (count) total, by(gender)

    * Calculate total sum  
	
    egen total_sum = sum(total)

    * Compute percentages 
	
    gen percent = (total / total_sum) * 100  
	
    gen percent_round = round(percent)
	
	
	* Store total N in a local macro
	  
	  sum total if !missing(gender), meanonly
      local N : display %15.0fc r(sum)

    * Generate a bar plot  
	
      graph hbar (mean) percent_round, over(gender, sort(percent_round) descending) ///
    bar(1, color(navy)) ///
    blabel(bar, format(%10.0gc) position(outside)) ///
    ytitle("Percentage") ///
    title("Gender of Respondents") ///
    note("N =`N'")  //
	
	restore
	
	
   
	
	

	*Does anyone you know participate in the program?
	
	preserve

     gen total = 1
	 
     collapse (sum) total, by(knows_participant)

     egen total_sum = total(total) if !missing(knows_participant)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(knows_participant), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
	 

   * Graph

    graph hbar percent_round, over(knows_participant, sort(percent_round) descending) ///
    bar(1, color(navy)) ///
    bar(2, color(blue)) ///
    blabel(bar, format(%10.0gc) position(outside)) ///
    ytitle("Percentage") ///
    title("Percentage of People Who Know Someone Participating in the Program") ///
    note("N=`N'") ///
    ysize(6) xsize(10)

    restore
	
	*Do you or other family members who live with you have an account at a bank or financial institution?
	
	preserve

     gen total = 1
	 
     collapse (sum) total, by(hh_bank_account)

     egen total_sum = total(total) if !missing(hh_bank_account)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(hh_bank_account), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
	 
	 
	 

   * Graph

    graph hbar percent_round, over(hh_bank_account, sort(percent_round) descending) ///
    bar(1, color(navy)) ///
    bar(2, color(blue)) ///
    blabel(bar, format(%10.0gc) position(outside)) ///
    ytitle("Percentage") ///
    title("Household Bank Account Ownership") ///
    note("N=`N'") ///
    ysize(6) xsize(10)

    restore
	
   *How often do you include your CPF on your purchase receipts today?
	
	preserve

     gen total = 1
	 
     collapse (sum) total, by(cpf_receipt_freq)

     egen total_sum = total(total) if !missing(cpf_receipt_freq)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(cpf_receipt_freq), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
	 

   * Graph

    graph hbar percent_round, over(cpf_receipt_freq, sort(percent_round) descending) ///
    bar(1, color(navy)) ///
    bar(2, color(blue)) ///
    blabel(bar, format(%10.0gc) position(outside)) ///
    ytitle("Percentage") ///
    title("CPF Inclusion Frequency on Receipts") ///
    note("N=`N'") ///
    ysize(6) xsize(10)

    restore
	
		
	*Who are the other participants in the program that you know?
	
	 preserve 
	
	gen friends_yes = other_beneficiaries_friends == 1
    gen leaders_yes = other_beneficiaries_leaders == 1
    gen family_yes = other_beneficiaries_family == 1
	gen other_yes = other_beneficiaries_other == 1
	
	egen total_obs = count(other_beneficiaries_friends)

  
    egen friends_yes_total = total(friends_yes)
    egen leaders_yes_total = total(leaders_yes)
    egen family_yes_total = total(family_yes)
	egen other_yes_total = total(other_yes)

    gen friends_pct = (friends_yes_total / total_obs) * 100
    gen leaders_pct = (leaders_yes_total / total_obs) * 100
    gen family_pct = (family_yes_total / total_obs) * 100
    gen other_pct = (other_yes_total / total_obs) * 100

    gen variable = "Friends" in 1
    replace friends_pct = leaders_pct in 2
    replace variable = "Leaders" in 2
    replace friends_pct = family_pct in 3
    replace variable = "Family" in 3
	replace friends_pct = other_pct in 4
    replace variable = "Other" in 4
    keep if _n <= 4
    rename friends_pct percent
	
	
	gen percent_round = round(percent)
	
	 * Store total N in a local macro directly from total_obs
     local N = total_obs[1]
	 
	 drop if percent_round<1

   *Graph the percentages
   
    graph hbar percent_round, over(variable, sort(percent_round) descending) ///
    bar(1, color(navy)) ///
    blabel(bar, format(%10.0gc) position(outside)) ///
    ytitle("Percentage") ///
    title("Percent of Yes Responses by Variable") ///
    note("N=`N'") ///
    ysize(6) xsize(10) /// Adjust size as needed
   
	
	
    restore

	
		
	*According to your knowledge, choose the answer that shows everything a family living in Rio Grande do Sul needs to  participate in the Devolve-ICMS program:
	
	 preserve
	 
	 gen program_eligilibility_cat=0
	 
	 replace program_eligilibility_cat=1 if program_eligilibility==4
	 
	 replace program_eligilibility_cat=2 if program_eligilibility==555
	 
	 replace program_eligilibility_cat=3 if program_eligilibility==666
	 
	 replace program_eligilibility_cat=. if program_eligilibility==.
	 
	 label var program_eligilibility_cat "Requirements Devolve program"
	
	la de lblprogram_eligilibility_cat 0 "One correct answer" 1 "All alternatives" 2 "Other answer" 3 "Don't know" 
	
	label values program_eligilibility_cat lblprogram_eligilibility_cat
	 
	  gen total = 1
	 
     collapse (sum) total, by(program_eligilibility_cat)

     egen total_sum = total(total) if !missing(program_eligilibility_cat)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	 * Store total N in a local macro
	  
	 sum total if !missing(program_eligilibility_cat), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
	 

     gen rank = -percent  // Create a ranking variable (negative to sort descending)
	
     gsort rank  // Sort by rank (descending order of percentage)
	
     gen keep_top4 = _n <= 4  // Flag the top 4 categories

     keep if keep_top4
	 

   *Graph 

   
    graph hbar percent_round, over(program_eligilibility_cat, sort(percent_round) descending) ///
    bar(1, color(navy)) ///
    bar(2, color(blue)) ///
    blabel(bar, format(%10.0gc) position(outside)) ///
    ytitle("Percentage") ///
    title("Requirements Devolve program") ///
    note("N=`N'") ///
    ysize(6) xsize(10)
	
	
	restore
	
	
	*The Devolve-ICMS program deposits money into the Devolve ICMS Citizen Card of families participating in the program. Do you know how many times this deposit is made?
	
	 preserve
	
	 gen total = 1
	 
     collapse (sum) total, by(deposit_frequency)

     egen total_sum = total(total) if !missing(deposit_frequency)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	 
	 gen order=deposit_frequency
	 
	 gsort order
	 
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(deposit_frequency), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1


   * Graph

    graph hbar percent_round, over(deposit_frequency, sort(order)) ///
    bar(1, color(navy)) ///
    bar(2, color(blue)) ///
    blabel(bar, format(%10.0gc) position(outside)) ///
    ytitle("Percentage") ///
    title("Frequency payments of the program") ///
    note("N=`N'") ///
    ysize(6) xsize(10)
	
	
	restore
	
	
	
	*Every three months, at least 100 reais are deposited on the Citizen ICMS Return Card.
	
	 preserve
	 
	 
	 gen total = 1
	 
     collapse (sum) total, by(quarterly_deposit)

     egen total_sum = total(total) if !missing(quarterly_deposit)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	 * Store total N in a local macro
	  
	 sum total if !missing(quarterly_deposit), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
	 
	

   * Graph

    graph hbar percent_round, over(quarterly_deposit, sort(percent_round) descending) ///
    bar(1, color(navy)) ///
    blabel(bar, format(%10.0gc) position(outside)) ///
    ytitle("Percentage") ///
    title("Quarterly Deposits of 100+ Reais on Citizen ICMS Card") ///
    note("N=`N'") ///
    ysize(6) xsize(10)

	
	restore
	
	
	*The more a family includes the CPF registered in the program on their purchase invoices, the more money they will be able to receive from the Devolve ICMS Program
	
	 preserve
	 
	  gen total = 1
	 
     collapse (sum) total, by(usage_increases)

     egen total_sum = total(total) if !missing(usage_increases)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(usage_increases), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1

	
	*Graph 
	
	graph hbar percent_round, over(usage_increases, sort(percent_round) descending) ///
    bar(1, color(navy)) ///
    blabel(bar, format(%10.0gc) position(outside)) ///
    ytitle("Percentage") ///
    title("Increased Earnings from Devolve ICMS Program with CPF-RI") ///
    note("N=`N'") ///
    ysize(6) xsize(10)
	
	
	restore
	
	*Devolve-ICMS provides a debit card called Cartão Cidadão through which people receive reimbursement. What happens if the money on the Devolve-ICMS card is not used in full within a month?
	
	 preserve
	 
	 
	  gen total = 1
	 
     collapse (sum) total, by(unused_funds)

     egen total_sum = total(total) if !missing(unused_funds)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(unused_funds), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
	

	*Graph 
	
	graph hbar percent_round, over(unused_funds, sort(percent_round) descending) ///
    bar(1, color(navy)) ///
    blabel(bar, format(%10.0gc) position(outside)) ///
    ytitle("Percentage") ///
    title("Handling Unused Funds") ///
    note("N=`N'") ///
    ysize(6) xsize(10)  // Adjust size as needed
	
	restore
	
	
	
	
	*Payments methods
	
	 preserve

	 
	gen cash_yes = payment_method_cash == 1
    gen debit_yes = payment_method_debit == 1
    gen credit_yes = payment_method_credit == 1
	gen pix_yes = payment_method_pix == 1
	gen mobile_yes = payment_method_mobile == 1
	
	egen total_obs_cash = count(payment_method_cash)
	egen total_obs_debit = count(payment_method_debit)
	egen total_obs_credit = count(payment_method_credit)
	egen total_obs_pix = count(payment_method_pix)
	egen total_obs_mobile = count(payment_method_mobile)

  
    egen cash_yes_total = total(cash_yes)
    egen debit_yes_total = total(debit_yes)
    egen credit_yes_total = total(credit_yes)
	egen pix_yes_total = total(pix_yes)
	egen mobile_yes_total = total(mobile_yes)

    gen cash_pct = (cash_yes_total / total_obs_cash) * 100
    gen debit_pct = (debit_yes_total / total_obs_debit) * 100
	gen credit_pct = (credit_yes_total / total_obs_credit) * 100
    gen pix_pct = (pix_yes_total / total_obs_pix) * 100
	gen mobile_pct = (mobile_yes_total / total_obs_mobile) * 100


    gen variable = "Cash" in 1
    replace cash_pct = debit_pct in 2
    replace variable = "Debit" in 2
    replace cash_pct = credit_pct in 3
    replace variable = "Credit" in 3
	replace cash_pct = pix_pct in 4
    replace variable = "Pix" in 4
	replace cash_pct = mobile_pct in 5
    replace variable = "Mobile" in 5
	
    keep if _n <= 5
    rename cash_pct percent
	
	 * Store total N in a local macro directly from total_obs
     local N = total_obs_cash[1]
	
	
	gen percent_round = round(percent)
	
	 drop if percent_round<1
	 
	
	*Graph 
	
	graph hbar percent_round, over(variable, sort(percent_round) descending) ///
    bar(1, color(navy)) ///
    bar(2, color(blue)) ///
    blabel(bar, format(%10.0gc) position(outside)) ///
    ytitle("Percentage") ///
    title("Daily Payment Methods Used for Purchases") ///
    note("N=`N'") ///
    ysize(6) xsize(10)

	
	restore
	
	*Purchases you made last week
	
	 preserve
	 
    gen total = 1
    collapse (sum) total, by(purchases_last_week)

    * Compute total sum to calculate percentages
    egen total_sum = total(total) if !missing(purchases_last_week)
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Adjust rounding errors to ensure sum = 100%
    egen sum_round = total(percent_round)
    
    * Find the category with the largest percentage
    egen max_percent = max(percent_round)
    
    * Adjust only the category with the largest percent to make total = 100%
    replace percent_round = percent_round + (100 - sum_round) if percent_round == max_percent & sum_round != 100

    * Store total N in a local macro
    sum total if !missing(purchases_last_week), meanonly
    local N : display %15.0fc r(sum)
	 
    drop if percent_round < 1
	
    * Convert purchases_last_week values to string labels
    gen purchases_label = string(purchases_last_week)
   
    * Assign a numeric order to categories
    gen order = .
    replace order = 1 if purchases_label == "All or almost all"
    replace order = 2 if purchases_label == "More than half"
    replace order = 3 if purchases_label == "Half"
    replace order = 4 if purchases_label == "Less than half"
    replace order = 5 if purchases_label == "None or almost none"
    replace order = 6 if purchases_label == "Don't know"

    * Ensure the order is correctly applied
    gsort order
	
    * Graph 
    graph hbar percent_round, over(purchases_last_week, sort(order)) ///
        bar(1, color(navy)) ///
        bar(2, color(blue)) ///
        blabel(bar, format(%10.0gc) position(outside)) ///
        ytitle("Percentage") ///
        title("Cash Payments for Purchases Made Last Week") ///
        note("N=`N'") ///
        ysize(6) xsize(10)

restore

	
	*Financial institutions
	
	preserve

    * Create yes/no variables for bank account usage
	
    gen brasil_yes = bank_account_brasil == 1
    gen bradesco_yes = bank_account_bradesco == 1
    gen itau_yes = bank_account_itau == 1
    gen santander_yes = bank_account_santander == 1
    gen nubank_yes = bank_account_nubank == 1
    gen inter_yes = bank_account_inter == 1
    gen c6_yes = bank_account_c6 == 1
    gen banrisul_yes = bank_account_banrisul == 1
    gen pagbank_yes = bank_account_pagbank == 1
    gen picpay_yes = bank_account_picpay == 1
    gen agibank_yes = bank_account_agibank == 1
    gen sicredi_yes = bank_account_sicredi == 1
    gen caixa_yes = bank_account_caixa == 1
	gen other_yes = bank_account_other == 1

   * Calculate total observations and totals for yes responses
   
   egen brasil_yes_total = total(brasil_yes)
   egen bradesco_yes_total = total(bradesco_yes)
   egen itau_yes_total = total(itau_yes)
   egen santander_yes_total = total(santander_yes)
   egen nubank_yes_total = total(nubank_yes)
   egen inter_yes_total = total(inter_yes)
   egen c6_yes_total = total(c6_yes)
   egen banrisul_yes_total = total(banrisul_yes)
   egen pagbank_yes_total = total(pagbank_yes)
   egen picpay_yes_total = total(picpay_yes)
   egen agibank_yes_total = total(agibank_yes)
   egen sicredi_yes_total = total(sicredi_yes)
   egen caixa_yes_total = total(caixa_yes)
   egen other_yes_total = total(other_yes)

   * Calculate percentages
   
    egen total_obs = count(bank_account_brasil) // Total observations for all banks
    gen brasil_pct = (brasil_yes_total / total_obs) * 100
    gen bradesco_pct = (bradesco_yes_total / total_obs) * 100
    gen itau_pct = (itau_yes_total / total_obs) * 100
    gen santander_pct = (santander_yes_total / total_obs) * 100
    gen nubank_pct = (nubank_yes_total / total_obs) * 100
    gen inter_pct = (inter_yes_total / total_obs) * 100
    gen c6_pct = (c6_yes_total / total_obs) * 100
    gen banrisul_pct = (banrisul_yes_total / total_obs) * 100
    gen pagbank_pct = (pagbank_yes_total / total_obs) * 100
    gen picpay_pct = (picpay_yes_total / total_obs) * 100
    gen agibank_pct = (agibank_yes_total / total_obs) * 100
    gen sicredi_pct = (sicredi_yes_total / total_obs) * 100
    gen caixa_pct = (caixa_yes_total / total_obs) * 100
	gen other_pct = (other_yes_total / total_obs) * 100

    gen variable = "Do-Brasil" in 1
    replace brasil_pct = bradesco_pct in 2
    replace variable = "Bradesco" in 2
    replace brasil_pct = itau_pct in 3
    replace variable = "Itau" in 3
	replace brasil_pct = santander_pct in 4
    replace variable = "Santander" in 4
	replace brasil_pct = nubank_pct in 5
    replace variable = "Nubank" in 5
    replace brasil_pct = inter_pct in 6
    replace variable = "Inter" in 6
	replace brasil_pct = c6_pct in 7
    replace variable = "C6" in 7
	replace brasil_pct = banrisul_pct in 8
    replace variable = "Banrisul" in 8
	replace brasil_pct = pagbank_pct in 9
    replace variable = "Pagbank" in 9
	replace brasil_pct = picpay_pct in 10
    replace variable = "PicPay" in 10
	replace brasil_pct = agibank_pct in 11
    replace variable = "Agibank" in 11
	replace brasil_pct = sicredi_pct in 12
    replace variable = "Sicredi" in 12
	replace brasil_pct = caixa_pct in 13
    replace variable = "Caixa" in 13
    replace brasil_pct = other_pct in 14
    replace variable = "Other" in 14
	
	
     keep if _n <= 14
    rename brasil_pct percent
	
	 * Store total N in a local macro directly from total_obs
     local N = total_obs[1]
	
	
	
	gen percent_round = round(percent)

    * Graph 
     graph hbar percent_round, over(variable, sort(percent_round) descending) ///
    bar(1, color(navy)) ///
    bar(2, color(blue)) ///
    blabel(bar, format(%10.0gc) position(outside)) ///
    ytitle("Percentage") ///
    title("Financial Institutions ") ///
    note("N=`N'") ///
    ysize(6) xsize(10)

restore



	
	*Does the store where you shop most often give you a receipt?
	
	 preserve 
	 
	 
	 gen total = 1
	 
     collapse (sum) total, by(store_receipt)

     egen total_sum = total(total) if !missing(store_receipt)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(store_receipt), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
	
	
	*Graph 
	
	graph hbar percent_round, over(store_receipt, sort(percent_round) descending) ///
    bar(1, color(navy)) ///
    bar(2, color(blue)) ///
    blabel(bar, format(%10.0gc) position(outside)) ///
    ytitle("Percentage") ///
    title("Receipt Practices: Does Your Most Frequent Store Provide One?") ///
    note("N=`N'") ///
    ysize(6) xsize(10)

	
	
	restore
	
	*Please indicate the main reason why you choose to shop there instead of going to stores that issue receipts?
	
	 preserve

     gen total = 1
	 
     collapse (sum) total, by(reason_no_receipt)

     egen total_sum = total(total) if !missing(reason_no_receipt)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(reason_no_receipt), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
	 
	
	
	*Graph 
	
	graph hbar percent_round, over(reason_no_receipt, sort(percent_round) descending) ///
    bar(1, color(navy)) ///
    bar(2, color(blue)) ///
    blabel(bar, format(%10.0gc) position(outside)) ///
    ytitle("Percentage") ///
    title("Main Reasons for Choosing Stores That Don't Issue Receipts") ///
    note("N=`N'") ///
    ysize(6) xsize(10)


	restore
	
	
	*How much of your consumption comes from stores where the attendant asks if you want to include your CPF on the purchase receipt?
	
	 preserve
	
	 gen total = 1
	 
     collapse (sum) total, by(consumption_receipt)

     egen total_sum = total(total) if !missing(consumption_receipt)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	 * Store total N in a local macro
	  
	 sum total if !missing(consumption_receipt), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
	 
	  gen consumption_label = string(consumption_receipt)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if consumption_label == "All or almost everything"
    replace order = 2 if consumption_label == "More than half"
    replace order = 3 if consumption_label == "Half"
    replace order = 4 if consumption_label == "Less than half"
	replace order = 5 if consumption_label == "None or almost nothing"
    replace order = 6 if consumption_label == "Don't know"

   * Ensure the order is correctly applied
    gsort order
	
	
	 

   * Create the graph
   
    graph hbar percent_round, over(consumption_receipt, sort(order)) /// 
    bar(1, color(navy)) /// 
    bar(2, color(blue)) /// 
    blabel(bar, format(%10.0gc) position(outside)) /// 
    ytitle("Percentage") /// 
    title("Consumption in Stores Asking for CPF on Receipts") /// 
    note("N=`N'") ///
    ysize(6) xsize(10)

	restore
	
   *CPF Usage on Purchase Invoices: Whose CPF Do You Typically Use?
	
	 preserve
	
	  gen total = 1
	 
     collapse (sum) total, by(type_cpf)

     egen total_sum = total(total) if !missing(type_cpf)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	 * Store total N in a local macro
	  
	 sum total if !missing(type_cpf), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
	 

	
	*Graph 
	
	graph hbar percent_round, over(type_cpf, sort(percent_round) descending) ///
    bar(1, color(navy)) ///
    blabel(bar, format(%10.0gc) position(outside)) ///
    ytitle("Number of Respondents") ///
    title("Most Common CPF Used on Purchase Invoices") ///
    note("N=`N'") ///
    ysize(6) xsize(10)  // Adjust size as needed
	
	restore
	
	
	*How often do you include someone else's CPF on the invoice?
	 
	 preserve 
	
     gen total = 1
	 
     collapse (sum) total, by(freq_cpf)

     egen total_sum = total(total) if !missing(freq_cpf)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	 * Store total N in a local macro
	  
	 sum total if !missing(freq_cpf), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   
      gen cpf_label = string(freq_cpf)
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if cpf_label == "Always"
    replace order = 2 if cpf_label == "Sometimes"
    replace order = 3 if cpf_label == "Rarely"
    replace order = 4 if cpf_label == "Never"
    replace order = 5 if cpf_label == "Don't know"

   * Ensure the order is correctly applied
    gsort order
	
   * Create the bar graph
   
    graph hbar percent_round, over(freq_cpf, sort(order)) ///
    bar(1, color(navy)) bar(2, color(blue)) ///
    title("Percent of Including Someone Else's CPF on Purchase Invoices") ///
    ytitle("Percent") ///
    blabel(bar) ///
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed


	restore
	
	*When the attendant asks you if you want to include your CPF on the purchase invoice, how often do you usually include your CPF on the invoice?
	 
	 preserve
	

     gen total = 1
	 
     collapse (sum) total, by(cpf_invoice_freq)

     egen total_sum = total(total) if !missing(cpf_invoice_freq)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	 * Store total N in a local macro
	  
	 sum total if !missing(cpf_invoice_freq), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
	 
	   gen cpf_label = string(cpf_invoice_freq)
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if cpf_label == "Always"
    replace order = 2 if cpf_label == "Sometimes"
    replace order = 3 if cpf_label == "Rarely"
    replace order = 4 if cpf_label == "Never"


   * Ensure the order is correctly applied
    gsort order
   

   * Create the bar graph
   
    graph hbar percent_round, over(cpf_invoice_freq, sort(order)) ///
    bar(1, color(navy)) bar(2, color(blue)) ///
    title("Frequency CPF on the invoice") ///
    ytitle("Percent") ///
    blabel(bar) ///
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed


	restore
	
	*For what reason(s) do you not include your CPF number on the invoice?
	 
	 preserve
	
     * Create yes/no variables for bank account usage
	 
     gen time_yes = reason_not_cpf_time == 1
     gen number_yes = reason_not_cpf_number == 1
     gen interest_yes = reason_not_cpf_interest == 1
     gen benefits_yes = reason_not_cpf_benefits == 1
     gen information_yes = reason_not_cpf_inofrmation == 1
	 gen other_yes = reason_not_cpf_other == 1


    * Calculate total observations and totals for yes responses

    egen time_yes_total = total(time_yes)
    egen number_yes_total = total(number_yes)
    egen interest_yes_total = total(interest_yes)
    egen benefits_yes_total = total(benefits_yes)
    egen information_yes_total = total(information_yes)
	egen other_yes_total = total(other_yes)


    * Calculate percentages

    egen total_obs = count(reason_not_cpf_time) // Total observations for all banks
    gen time_pct = (time_yes_total / total_obs) * 100
    gen number_pct = (number_yes_total / total_obs) * 100
    gen benefits_pct = (benefits_yes_total / total_obs) * 100
    gen information_pct = (information_yes_total / total_obs) * 100
    gen interest_pct = (interest_yes_total / total_obs) * 100
	gen other_pct = (other_yes_total / total_obs) * 100


    gen variable = "Time" in 1
    replace time_pct = number_pct in 2
    replace variable = "Don't know the number" in 2
    replace time_pct = benefits_pct in 3
    replace variable = "Don't know the benefits" in 3
	replace time_pct = information_pct in 4
    replace variable = "Data Privacy" in 4
	replace time_pct = interest_pct in 5
    replace variable = "Not interested in invoices" in 5
	replace time_pct = other_pct in 5
    replace variable = "Other" in 6
	
	 * Store total N in a local macro directly from total_obs
     local N = total_obs[1]
	
     keep if _n <= 6
    rename time_pct percent
	
	
	gen percent_round = round(percent)
   

   * Create the bar graph
   
    graph hbar percent_round, over(variable, sort(percent_round) descending) ///
    bar(1, color(navy)) bar(2, color(blue)) ///
    title("Reason(s) do you not include your CPF number") ///
    ytitle("Percent") ///
    blabel(bar) ///
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed


	restore
	
	*And when the attendant DOES NOT ask you if you want to include your CPF on the purchase invoice, how often do you ask to include your CPF on the invoice?
	 
	 preserve
	

     gen total = 1
	 
     collapse (sum) total, by(freq_cpf_na)

     egen total_sum = total(total) if !missing(freq_cpf_na)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	 drop if percent_round<1
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(freq_cpf_na), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
	 
	  gen cpf_label = string(freq_cpf_na)
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if cpf_label == "Always"
    replace order = 2 if cpf_label == "Sometimes"
    replace order = 3 if cpf_label == "Rarely"
    replace order = 4 if cpf_label == "Never"
    replace order = 5 if cpf_label == "Don't know"

   * Ensure the order is correctly applied
    gsort order
   
   

   * Create the bar graph
   
    graph hbar percent_round, over(freq_cpf_na, sort(order)) ///
    bar(1, color(navy)) bar(2, color(blue)) ///
    title("Requesting CPF When Not Asked") ///
    ytitle("Percent") ///
    blabel(bar) ///
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed


	restore
  
  
  
  *For what reason(s) do you not include your CPF number on the invoice?NFI04b1_1
	 
	 preserve
	
     * Create yes/no variables for bank account usage
	 
      gen time_yes = reason_not_cpf_time_da == 1
      gen number_yes = reason_not_cpf_number_da == 1
      gen interest_yes = reason_not_cpf_interest_dat == 1
      gen benefits_yes = reason_not_cpf_benefits_da == 1
      gen information_yes = reason_not_cpf_inofrmation_da == 1


   * Calculate total observations and totals for yes responses

     egen time_yes_total = total(time_yes)
     egen number_yes_total = total(number_yes)
     egen interest_yes_total = total(interest_yes)
     egen benefits_yes_total = total(benefits_yes)
     egen information_yes_total = total(information_yes)


   * Calculate percentages

    egen total_obs = count(reason_not_cpf_time_da) // Total observations for all banks
    gen time_pct = (time_yes_total / total_obs) * 100
    gen number_pct = (number_yes_total / total_obs) * 100
    gen benefits_pct = (benefits_yes_total / total_obs) * 100
    gen information_pct = (information_yes_total / total_obs) * 100
    gen interest_pct = (interest_yes_total / total_obs) * 100


    gen variable = "Time" in 1
    replace time_pct = number_pct in 2
    replace variable = "Don't know the number" in 2
    replace time_pct = benefits_pct in 3
    replace variable = "Don't know the benefits" in 3
	replace time_pct = information_pct in 4
    replace variable = "Not sharing info" in 4
	replace time_pct = interest_pct in 5
    replace variable = "Not interested" in 5
	
	 * Store total N in a local macro directly from total_obs
     local N = total_obs[1]
	 
     keep if _n <= 5
    rename time_pct percent
	
	
	gen percent_round = round(percent)
   

   * Create the bar graph
   
    graph hbar percent_round, over(variable, sort(percent_round) descending) ///
    bar(1, color(navy)) bar(2, color(blue)) ///
    title("Reason(s) do you not include your CPF number") ///
    ytitle("Percent") ///
    blabel(bar) ///
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed



	restore
	
	*And according to the following options, considering all the purchases you make for yourself and your family who lives with you, how much approximately do you spend throughout the month?
	
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(monthly_spend)

     egen total_sum = total(total) if !missing(monthly_spend)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	   * Store total N in a local macro
	  
	 sum total if !missing(monthly_spend), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   

   * Create the bar graph
   
    graph hbar percent_round, over(monthly_spend, sort(percent_round) descending) ///
    bar(1, color(navy)) bar(2, color(blue)) ///
    title("Monthly Spending on Purchases") ///
    ytitle("Percent") ///
    blabel(bar) ///
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed


	restore
	
	
	*And according to the following options, considering all the purchases you make for yourself and your family who lives with you, how much approximately do you spend throughout the month? NFI05
	
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(monthly_purchases_cat)

     egen total_sum = total(total) if !missing(monthly_purchases_cat)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	   * Store total N in a local macro
	  
	 sum total if !missing(monthly_purchases_cat), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
	 
	 gen monthly_label = string(monthly_purchases_cat)
	 
	 
   * Assign a numeric order to categories
   
    gen order = .
    replace order = 1 if monthly_label == "Less than R$500.00"
    replace order = 2 if monthly_label == "From R$500.00 to R$1,000.00"
    replace order = 3 if monthly_label == "From R$1,000.00 to R$1,500.00"
    replace order = 4 if monthly_label == "From R$1,500.00 to R$2,000.00"
    replace order = 5 if monthly_label == "More than R$ 2,000.00"

   * Ensure the order is correctly applied
   
    gsort order

   * Create the bar graph
   
    graph hbar percent_round, over(monthly_purchases_cat, sort(order)) ///
    bar(1, color(navy)) bar(2, color(blue)) ///
    title("Monthly Spending on Purchases") ///
    ytitle("Percent") ///
    blabel(bar) ///
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed


	restore
	
	*Do you have the Citizen Card from the Devolve-ICMS program?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(card_devolve)

     egen total_sum = total(total) if !missing(card_devolve)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(card_devolve), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   

   * Create the bar graph
   
  graph hbar percent_round, over(card_devolve, sort(percent_round) descending) ///
    bar(1, color(navy)) bar(2, color(blue)) ///
    title("Citizen Card Ownership (Devolve-ICMS)") ///
    ytitle("Percent") ///
    blabel(bar) ///
     note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed
	
	restore
	
	
	*How long does it take to spend the amounts you receive on your Devolve card?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(spend_value)

     egen total_sum = total(total) if !missing(spend_value)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(spend_value), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   

   * Create the bar graph
   
    graph hbar percent_round, over(spend_value, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Spend the amounts Devolve card") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
     note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed

	
	restore
	
	
	
	*How much of the money on your Citizen Card do you use?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(use_citizen_card)

     egen total_sum = total(total) if !missing(use_citizen_card)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	 * Store total N in a local macro
	  
	 sum total if !missing(use_citizen_card), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   
   
   
	  gen money_label = string(use_citizen_card)
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if money_label == "All"
    replace order = 2 if money_label == "More than half"
    replace order = 3 if money_label == "Half"
    replace order = 4 if money_label == "Less than half"
    

   * Ensure the order is correctly applied
    gsort order

   * Create the bar graph
   
    graph hbar percent_round, over(use_citizen_card, sort(order)) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Usage of Funds on the Citizen Card") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed

	
	restore
	
	*How much of the money on your Citizen Card do you use?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(main_use_card)

     egen total_sum = total(total) if !missing(main_use_card)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	 
	 * Store total N in a local macro
	  
	 sum total if !missing(main_use_card), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   

   * Create the bar graph
   
    graph hbar percent_round, over(main_use_card, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Main Use of the ICMS Return Citizen Card") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed
	
	restore
	
	*Have you ever had any problems when trying to use your Citizen Card from the Devolve-ICMS program?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(problem_card)

     egen total_sum = total(total) if !missing(problem_card)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	 * Store total N in a local macro
	  
	 sum total if !missing(problem_card), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   

   * Create the bar graph
   
    graph hbar percent_round, over(problem_card, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Issues with Using the Devolve-ICMS Citizen Card") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed

	
	restore
	
   	*What problems did you encounter when using your Citizen Card?
	
     preserve
	 
     gen store_yes = problem_card_na == 1
     gen transfer_yes = problem_card_transfer == 1
     gen money_yes = problem_card_money == 1
     gen password_yes = problem_card_password == 1
     gen other_yes = problem_card_other == 1



    egen store_yes_total = total(store_yes)
    egen transfer_yes_total = total(transfer_yes)
    egen money_yes_total = total(money_yes)
    egen password_yes_total = total(password_yes)
    egen other_yes_total = total(other_yes)


   * Calculate percentages

    egen total_obs = count(problem_card_na) // Total observations 
    gen store_pct = (store_yes_total / total_obs) * 100
    gen transfer_pct = (transfer_yes_total / total_obs) * 100
    gen money_pct = (money_yes_total / total_obs) * 100
    gen password_pct = (password_yes_total / total_obs) * 100
    gen other_pct = (other_yes_total / total_obs) * 100


    gen variable = "Not accepted at the store" in 1
    replace store_pct = transfer_pct in 2
    replace variable = "Transfers are delayed or don't arrive" in 2
    replace store_pct = money_pct in 3
    replace variable = "Don't know how much money in the card" in 3
	replace store_pct = password_pct in 4
    replace variable = "Don't know the PIN" in 4
	replace store_pct = other_pct in 5
    replace variable = "Other" in 5
	
	 * Store total N in a local macro directly from total_obs
     local N = total_obs[1]
	 
	
     keep if _n <= 5
    rename store_pct percent
	
	
	gen percent_round = round(percent)
   


   * Create the bar graph
   
    graph hbar percent_round, over(variable, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Issues with Using the Devolve-ICMS Citizen Card") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed

	
	restore
	
	*Have you tried to get the Citizen Card from the Devolve-ICMS program?
	
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(get_card)

     egen total_sum = total(total) if !missing(get_card)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	 
	 * Store total N in a local macro
	  
	 sum total if !missing(get_card), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   

   * Create the bar graph
   
    graph hbar percent_round, over(get_card, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Efforts to Obtain the Devolve-ICMS Citizen Card") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
     note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed

	
	restore
	
	
	**For what reason(s) did you not collect your card?
	
	
	preserve
	

     gen location_yes = card_collection_l == 1
     gen distance_yes = card_collection_d == 1
     gen kids_yes = card_collection_k == 1
     gen work_yes = card_collection_w == 1
     gen transport_yes = card_collection_t == 1
     gen participation_yes = card_collection_p == 1
	 gen program_yes = card_collection_dp == 1
	 gen other_yes = card_collection_other == 1


    egen location_yes_total = total(location_yes)
    egen distance_yes_total = total(distance_yes)
    egen kids_yes_total = total(kids_yes)
    egen work_yes_total = total(work_yes)
    egen transport_yes_total = total(transport_yes)
    egen program_yes_total = total(program_yes)
	egen participation_yes_total = total(participation_yes)
	egen other_yes_total = total(other_yes)

   * Calculate percentages

    egen total_obs = count(card_collection_l) // Total observations 
    gen location_pct = (location_yes_total / total_obs) * 100
    gen distance_pct = (distance_yes_total / total_obs) * 100
    gen kids_pct = (kids_yes_total / total_obs) * 100
    gen work_pct = (work_yes_total / total_obs) * 100
    gen transport_pct = (transport_yes_total / total_obs) * 100
	gen participation_pct = (participation_yes_total / total_obs) * 100
	gen program_pct = (program_yes_total / total_obs) * 100
	gen other_pct = (other_yes_total / total_obs) * 100


    gen variable = "Location" in 1
    replace location_pct = distance_pct in 2
    replace variable = "Distance" in 2
    replace location_pct = kids_pct in 3
    replace variable = "Take care kids" in 3
	replace location_pct = work_pct in 4
    replace variable = "Work" in 4
	replace location_pct = transport_pct in 5
    replace variable = "Transport" in 5
	replace location_pct = participation_pct in 6
    replace variable = "Didn't know could participate" in 6
	replace location_pct = program_pct in 7
    replace variable = "Didn't know the program" in 7
	replace location_pct = other_pct in 8
    replace variable = "Other" in 8
	
	 * Store total N in a local macro directly from total_obs
     local N = total_obs[1]
	 
	
     keep if _n <= 8
    rename location_pct percent
	
	
	gen percent_round = round(percent)
   

   * Create the bar graph
   
    graph hbar percent_round, over(variable, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Reasons for not collecting the card because of...") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed

	
	restore
	
	
	*How worried would you be about there being NO stores nearby where you could use your card?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(stores_nearby)

     egen total_sum = total(total) if !missing(stores_nearby)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	 * Store total N in a local macro
	  
	 sum total if !missing(stores_nearby), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   
    gen stores_label = string(stores_nearby)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if stores_label == "Very worried"
    replace order = 2 if stores_label == "Worried"
    replace order = 3 if stores_label == "A little worried"
    replace order = 4 if stores_label == "No worried"
    replace order = 5 if stores_label == "Don't know"

   * Ensure the order is correctly applied
    gsort order

   * Create the bar graph
   
    graph hbar percent_round, over(stores_nearby, sort(order)) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Concerns About Lack of Nearby Stores for Card Use") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed

	
	restore
	
	*How much do you worry about knowing how to use the card?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(card_use_worry)

     egen total_sum = total(total) if !missing(card_use_worry)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(card_use_worry), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   
   
    gen stores_label = string(card_use_worry)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if stores_label == "Very worried"
    replace order = 2 if stores_label == "Worried"
    replace order = 3 if stores_label == "A little worried"
    replace order = 4 if stores_label == "No worried"
    replace order = 5 if stores_label == "Don't know"

   * Ensure the order is correctly applied
    gsort order

   * Create the bar graph
   
    graph hbar percent_round, over(card_use_worry, sort(order)) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Level of concern about using the card") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed

	
	restore
	
	*How worried would you be about someone in your household using your card without your permission?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(worry_unauthorized_card)

     egen total_sum = total(total) if !missing(worry_unauthorized_card)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(worry_unauthorized_card), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   
    gen stores_label = string(worry_unauthorized_card)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if stores_label == "Very worried"
    replace order = 2 if stores_label == "Worried"
    replace order = 3 if stores_label == "A little worried"
    replace order = 4 if stores_label == "No worried"
    replace order = 5 if stores_label == "Don't know"

   * Ensure the order is correctly applied
    gsort order


   * Create the bar graph
   
    graph hbar percent_round, over(worry_unauthorized_card, sort(order)) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Concern about unauthorized card use by household members") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
     note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed

	
	restore
	
	*Income inequality is a serious problem in Brazil.
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(inequality_brazil)

     egen total_sum = total(total) if !missing(inequality_brazil)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(inequality_brazil), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
	 
	 gen inequality_label = string(inequality_brazil)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if inequality_label == "Strongly Agree"
    replace order = 2 if inequality_label == "Agree"
    replace order = 3 if inequality_label == "Disagree"
    replace order = 4 if inequality_label == "Strongly Disagree"
    replace order = 5 if inequality_label == "Don't know"

   * Ensure the order is correctly applied
    sort order

   * Create the ordered bar graph
   
    graph hbar percent_round, over(inequality_brazil, sort(order)) ///
    bar(1, color(navy)) bar(2, color(blue)) ///
    title("Perceptions of Income Inequality in Brazil") ///
    ytitle("Percent") ///
    blabel(bar) ///
    note("N=`N'") ///
    ysize(6) xsize(10)  // Adjust size as needed

   
	
	restore
	
**How much is the ICMS charged on most of the things we buy in Rio Grande do Sul?
	
preserve

 
	
    *Replace values

	
	replace icms_rate2_div=2 if icms_rate2>=7 & icms_rate2<10
	
	replace icms_rate2=3 if icms_rate2>=10 & icms_rate2<20
	
	replace icms_rate2=4 if icms_rate2>=20 & icms_rate2<30
	
	replace icms_rate2=5 if icms_rate2>=30 & icms_rate2<40
	
	replace icms_rate2=6 if icms_rate2>=40 

    * Generate total count per ICMS rate
    gen total = 1
    collapse (sum) total, by(icms_rate2)

    * Compute total observations
    egen total_sum = total(total)

    * Calculate percentage per ICMS rate group
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Drop very small percentages for cleaner visualization
    drop if percent_round < 1
	
	 gen rate_label = string(icms_rate2)
   
   * Assign a numeric order to categories
    gen order = .
	replace order = 1 if rate_label == "Less than 5%"
    replace order = 2 if rate_label == "Between 5-10%"
    replace order = 3 if rate_label == "Between 10-20%"
    replace order = 4 if rate_label == "Between 20-30%"
    replace order = 5 if rate_label == "Between 30-40%"
    replace order = 6 if rate_label == "More than 40%"

   * Ensure the order is correctly applied
    sort order

    * Store total N in a local macro
    sum total, meanonly
    local N : display %15.0fc r(sum)

    * Create the bar graph sorted by ICMS rate (smallest to largest)
    graph hbar percent_round, over(icms_rate2, sort(order)) ///
        bar(1, color(navy)) /// Dark blue for bars
        title("Perceived ICMS Tax Rate on Purchases in Rio Grande do Sul") ///
        ytitle("Percent") ///
        blabel(bar, format(%10.0gc) position(outside)) ///
        note("N=`N'") ///
        ysize(6) xsize(10)  // Adjust size as needed

restore


**How much is the ICMS charged on most of the things we buy in Rio Grande do Sul?- IET05 and IET05a
	
preserve
   
   replace icms_rate2=2 if icms_rate2>=7 & icms_rate2<10
	
	replace icms_rate2=3 if icms_rate2>=10 & icms_rate2<20
	
	replace icms_rate2=4 if icms_rate2>=20 & icms_rate2<30
	
	replace icms_rate2=5 if icms_rate2>=30 & icms_rate2<40
	
	replace icms_rate2=6 if icms_rate2>=40 

 
   gen icms_combined = icms_rate2  // Start with icms_rate2 responses
   replace icms_combined = icms_rate_rgs if icms_rate2 == -9 | missing(icms_rate2)  // Use icms_rate_rgs if icms_rate2 is missing

    // Label the new variable
   label var icms_combined "Perceived ICMS Rate (Combined)"
   label define icms_labels 1 "Less than 5%" 2 "Between 5-10%" 3 "Between 10-20%" ///
                         4 "Between 20-30%" 5 "Between 30-40%" 6 "More than 40%" ///
                         666 "Don't know"
    label values icms_combined icms_labels

    * Generate total count per ICMS category
    gen total = 1
    collapse (sum) total, by(icms_combined)

    * Compute total observations
    egen total_sum = total(total)

    * Calculate percentage per ICMS category
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Drop very small percentages for cleaner visualization
    drop if percent_round < 1

    * Create a new variable with labels including counts
    gen icms_label_with_counts = ""
    replace icms_label_with_counts = "Less than 5%" if icms_combined == 1
    replace icms_label_with_counts = "Between 5-10%" if icms_combined == 2
    replace icms_label_with_counts = "Between 10-20%" if icms_combined == 3
    replace icms_label_with_counts = "Between 20-30%" if icms_combined == 4
    replace icms_label_with_counts = "Between 30-40%" if icms_combined == 5
    replace icms_label_with_counts = "More than 40%" if icms_combined == 6
    replace icms_label_with_counts = "Don't know" if icms_combined == 666

    * Sort in the correct order
    sort icms_combined

    * Store total N in a local macro
    sum total, meanonly
    local N : display %15.0fc r(sum)

    * Create the bar graph using the updated labels
    graph hbar percent_round, over(icms_label_with_counts, sort(icms_combined)) ///
        bar(1, color(navy)) /// Dark blue for bars
        title("Perceived ICMS Tax Rate on Purchases in Rio Grande do Sul") ///
        ytitle("Percent") ///
        blabel(bar, format(%10.0gc) position(outside)) ///
        note("N=`N'") ///
        ysize(6) xsize(10)  // Adjust size as needed

restore


	
	*The government should collect more taxes from rich people and give more money to poor people.
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(tax_collection)

     egen total_sum = total(total) if !missing(tax_collection)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	 drop if percent_round<1
   
    * Store total N in a local macro
	  
	 sum total if !missing(tax_collection), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   
   
    gen tax_label = string(tax_collection)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if tax_label == "Strongly Agree"
    replace order = 2 if tax_label == "Agree"
    replace order = 3 if tax_label == "Disagree"
    replace order = 4 if tax_label == "Strongly Disagree"
    replace order = 5 if tax_label == "Don't know"

   * Ensure the order is correctly applied
    gsort order

   * Create the bar graph
   
    graph hbar percent_round, over(tax_collection, sort(order)) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Support for Progressive Taxation and Redistribution") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed

	
	restore
	
	*Most of the money the government receives should come from taxes on what people earn or have, such as income tax, not on what people. 
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(tax_revenue_preference)

     egen total_sum = total(total) if !missing(tax_revenue_preference)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(tax_revenue_preference), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   
   
   gen revenue_label = string(tax_revenue_preference)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if revenue_label == "Strongly Agree"
    replace order = 2 if revenue_label == "Agree"
    replace order = 3 if revenue_label == "Disagree"
    replace order = 4 if revenue_label == "Strongly Disagree"
    replace order = 5 if revenue_label == "Don't know"

   * Ensure the order is correctly applied
    gsort order


   * Create the bar graph
   
    graph hbar percent_round, over(tax_revenue_preference, sort(order)) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Support for Income-Based vs. Consumption-Based Taxation") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
     note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed


	
	restore
	
	*We should pay less tax on essential goods like food compared to other products we buy.
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(tax_essential_goods)

     egen total_sum = total(total) if !missing(tax_essential_goods)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(tax_essential_goods), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
	 
	 gen essential_label = string(tax_essential_goods)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if essential_label == "Strongly Agree"
    replace order = 2 if essential_label == "Agree"
    replace order = 3 if essential_label == "Disagree"
    replace order = 4 if essential_label == "Strongly Disagree"
    replace order = 5 if essential_label == "Don't know"

   * Ensure the order is correctly applied
    gsort order
   

   * Create the bar graph
   
    graph hbar percent_round, over(tax_essential_goods, sort(order)) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Support for Lower Taxes on Essential Goods") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed


	
	restore
	
	*How much is the ICMS charged on most of the things we buy in Rio Grande do Sul?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(icms_rate_rgs)

     egen total_sum = total(total) if !missing(icms_rate_rgs)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	 gen icms_label = string(icms_rate_rgs)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if icms_label == "Less than 5%"
    replace order = 2 if icms_label == "Between 5-10%"
    replace order = 3 if icms_label == "Between 10-20% "
    replace order = 4 if icms_label == "Between 20-30%"
    replace order = 5 if icms_label == "Between 30-40%"
	replace order = 6 if icms_label == "More than 40%"

   * Ensure the order is correctly applied
    gsort order
	
	  * Store total N in a local macro
	  
	 sum total if !missing(icms_rate_rgs), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   

   * Create the bar graph
   
    graph hbar percent_round, over(icms_rate_rgs, sort(order)) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("ICMS Tax Rates on Goods in Rio Grande do Sul") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed

	
	restore
	
	
	*To receive more money from the Devolve ICMS program, you must include your CPF on the invoice when making purchases. Knowing this, you should consider this rule:
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(cpf_on_invoice_rule)

     egen total_sum = total(total) if !missing(cpf_on_invoice_rule)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(cpf_on_invoice_rule), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   
   gen cpf_label = string(cpf_on_invoice_rule)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if cpf_label == "Strongly Fair"
    replace order = 2 if cpf_label == "Fair"
    replace order = 3 if cpf_label == "Not Fair"
    replace order = 4 if cpf_label == "Strongly Unfair"
    replace order = 5 if cpf_label == "Don't know"

   * Ensure the order is correctly applied
    gsort order
   
   

   * Create the bar graph
   
    graph hbar percent_round, over(cpf_on_invoice_rule, sort(order)) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Awareness of CPF Inclusion for Devolve ICMS Program") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed

	
	restore
	
	*Are you in favor of the government increasing the tax on food so that it is the same as on other products? That is, that all products have the same tax, even if it means spending more when buying food.
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(increase_tax_on_food)

     egen total_sum = total(total) if !missing(increase_tax_on_food)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  
	  * Store total N in a local macro
	  
	 sum total if !missing(increase_tax_on_food), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
	 
	  gen increase_label = string(increase_tax_on_food)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if increase_label == "Totally in Favor"
    replace order = 2 if increase_label == "Favor"
    replace order = 3 if increase_label == "Against"
    replace order = 4 if increase_label == "Totally Against"
    replace order = 5 if increase_label == "Don't know"

   * Ensure the order is correctly applied
    gsort order
   
   
   

   * Create the bar graph
   
    graph hbar percent_round, over(increase_tax_on_food, sort(order)) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Support for Equalizing Taxes on Food and Other Products") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
     note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed



	
	restore
	
  *Are you in favor of the government increasing the tax on food so that it is equal to that on other products, only if participants in the Devolve program receive it back?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(tax_on_foodreturned)

     egen total_sum = total(total) if !missing(tax_on_foodreturned)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(tax_on_foodreturned), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   
     gen tax_label = string(tax_on_foodreturned)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if tax_label == "Totally in Favor"
    replace order = 2 if tax_label == "Favor"
    replace order = 3 if tax_label == "Against"
    replace order = 4 if tax_label == "Totally Against"
    replace order = 5 if tax_label == "Don't know"

   * Ensure the order is correctly applied
    gsort order
   
   
   * Create the bar graph
   
    graph hbar percent_round, over(tax_on_foodreturned, sort(order)) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Support for Tax Equalization on Food with Devolve Program") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
     note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed

	restore
	
	
	 *Are you in favor of the government increasing the tax on food so that it is equal to that on other products, only if all residents of Rio Grande do Sul receive back the amount paid in tax?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(tax_food_all)

     egen total_sum = total(total) if !missing(tax_food_all)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(tax_food_all), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   
   gen tax_label = string(tax_food_all)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if tax_label == "Totally in Favor"
    replace order = 2 if tax_label == "Favor"
    replace order = 3 if tax_label == "Against"
    replace order = 4 if tax_label == "Totally Against"
    replace order = 5 if tax_label == "Don't know"

   * Ensure the order is correctly applied
    gsort order

   * Create the bar graph
   
    graph hbar percent_round, over(tax_food_all, sort(order)) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Support for Equalizing Food Tax with Refunds for All Residents") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
     note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed

	restore
	
	 *Are you in favor of the government reducing the tax on perfumes and makeup so that it is the same as on other products?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(tax_perfumes_makeup)

     egen total_sum = total(total) if !missing(tax_perfumes_makeup)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(tax_perfumes_makeup), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
	 
	  gen tax_label = string(tax_perfumes_makeup)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if tax_label == "Totally in Favor"
    replace order = 2 if tax_label == "Favor"
    replace order = 3 if tax_label == "Against"
    replace order = 4 if tax_label == "Totally Against"
    replace order = 5 if tax_label == "Don't know"

   * Ensure the order is correctly applied
    gsort order
   

   * Create the bar graph
   
    graph hbar percent_round, over(tax_perfumes_makeup, sort(order)) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Support for Reducing Taxes on Perfumes and Makeup") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
     note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed

	restore
	
	 *Are you familiar with the Nota Fiscal Gaúcha program?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(nota_fiscal_program)

     egen total_sum = total(total) if !missing(nota_fiscal_program)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(nota_fiscal_program), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   
   

   * Create the bar graph
   
    graph hbar percent_round, over(nota_fiscal_program, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Awareness of the Nota Fiscal Gaúcha Program") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed

	restore
	
	 *Are you part of it?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(participate_nfg)

     egen total_sum = total(total) if !missing(participate_nfg)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(participate_nfg), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   

   * Create the bar graph
   
    graph hbar percent_round, over(participate_nfg, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Participation Nota Fiscal Gaúcha Program") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed

	restore
	
	
	
	 *What is the main reason you do not participate in the Nota Fiscal Gaúcha program?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(reason_nfg)

     egen total_sum = total(total) if !missing(reason_nfg)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	 * Store total N in a local macro
	  
	 sum total if !missing(reason_nfg), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
	 

   * Create the bar graph
   
    graph hbar percent_round, over(reason_nfg, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Reasons for Not Joining Nota Fiscal Gaúcha") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore
	
	*If you would like, I can soon send you information on how to apply for the program. Would you like to receive it?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(send_information)

     egen total_sum = total(total) if !missing(send_information)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	 * Store total N in a local macro
	  
	 sum total if !missing(send_information), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
	 
   

   * Create the bar graph
   
    graph hbar percent_round, over(send_information, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Send information about the program") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore
	
	*Do you prefer to receive information via SMS or Whatsapp?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(send_information_method)

     egen total_sum = total(total) if !missing(send_information_method)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	 * Store total N in a local macro
	  
	 sum total if !missing(send_information_method), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   

   * Create the bar graph
   
    graph hbar percent_round, over(send_information_method, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Preferred Method of Receiving Information: SMS or WhatsApp?") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore
	
	*Including benefits such as Bolsa Família, how much money do you and your family earn per month?
	
	preserve
	
	 gen income_div=0
	 
	 replace income_div=1 if income>=2 & income<666
	 
	 replace income_div=income if income==666
	 
	 label var income_div "Income Division"
	
	 la de lblincome_div 0 "Less than 600" 1 "More than 600" 666 "Don't know"
	
	 label values income_div lblincome_div

     gen total = 1
	 
     collapse (sum) total, by(income_div)

     egen total_sum = total(total) if !missing(income_div)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  
	 * Store total N in a local macro
	  
	 sum total if !missing(income_div), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   

   * Create the bar graph
   
    graph hbar percent_round, over(income_div, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Income including benefits per month (reais)") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore
	
	*Including yourself, how many people live in your house?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(household_size)

     egen total_sum = total(total) if !missing(household_size)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
    gen order = household_size
    
   * Ensure the order is correctly applied
   
    gsort order
	
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(household_size), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   

   * Create the bar graph
   
    graph hbar percent_round, over(household_size, sort(order)) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Household Size (Including Yourself)") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore
	
	
	
	
	*Have you or anyone in your family been affected by this year's floods?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(flood_impact)

     egen total_sum = total(total) if !missing(flood_impact)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(flood_impact), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   

   * Create the bar graph
   
    graph hbar percent_round, over(flood_impact, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Impact of This Year's Floods on You or Your Family") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore
	
	
	*How many days were you unable to enter your home because of the floods?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(displaced_rains_days)

     egen total_sum = total(total) if !missing(displaced_rains_days)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  gen order = displaced_rains_days
    
   * Ensure the order is correctly applied
   
       gsort order
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(displaced_rains_days), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<5
   
   

   * Create the bar graph
   
    graph hbar percent_round, over(displaced_rains_days, sort(order)) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Days Unable to Enter Home Due to Floods") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore
	
	
	*How do you assess the impact of floods on your life?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(flood_impact2)

     egen total_sum = total(total) if !missing(flood_impact2)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(flood_impact2), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
	 
	  gen floods_label = string(flood_impact2)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if floods_label == "Very Big"
    replace order = 2 if floods_label == "Big"
    replace order = 3 if floods_label == "Medium"
    replace order = 4 if floods_label == "Small"
    replace order = 5 if floods_label == "Don't know"

   * Ensure the order is correctly applied
    gsort order
   

   * Create the bar graph
   
    graph hbar percent_round, over(flood_impact2, sort(order)descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Assessment of Flood Impact on Your Life") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
     note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore
	
	*Did you have to leave your home during the heavy rains this year in Rio Grande do Sul?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(displaced_rains)

     egen total_sum = total(total) if !missing(displaced_rains)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	* Store total N in a local macro
	  
	 sum total if !missing(displaced_rains), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   

   * Create the bar graph
   
    graph hbar percent_round, over(displaced_rains, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Displacement During Heavy Rains in Rio Grande do Sul This Year") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore
	
	*Did you receive any help (money, materials or otherwise) to recover from the floods?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(flood_aid)

     egen total_sum = total(total) if !missing(flood_aid)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	 * Store total N in a local macro
	  
	 sum total if !missing(flood_aid), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   

   * Create the bar graph
   
    graph hbar percent_round, over(flood_aid, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Assistance Received for Flood Recovery") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore
	
	*What kind of assistance or help did you receive after the floods?
	
	 preserve
	 
     gen finance_yes = aid_finance == 1
     gen material_yes = aid_material == 1
     gen medic_yes = aid_medic == 1
     gen cleaning_yes = aid_cleaning == 1
     gen reconstruction_yes = aid_reconstruction == 1
     gen other_yes = aid_reconstruction == 1
	 


    egen finance_yes_total = total(finance_yes)
    egen material_yes_total = total(material_yes)
    egen medic_yes_total = total(medic_yes)
    egen cleaning_yes_total = total(cleaning_yes)
    egen reconstruction_yes_total = total(reconstruction_yes)
    egen other_yes_total = total(other_yes)
	

   * Calculate percentages

    egen total_obs = count(aid_finance) // Total observations 
    gen finance_pct = (finance_yes_total / total_obs) * 100
    gen material_pct = (material_yes_total / total_obs) * 100
    gen medic_pct = (medic_yes_total / total_obs) * 100
    gen cleaning_pct = (cleaning_yes_total / total_obs) * 100
    gen reconstruction_pct = (reconstruction_yes_total / total_obs) * 100
	gen other_pct = (other_yes_total / total_obs) * 100


    gen variable = "Financial aid" in 1
    replace finance_pct = material_pct in 2
    replace variable = "Material aid" in 2
    replace finance_pct = medic_pct in 3
    replace variable = "Medical assistance" in 3
	replace finance_pct = cleaning_pct in 4
    replace variable = "Cleaning assistance" in 4
	replace finance_pct = reconstruction_pct in 5
    replace variable = "Reconstruction assistance" in 5
	replace finance_pct = other_pct in 6
    replace variable = "Other" in 6
	
	* Store total N in a local macro directly from total_obs
     local N = total_obs[1]
	 
	
     keep if _n <= 6
    rename finance_pct percent
	
	
	gen percent_round = round(percent)
    
   

   * Create the bar graph
   
    graph hbar percent_round, over(variable, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Type of Assistance Received for Flood Recovery") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore
***********************************************************************************

 *Are you familiar with the Nota Fiscal Gaúcha program?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(nota_fiscal_program)

     egen total_sum = total(total) if !missing(nota_fiscal_program)
   
     gen percent = (total / total_sum) * 100  
	
	 
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(nota_fiscal_program), meanonly
     local N : display %15.0fc r(sum)
	 
	 
   
   

   * Create the bar graph
   
    graph hbar percent, over(nota_fiscal_program, sort(percent) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Awareness of the Nota Fiscal Gaúcha Program") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed

	restore
	
	 *Are you part of it?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(participate_nfg)

     egen total_sum = total(total) if !missing(participate_nfg)
   
     gen percent = (total / total_sum) * 100  
	
	
	 
	  * Store total N in a local macro
	  
	 sum total if !missing(participate_nfg), meanonly
     local N : display %15.0fc r(sum)
	 
	 
   

   * Create the bar graph
   
    graph hbar percent, over(participate_nfg, sort(percent) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Participation Nota Fiscal Gaúcha Program") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed

	restore
	
	
	
	 *What is the main reason you do not participate in the Nota Fiscal Gaúcha program?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(reason_nfg)

     egen total_sum = total(total) if !missing(reason_nfg)
   
     gen percent = (total / total_sum) * 100  
	
	
	 
	 * Store total N in a local macro
	  
	 sum total if !missing(reason_nfg), meanonly
     local N : display %15.0fc r(sum)
	 
	 
	 

   * Create the bar graph
   
    graph hbar percent, over(reason_nfg, sort(percent) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Reasons for Not Joining Nota Fiscal Gaúcha") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore	
	
	*If you would like, I can soon send you information on how to apply for the program. Would you like to receive it?
	
	preserve
	

     gen total = 1
	 
     collapse (sum) total, by(send_information)

     egen total_sum = total(total) if !missing(send_information)
   
     gen percent = (total / total_sum) * 100  
	

	 * Store total N in a local macro
	  
	 sum total if !missing(send_information), meanonly
     local N : display %15.0fc r(sum)
	 
	 
   

   * Create the bar graph
   
    graph hbar percent, over(send_information, sort(percent) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Send information about the program") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore
	
*Other 	How did you find out you were part of the program?

    preserve
	
	gen other_PAG02=PAR02oth
	
	replace other_PAG02="School" if other_PAG02=="Escola"
	
	replace other_PAG02="Received a letter" if other_PAG02=="Recebeu uma correspondência"
	
	replace other_PAG02="Banco Banrisul" if other_PAG02=="Banco Banrisul"
	
	*Count occurrences of each category
	
    bysort other_PAG02 (other_PAG02): gen freq = _N

   *Recode categories below the threshold as "Other"
   
    replace other_PAG02 = "Other" if freq < 9

    *Drop helper variable
	
      drop freq
	

     gen total = 1
	 
     collapse (sum) total, by(other_PAG02)

     egen total_sum = total(total) if !missing(other_PAG02)
   
     gen percent = (total / total_sum) * 100  
	 
	 
	

	 * Store total N in a local macro
	  
	 sum total if !missing(other_PAG02), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent <10
	 
	 gen percent_round = round(percent)
    
   

   * Create the bar graph
   
    graph hbar percent_round, over(other_PAG02, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("How did you find out you were part of the program?-Other") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore


*Other 	Who are the other participants in the program that you know?

    preserve
	
	gen other_DEV02=DEV02aoth
	
	replace other_DEV02="Neighbors" if other_DEV02=="Vizinhos"
	
	replace other_DEV02="Coworkers" if other_DEV02=="Colegas de trabalho"
	
	replace other_DEV02="Acquaintances" if other_DEV02=="conhecidos"
	
	replace other_DEV02="Acquaintances" if other_DEV02=="Conhecidos"
	
	replace other_DEV02="Acquaintances" if other_DEV02=="Conhecidos."
	
	*Count occurrences of each category
	
    bysort other_DEV02 (other_DEV02): gen freq = _N

   *Recode categories below the threshold as "Other"
   
    replace other_DEV02 = "Other" if freq < 5

    *Drop helper variable
	
      drop freq
	

     gen total = 1
	 
     collapse (sum) total, by(other_DEV02)

     egen total_sum = total(total) if !missing(other_DEV02)
   
     gen percent = (total / total_sum) * 100  
	 
	 * Store total N in a local macro
	  
	 sum total if !missing(other_DEV02), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent <2
	 
	 gen percent_round = round(percent)
    
   

   * Create the bar graph
   
    graph hbar percent_round, over(other_DEV02, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Other participants in the program that you know?-Other") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore
	
	
*Other *What banks or financial institutions do you and other family members living with you have accounts at?

    preserve
	
	gen other_PAG03=PAG03aoth
	
	 *Count occurrences of each category
	
    bysort other_PAG03 (other_PAG03): gen freq = _N

   *Recode categories below the threshold as "Other"
   
    replace other_PAG03 = "Other" if freq < 6

    *Drop helper variable
	
      drop freq
	 

     gen total = 1
	 
     collapse (sum) total, by(other_PAG03)

     egen total_sum = total(total) if !missing(other_PAG03)
   
     gen percent = (total / total_sum) * 100  
	 
	 * Store total N in a local macro
	  
	 sum total if !missing(other_PAG03), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent <9
	 
	 gen percent_round = round(percent)
    
   

   * Create the bar graph
   
    graph hbar percent_round, over(other_PAG03, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Financial Institutions-Other") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore
	
	
	
	
*Other For what reason(s) do you not include your CPF number on the invoice? NFI04a1

    preserve
	
	gen other_NFI04a1=NFI04a1oth
	
	
	replace other_NFI04a1="Forget to request" if other_NFI04a1=="Esquece de solicitar"
	
	replace other_NFI04a1="Lack of time/hurry" if other_NFI04a1=="Falta de tempo/ pressa"
	
	replace other_NFI04a1=" Not included for small purchases" if other_NFI04a1=="Compras de pequeno valor não inclui o CPF"
	
	*Count occurrences of each category
	
    bysort other_NFI04a1 (other_NFI04a1): gen freq = _N

   *Recode categories below the threshold as "Other"
   
    replace other_NFI04a1 = "Other" if freq < 11

    *Drop helper variable
	
      drop freq

     gen total = 1
	 
     collapse (sum) total, by(other_NFI04a1)

     egen total_sum = total(total) if !missing(other_NFI04a1)
   
     gen percent = (total / total_sum) * 100  
	

	 * Store total N in a local macro
	  
	 sum total if !missing(other_NFI04a1), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent <9
	 
	 gen percent_round = round(percent)
    
   

   * Create the bar graph
   
    graph hbar percent_round, over(other_NFI04a1, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Reason(s) do you not include your CPF-Other") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore	
	
	
	
	
*Other For what reason(s) do you not include your CPF number on the invoice? NFI04b1oth 

    preserve
	
	gen other_NFI04b1=NFI04b1oth
	
	
	replace other_NFI04b1="Forget to request" if other_NFI04b1=="Esquece de solicitar"
	
	replace other_NFI04b1="Attendant didn't requested it" if other_NFI04b1=="Não inclui o CPF quando o atendente não solicita"
	
	replace other_NFI04b1="Not included for small purchases" if other_NFI04b1=="Compras de pequeno valor não inclui o CPF"
	
	
	*Count occurrences of each category
	
    bysort other_NFI04b1 (other_NFI04b1): gen freq = _N

   *Recode categories below the threshold as "Other"
   
    replace other_NFI04b1 = "Other" if freq < 12

    *Drop helper variable
	
      drop freq

     gen total = 1
	 
     collapse (sum) total, by(other_NFI04b1)

     egen total_sum = total(total) if !missing(other_NFI04b1)
   
     gen percent = (total / total_sum) * 100  
	 

	 * Store total N in a local macro
	  
	 sum total if !missing(other_NFI04b1), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent <5
	 
	 gen percent_round = round(percent)
    
   

   * Create the bar graph
   
    graph hbar percent_round, over(other_NFI04b1, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Reason(s) do you not include your CPF-Other") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore	
	
*Other What problems did you encounter when using your Citizen Card? CCD07

    preserve
	
	gen other_CCD07=CCD07oth
	
	
	replace other_CCD07="System down" if other_CCD07=="Sistema fora do ar"
	
	replace other_CCD07="A Overload and deposit failure" if other_CCD07=="Sistema fica fora do ar quando o dinheiro é depositado ou sobrecarga de usuários comparando"
	
	
	replace other_CCD07="Card reading error" if other_CCD07=="Erro de leitura do cartão na máquina da loja/ Máquina da loja travou"
	
	*Count occurrences of each category
	
    bysort other_CCD07 (other_CCD07): gen freq = _N

   *Recode categories below the threshold as "Other"
   
    replace other_CCD07 = "Other" if freq < 11

    *Drop helper variable
	
      drop freq

     gen total = 1
	 
     collapse (sum) total, by(other_CCD07)

     egen total_sum = total(total) if !missing(other_CCD07)
   
     gen percent = (total / total_sum) * 100  
	 
	 
	

	 * Store total N in a local macro
	  
	 sum total if !missing(other_CCD07), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent <10
	 
	 gen percent_round = round(percent)
    
   

   * Create the bar graph
   
    graph hbar percent_round, over(other_CCD07, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Problems using Citizen Card-Other") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore		
		
*Other For what reason(s) did you not collect your card?CCD09

    preserve
	
	gen other_CCD09=CCD09oth
	
	
	replace other_CCD09="Participant has reduced mobility" if other_CCD09=="Participante tem mobilidade reduzida e não consegue se deslocar até o local"
	
	replace other_CCD09="No interest in receiving" if other_CCD09=="nao tem interesse de receber"
	
	
	replace other_CCD09="Card was not there when he went" if other_CCD09=="chegou a tentar retirar mas não havia o cartão quando foi ao local"
	
	replace other_CCD09="Card at Banrisul, update pending" if other_CCD09=="Recebeu informação da escola de que tinha direito e que o cartão estava no Banrisul, precisava desbloquear. Ligou para o 0800 e informaram que precisava atualizar cadastro. Não foi feito."
	
	replace other_CCD09="Does not live alone" if other_CCD09=="Não mora sozinha"
	
	replace other_CCD09="Center confirmed no benefit" if other_CCD09=="porque ligou na central e falaram que não tem direito ao beneficio"
	
	replace other_CCD09="Card reading error" if other_CCD09=="Disse que está afastada/enconstada e não tem direito ao benefício"
	
	replace other_CCD09="Participant has reduced mobility" if other_CCD09=="Participante tem mobilidade reduzida e não consegue se deslocar até o local"
	
	replace other_CCD09="Benefit requirements unmet" if other_CCD09=="Considera que não cumpre os requisitos para receber o benefício"
	
     gen total = 1
	 
     collapse (sum) total, by(other_CCD09)

     egen total_sum = total(total) if !missing(other_CCD09)
   
     gen percent = (total / total_sum) * 100  
	 
	 
	

	 * Store total N in a local macro
	  
	 sum total if !missing(other_CCD09), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent <10
	 
	 gen percent_round = round(percent)
    
   

   * Create the bar graph
   
    graph hbar percent_round, over(other_CCD09, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Reasons not collecting the card-Other") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore			
	
	
	
*Other What is the main reason you do not participate in the Nota Fiscal Gaúcha program? NFG02Aaoth 

    preserve
	
	gen other_NFG02Aa=NFG02Aaoth
	
	
	replace other_NFG02Aa="Does not know the program" if other_NFG02Aa=="Não conhece bem o programa Nota Fiscal Gaúcha"
	
	replace other_NFG02Aa="Never tried to register" if other_NFG02Aa=="Nunca tentou se cadastrar"
	
	
	replace other_NFG02Aa="Can't access the application" if other_NFG02Aa=="Não consegue acessar o aplicativo"
	
	*Count occurrences of each category
	
    bysort  other_NFG02Aa (other_NFG02Aa): gen freq = _N

   *Recode categories below the threshold as "Other"
   
    replace other_NFG02Aa = "Other" if freq < 12

    *Drop helper variable
	
      drop freq
	  
     gen total = 1
	 
     collapse (sum) total, by(other_NFG02Aa)

     egen total_sum = total(total) if !missing(other_NFG02Aa)
   
     gen percent = (total / total_sum) * 100  
	 
	 
	

	 * Store total N in a local macro
	  
	 sum total if !missing(other_NFG02Aa), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent <11
	 
	 gen percent_round = round(percent)
    
   

   * Create the bar graph
   
    graph hbar percent_round, over(other_NFG02Aa, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Reasons not participating Nota Fiscal Program-Other") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore		
	
	
	
	
*Other What kind of assistance or help did you receive after the floods? INU04aoth 


    preserve
	
	gen other_INU04a=INU04aoth
	
	
	replace other_INU04a="Government aid" if other_INU04a=="Auxlio do governo"
	
	replace other_INU04a="Building materials" if other_INU04a=="Materiais de construção"
	
	
	replace other_INU04a="Government aid" if other_INU04a=="Auxlio do Governo do Estado"
	
	*Count occurrences of each category
	
    bysort  other_INU04a (other_INU04a): gen freq = _N

   *Recode categories below the threshold as "Other"
   
    replace other_INU04a = "Other" if freq < 3

    *Drop helper variable
	
      drop freq

     gen total = 1
	 
     collapse (sum) total, by(other_INU04a)

     egen total_sum = total(total) if !missing(other_INU04a)
   
     gen percent = (total / total_sum) * 100  
	 
	 
	

	 * Store total N in a local macro
	  
	 sum total if !missing(other_INU04a), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent <10
	 
	 gen percent_round = round(percent)
    
   

   * Create the bar graph
   
    graph hbar percent_round, over(other_INU04a, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Kind of assistance after the floods-Other") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore			
			
	
*-------------------------------------------------------------------------------	
* Part II: Second round of Graphs 
*------------------------------------------------------------------------------- 
  
  *The more a family includes the CPF registered in the program on their purchase invoices, the more money they will be able to receive from the Devolve ICMS Program- by income level
	
	preserve
	
	* Drop observations for plotting
	
    drop if usage_increases==. 
	
	drop if income_div==.

    * Generate total count per group
    gen total = 1
    collapse (sum) total, by(usage_increases income_div)

    * Compute total responses per income group
	
    egen total_sum = total(total), by(income_div)

    * Compute percentage within each income group
	
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Store total N in a local macro
	
    sum total if !missing(usage_increases), meanonly
    local N : display %15.0fc r(sum)


    * Grouped bar chart with correct labels for Yes, No, and Don't Know
	
    graph bar percent_round, over(usage_increases, gap(0)) ///Grouped by Yes, No, Don't Know
        over(income_div) /// Bars for each income category (Less than 600 / More than 600)
        asyvars ///  Ensures different colors for categories
        bar(1, color(navy))  /// Yes - Dark Blue
        bar(2, color(midblue))  /// No - Light Blue
        bar(3, color(ltblue))  /// Don't Know - Green
        blabel(bar, format(%10.0gc) position(outside)) /// Labels percentage on bars
        ytitle("Percentage") ///
        title("Increased Earnings from Devolve ICMS Program with CPF-RI") ///
        note("N=`N'") ///
        legend(order(1 "Yes" 2 "No" 3 "Don't Know")) ///  Corrected legend labels
        ysize(6) xsize(10)

restore

	

*Which of the following payment methods do you use to make purchases on a daily basis?-cash

	preserve 
	
	gen total = 1
	 
     collapse (sum) total, by(payment_method_cash)

     egen total_sum = total(total) if !missing(payment_method_cash)
   
     gen percent = (total / total_sum) * 100  
	

	 * Store total N in a local macro
	  
	 sum total if !missing(payment_method_cash), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent <10
	 
	 gen percent_round = round(percent)
    

   * Create the bar graph
   
    graph hbar percent_round, over(payment_method_cash, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Cash Daily Purchases") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

   restore
	 
	*Did you receive any help (money, materials or otherwise) to recover from the floods?
	
	preserve

    * Count the number of "Yes" (flood_aid == 1) responses per municipality
    contract municipality flood_aid, freq(count)

    * Keep only municipalities where flood aid was received (flood_aid == 1)
    keep if flood_aid == 1

    * Sort by the number of aid recipients in descending order
    gsort -count

    * Select the top 5 municipalities (or top 3, if preferred)
    gen rank = _n
    replace municipality = "Other" if rank > 5  // Change to 3 if you want top 3

    * Aggregate all "Other" municipalities into one group
    collapse (sum) count, by(municipality)

    * Compute total sum to calculate percentages
    egen total_sum = total(count)
    gen percent = (count / total_sum) * 100
    gen percent_round = round(percent)

    * Adjust rounding errors to ensure sum = 100%
    egen sum_round = total(percent_round)
    
    * Find the municipality with the largest percentage
    egen max_percent = max(percent_round)
    
    * Adjust only the category with the largest percent to make total = 100%
    replace percent_round = percent_round + (100 - sum_round) if percent_round == max_percent & sum_round != 100

    * Store total count for display
    sum count, meanonly
    local N : display %15.0fc r(sum)

    * Drop municipalities with very low percentage (optional)
    drop if percent_round < 1

    * Sort municipalities by percentage for correct color assignment
    gsort -percent_round  

    * Generate a numeric ranking for assigning colors
    gen rank_order = _n

    * Generate bar chart with correctly ordered colors
    graph bar percent_round, over(municipality, sort(1)) /// Sorted bars
        asyvars /// Allow different colors
        bar(1, color(navy)) bar(2, color(midblue)) bar(3, color(blue)) ///
        bar(4, color(ltblue)) bar(5, color(cyan)) /// Ensure darker blue for higher percentage
        blabel(bar, format(%10.0gc) position(outside)) /// Label values
        ytitle("Percentage of Aid Received") ///
        title("Top Municipalities Receiving Flood Aid") ///
        note("N=`N'") ///
        ysize(6) xsize(10)

restore


 
 *Which of the following payment methods do you use to make purchases on a daily basis?-cash and per income level
	
	preserve

    * Drop observations for plotting
	
    drop if income_div == .
    
    * Generate total count per group
	
    gen total = 1
    collapse (sum) total, by(payment_method_cash income_div)

    * Compute total responses per income group
	
    egen total_sum = total(total), by(income_div)

    * Compute percentage within each income group
	
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Store total N in a local macro
	
    sum total if !missing(payment_method_cash), meanonly
    local N : display %15.0fc r(sum)

    * Remove very small percentages for cleaner visualization
	
    drop if percent_round < 1

    * Grouped bar chart with correct labels for Yes, No, and Don't Know
	
    graph bar percent_round, over(payment_method_cash, gap(0)) ///Grouped by Yes, No, Don't Know
        over(income_div) /// Bars for each income category (Less than 600 / More than 600)
        asyvars /// Ensures different colors for categories
        bar(1, color(navy))  /// Yes - Dark Blue
        bar(2, color(midblue))  /// No - Light Blue
        bar(3, color(ltblue))  /// Don't Know - Green
        blabel(bar, format(%10.0gc) position(outside)) /// Labels percentage on bars
        ytitle("Percentage") ///
        title("Cash as a Daily Payment Method by Income Level") ///
        note("N=`N'") ///
        legend(order(1 "Yes" 2 "No")) /// Corrected legend labels
        ysize(6) xsize(10)

restore



   
 *Which of the following payment methods do you use to make purchases on a daily basis?-cash density plot
	
	preserve

   * Create a categorical variable for payment method
   gen cash_payment = "Other"
   replace cash_payment = "Cash" if payment_method_cash == 1  // Assuming 1 = Yes, 0 = No

   * Overlay Density Plot for "Cash" vs "Other"
   twoway ///
       (kdensity monthly_purchases if payment_method_cash == 1, color(blue) lwidth(medthick) lpattern(solid)) /// 
       (kdensity monthly_purchases if payment_method_cash == 2, color(red) lwidth(medthick) lpattern(dash)), ///
       legend(order(1 "Cash" 2 "Other")) ///
       title("Monthly Purchases Density by Payment Method") ///
       xtitle("Monthly Purchases") ///
       ytitle("Density") ///
       note("Smoothed density curves for monthly purchases distribution by payment method")

restore


*Which of the following payment methods do you use to make purchases on a daily basis?-cash and devolve beneficiary 
	
	preserve
	
	* Replace "Does not currently participate" category (3) to "No participants" (2) for better grouping
	
	replace participates_devolve = 2 if participates_devolve == 3
	
	*Drop obs for graph 
	
	drop if participates_devolve==666
	
	drop if participates_devolve==.
	
	
	*Change labels for graph 
	
    label define devolve_lbl 1 "Beneficiaries" 2 "Non-Beneficiaries"
    label values participates_devolve devolve_lbl

    * Generate a total count variable
	
    gen total = 1

    * Collapse data by payment method and participation in Devolve
	
    collapse (sum) total, by(participates_devolve payment_method_cash)

    * Compute total responses per participation group
	
    egen total_sum = total(total), by(participates_devolve)

    * Compute percentage within each participation group
	
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Store total N for display
	
    sum total, meanonly
    local N : display %15.0fc r(sum)

    * Drop small percentage groups (optional)
	
    drop if percent_round < 1

    * Grouped bar chart: X-axis = Beneficiaries vs. Non-Beneficiaries, Three bars per group
	
    graph bar percent_round, over(payment_method_cash, gap(0)) /// X-axis: Beneficiaries & Non-Beneficiaries
    over(participates_devolve) /// Three bars per group: Yes, No, Don't Know
    asyvars /// Ensures different colors for groups
    bar(1, color(navy))  /// Yes - Dark Blue
    bar(2, color(midblue))  /// No - Light Blue
    blabel(bar, format(%10.0gc) position(outside)) /// Labels percentage on bars
    ytitle("Percentage") ///
    title("Cash as a Daily Payment Method by Devolve Participation") ///
    note("N=`N'") ///
    legend(order(1 "Yes" 2 "No")) /// Corrected legend labels
    ysize(6) xsize(10)


restore



**Purchases you made last week and payment methods
	
	preserve

    * Keep only observations where respondents pay less than half and none or almost none
	
    keep if purchases_last_week > 3
	
	drop if purchases_last_week==666
	
	*Payment methods

    gen cash_yes = payment_method_cash == 1
    gen debit_yes = payment_method_debit == 1
    gen credit_yes = payment_method_credit == 1
	gen pix_yes = payment_method_pix == 1
	gen mobile_yes = payment_method_mobile == 1
	
	egen total_obs_cash = count(payment_method_cash)
	egen total_obs_debit = count(payment_method_debit)
	egen total_obs_credit = count(payment_method_credit)
	egen total_obs_pix = count(payment_method_pix)
	egen total_obs_mobile = count(payment_method_mobile)

  
    egen cash_yes_total = total(cash_yes)
    egen debit_yes_total = total(debit_yes)
    egen credit_yes_total = total(credit_yes)
	egen pix_yes_total = total(pix_yes)
	egen mobile_yes_total = total(mobile_yes)

    gen cash_pct = (cash_yes_total / total_obs_cash) * 100
    gen debit_pct = (debit_yes_total / total_obs_debit) * 100
	gen credit_pct = (credit_yes_total / total_obs_credit) * 100
    gen pix_pct = (pix_yes_total / total_obs_pix) * 100
	gen mobile_pct = (mobile_yes_total / total_obs_mobile) * 100


    gen variable = "Cash" in 1
    replace cash_pct = debit_pct in 2
    replace variable = "Debit" in 2
    replace cash_pct = credit_pct in 3
    replace variable = "Credit" in 3
	replace cash_pct = pix_pct in 4
    replace variable = "Pix" in 4
	replace cash_pct = mobile_pct in 5
    replace variable = "Mobile" in 5
	
    keep if _n <= 5
    rename cash_pct percent
	
	 * Store total N in a local macro directly from total_obs
	 
     local N = total_obs_cash[1]
	
	
	gen percent_round = round(percent)
	
	 drop if percent_round<1
	 
	
	*Graph 
	
	graph hbar percent_round, over(variable, sort(percent_round) descending) ///
    bar(1, color(navy)) ///
    bar(2, color(blue)) ///
    blabel(bar, format(%10.0gc) position(outside)) ///
    ytitle("Percentage") ///
    title("Daily Payment Methods Used for Purchases") ///
    note("N=`N'") ///
    ysize(6) xsize(10)

	

restore


**Purchases you made last week and payment methods
	
	preserve

    * Keep only observations where respondents pay less than half and none or almost none
	
    drop if purchases_last_week==3
	
	drop if purchases_last_week==666
	
	 * Generate a total count variable
    gen total = 1

    * Collapse data by payment method and participation
    collapse (sum) total, by(purchases_last_week)

    * Compute total sum to calculate percentages
    egen total_sum = total(total)
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Store total N for display
    sum total, meanonly
    local N : display %15.0fc r(sum)
	
	
	 gen purchases_label = string(purchases_last_week)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if purchases_label == "All or almost all"
    replace order = 2 if purchases_label == "More than half"
    replace order = 3 if purchases_label == "Less than half"
    replace order = 4 if purchases_label == "None or almost none"


   * Ensure the order is correctly applied
    gsort order
	
	
	*Graph 
	
	graph hbar percent_round, over(purchases_last_week, sort(order)) ///
    bar(1, color(navy)) ///
    bar(2, color(blue)) ///
    blabel(bar, format(%10.0gc) position(outside)) ///
    ytitle("Percentage") ///
    title("Puchases with cash last week") ///
    note("N=`N'") ///
    ysize(6) xsize(10)

	

restore


*Does having a bank account affect how much is paid in cash?
	
	preserve

    * Keep only relevant observations
    keep if hh_bank_account == 4
	
    * Generate a total count variable
    gen total = 1

    * Collapse data by payment method and participation
    collapse (sum) total, by(purchases_last_week)

    * Compute total sum to calculate percentages
    egen total_sum = total(total)
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Adjust rounding errors to ensure sum = 100%
    egen sum_round = total(percent_round)
    
    * Find the category with the largest percentage
    egen max_percent = max(percent_round)
    
    * Adjust only the largest category to make total = 100%
    replace percent_round = percent_round + (100 - sum_round) if percent_round == max_percent & sum_round != 100

    * Store total N for display
    sum total, meanonly
    local N : display %15.0fc r(sum)

    * Assign readable labels for purchases_last_week
    gen purchases_label = string(purchases_last_week)
   
    * Assign a numeric order to categories
    gen order = .
    replace order = 1 if purchases_label == "All or almost all"
    replace order = 2 if purchases_label == "More than half"
    replace order = 3 if purchases_label == "Half"
    replace order = 4 if purchases_label == "Less than half"
    replace order = 5 if purchases_label == "None or almost none"

    * Ensure the order is correctly applied
    gsort order

    * Graph 
    graph hbar percent_round, over(purchases_last_week, sort(order)) ///
        bar(1, color(navy)) ///
        bar(2, color(blue)) ///
        blabel(bar, format(%10.0gc) position(outside)) ///
        ytitle("Percentage") ///
        title("Purchases with Cash Last Week") ///
        note("N=`N'") ///
        ysize(6) xsize(10)

restore

  
 * If a person or someone in their family has a bank account, create a bar plot with two bars, crossed with PAG01.
	
	
preserve


    * Recode bank account ownership: 1 = Has Account, 0 = No Account
	
	drop if hh_bank_account == 666
    recode hh_bank_account (2/3=1) (else=0)


    * Create indicator variables for each payment method
	
    gen cash = payment_method_cash == 1
    gen debit = payment_method_debit == 1
    gen credit = payment_method_credit == 1
    gen pix = payment_method_pix == 1
    gen mobile = payment_method_mobile == 1

    collapse (sum) cash debit credit pix mobile, by(hh_bank_account)

	gen payment_method = ""
stack cash debit credit pix mobile, into(payment_value) wide
	

    * Label payment methods correctly
	
   gen payment_method = ""
replace payment_method = "Cash" if _stack == 1
replace payment_method = "Debit" if _stack == 2
replace payment_method = "Credit" if _stack == 3
replace payment_method = "Pix" if _stack == 4
replace payment_method = "Mobile" if _stack == 5

replace hh_bank_account = "No Bank Account" if hh_bank_account == "0"
replace hh_bank_account = "Has Bank Account" if hh_bank_account == "Yes, you have"    

   graph bar (sum) payment_value, over(payment_value, label(angle(45))) over(payment_method) stack ///
    asyvars bar(1, color(navy)) bar(2, color(blue*0.8)) /// 
    blabel(bar, format(%10.1f) position(outside)) /// 
    ytitle("Number of Users") title("Payment Methods by Bank Account Ownership") ///
    legend(order(1 "No Bank Account" 2 "Has Bank Account")) ///
    ysize(6) xsize(10)

restore



 * If a person or someone in their family has a bank account by gender 
 
   preserve

    * Keep individuals who either have a bank account (1) or do not have one (4)
	
    keep if hh_bank_account == 1 | hh_bank_account == 4

    * Generate a total count variable
	
    gen total = 1

    * Collapse data by gender and bank account ownership status
	
    collapse (sum) total, by(gender hh_bank_account)
	

    * Compute total sum to calculate percentages within each gender group
	
    egen total_sum = total(total), by(gender)
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Store total N for display
	
    sum total, meanonly
    local N : display %15.0fc r(sum)

    * Grouped bar graph: Gender on X-axis, Two Bars per Group (Has vs. No Bank Account)
    graph bar percent_round, over(hh_bank_account) /// Two bars per group: Has vs. No Bank Account
        over(gender, gap(50)) ///X-axis: Gender (Female, Male)
        asyvars /// Ensures different colors for groups
        bar(1, color(navy))  /// Has a Bank Account - Dark Blue
        bar(2, color(midblue))  /// No Bank Account - Light Blue
        blabel(bar, format(%10.0gc) position(outside)) /// Labels percentage on bars
        ytitle("Percentage") ///
        title("Bank Account Ownership by Gender") ///
        note("N=`N'") ///
        legend(order(1 "Has a Bank Account" 2 "No Bank Account")) /// Corrected legend labels
        ysize(6) xsize(10)

restore


	
*What is the main use of your ICMS Return Citizen Card?-Other category 

preserve
	
	gen other_CCD05=CCD05oth
	
	
	replace other_CCD05="Food and hygiene products" if other_CCD05=="Alimentos;Produtos de higiene" 
	
	replace other_CCD05="Food and Meds" if other_CCD05=="Remédios;Alimentos"
	
	
	replace other_CCD05="Gas" if other_CCD05=="Gás"
	
	*Count occurrences of each category
	
    bysort  other_CCD05 (other_CCD05): gen freq = _N

   *Recode categories below the threshold as "Other"
   
    replace other_CCD05 = "Other" if freq < 3

    *Drop helper variable
	
      drop freq

     gen total = 1
	 
     collapse (sum) total, by(other_CCD05)

     egen total_sum = total(total) if !missing(other_CCD05)
   
     gen percent = (total / total_sum) * 100  
	 
	 

	 * Store total N in a local macro
	  
	 sum total if !missing(other_CCD05), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent <10
	 
	 gen percent_round = round(percent)
    

   * Create the bar graph
   
    graph hbar percent_round, over(other_CCD05, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Main use of your ICMS Return Citizen Card-Other") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore			
			
*Among people currently in the program, what percentage is experiencing issues with the card?

  preserve

    * Keep only beneficiaries and non-participants
	
    keep if participates_devolve == 1 
	
	*Drop observations for plotting
	
	drop if problem_card==.

    * Generate a total count variable
	
    gen total = 1

    * Collapse data by problem type and participation status
	
    collapse (sum) total, by(problem_card)

    * Compute total sum to calculate percentages within each group
	
    egen total_sum = total(total)
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Store total N for display
	
    sum total, meanonly
    local N : display %15.0fc r(sum)

    * Drop small percentage groups (optional)
	
    drop if percent_round < 1

    * Grouped bar chart
	 graph hbar percent_round, over(problem_card, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Issues with Using the Devolve-ICMS Citizen Card") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed

restore



	
*What problems did you encounter when using your Citizen Card?-beneficiaries

  preserve
	
   * Keep only observations where participates_devolve == 1
    keep if participates_devolve == 1

     gen store_yes = problem_card_na == 1
     gen transfer_yes = problem_card_transfer == 1
     gen money_yes = problem_card_money == 1
     gen password_yes = problem_card_password == 1
     gen other_yes = problem_card_other == 1



    egen store_yes_total = total(store_yes)
    egen transfer_yes_total = total(transfer_yes)
    egen money_yes_total = total(money_yes)
    egen password_yes_total = total(password_yes)
    egen other_yes_total = total(other_yes)


   * Calculate percentages

    egen total_obs = count(problem_card_na) // Total observations 
    gen store_pct = (store_yes_total / total_obs) * 100
    gen transfer_pct = (transfer_yes_total / total_obs) * 100
    gen money_pct = (money_yes_total / total_obs) * 100
    gen password_pct = (password_yes_total / total_obs) * 100
    gen other_pct = (other_yes_total / total_obs) * 100


    gen variable = "Not accepted at the store" in 1
    replace store_pct = transfer_pct in 2
    replace variable = "Delayed or missing transfers" in 2
    replace store_pct = money_pct in 3
    replace variable = "Don't know card balance" in 3
	replace store_pct = password_pct in 4
    replace variable = "Don't know the PIN" in 4
	replace store_pct = other_pct in 5
    replace variable = "Other" in 5
	
	 * Store total N in a local macro directly from total_obs
     local N = total_obs[1]
	 
	
     keep if _n <= 5
    rename store_pct percent
	
	
	gen percent_round = round(percent)
   
   * Create the bar graph
   
    graph hbar percent_round, over(variable, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(midblue)) /// 
    title("Types of problems in Devolve card among beneficiaries") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore			
	
	
	
*What banks or financial institutions do you and other family members living with you have accounts at?-by income and consumption level 

   preserve
	
    * Create income categories (modify as needed)
egen income_group = cut(monthly_purchases), group(4) label

* Generate the bar chart
graph bar (percent) monthly_purchases, over(hh_bank_account) ///
    asyvars bar(1, color(navy)) bar(2, color(blue)) ///
    blabel(bar, format(%10.0gc) position(outside)) ///
    ytitle("Percentage") title("Monthly Purchases Distribution by Bank Account Ownership") ///
    legend(order(1 "No Bank Account" 2 "Has Bank Account")) ///
    note("N=`=_N'") ysize(6) xsize(10)

	* Generate a density plot for income by bank account ownership
twoway (kdensity monthly_purchases if hh_bank_account == 1, color(blue) lpattern(solid)) ///
       (kdensity monthly_purchases if hh_bank_account == 4, color(red) lpattern(dash)), ///
       legend(order(1 "Has Bank Account" 2 "No Bank Account")) ///
       title("Monthly Purchases Distribution by Bank Account Ownership") ///
       xtitle("Monthly Purchases") ytitle("Density") ///
       

	restore			
	
*DEV03: Why does this money go into the participants' accounts?- for devolve participants

	preserve
	
   * Keep only observations where participates_devolve == 1
   
    keep if participates_devolve == 1
	
	*Frequency table 
   
    asdoc tab reason_money_accounts, title(Reasons money goes into accounts) save(Reasons_Money_goes_into_accounts_DevolveParticipants.doc)

   

    * Generate a total count variable
    gen total = 1

    * Collapse data by payment method and participation
	
    collapse (sum) total, by(reason_money_accounts)

    * Compute total sum to calculate percentages
    egen total_sum = total(total)
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Store total N for display
    sum total, meanonly
    local N : display %15.0fc r(sum)

    * Drop municipalities with very low percentage (optional)
	
    drop if percent_round < 1
	

   * Create the bar graph
   
    graph hbar percent_round, over(reason_money_accounts, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(midblue)) /// 
    title("Reasons money goes into accounts") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore			

	
*DEV03: Why does this money go into the participants' accounts?- for NFG participants

	preserve
	
   * Keep only observations where participate_nfg == 1
    keep if participate_nfg == 1

    * Generate a total count variable
    gen total = 1

    * Collapse data by payment method and participation
    collapse (sum) total, by(reason_money_accounts)

    * Compute total sum to calculate percentages
    egen total_sum = total(total)
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Store total N for display
    sum total, meanonly
    local N : display %15.0fc r(sum)

    * Drop municipalities with very low percentage (optional)
    drop if percent_round < 1
   

   * Create the bar graph
   
    graph hbar percent_round, over(reason_money_accounts, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(midblue)) /// 
    title("Reasons money goes into accounts-NGF participants") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed

	restore			
	

		
*DEV07: The more a family includes the CPF registered in the program on their purchase invoices, the more money they will be able to receive from the Devolve ICMS Program.	NFG participants

  preserve
	
    * Keep only observations where participate_nfg == 1
    keep if participate_nfg == 1

    * Generate a total count variable
    gen total = 1

    * Collapse data by payment method and participation
    collapse (sum) total, by(usage_increases)

    * Compute total sum to calculate percentages
    egen total_sum = total(total)
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Store total N for display
    sum total, meanonly
    local N : display %15.0fc r(sum)

    * Drop municipalities with very low percentage (optional)
    drop if percent_round < 1
   

   * Create the bar graph
   
    graph hbar percent_round, over(usage_increases, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("CPF Inclusion Increases Devolve ICMS Benefits") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(10)  // Adjust size as needed


	restore			
	
*PAG03: Do you or other family members who live with you have an account at a bank or financial institution?- income level 

preserve

    drop if income_div == .

    gen total = 1
    collapse (sum) total, by(hh_bank_account income_div)

    egen total_sum = total(total), by(income_div)  
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Adjust rounding errors to ensure sum = 100%
	
    egen sum_round = total(percent_round), by(income_div)
    replace percent_round = percent_round + (100 - sum_round) if _n == 1 & sum_round != 100

    * Store total N in a local macro
	
    sum total if !missing(hh_bank_account), meanonly
    local N : display %15.0fc r(sum)

    drop if percent_round < 1

    * Grouped bar chart with two bars per category
	
    graph bar percent_round, over(hh_bank_account, gap(0)) ///Grouped by Yes, No, Don't Know
        over(income_div) /// Bars for each income category (Less than 600 / More than 600)
        asyvars /// 
        bar(1, color(navy))  /// 
        bar(2, color(midblue))  /// 
        bar(3, color(ltblue))  /// 
        bar(4, color(eltblue)) ///
        blabel(bar, format(%10.0gc) position(outside)) /// Labels percentage on bars
        ytitle("Percentage") ///
        title("Bank Account Ownership by Income Level") ///
        note("N=`N'") ///
        legend(order(1 "Yes" 2 "Yes, other person have" 3 "Yes, you and a family member" 4 "No" 5 "Don't Know")) ///
        ysize(6) xsize(10)

restore

  
 *PAG03: Do you or other family members who live with you have an account at a bank or financial institution?- age

preserve

    gen total = 1
    collapse (sum) total, by(hh_bank_account age_div)

    egen total_sum = total(total), by(age_div)  
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)
    
    * Adjust rounding errors to ensure sum = 100%
	
    egen sum_round = total(percent_round), by(age_div)
    
    * Find the category with the largest percentage to adjust
	
    egen max_percent = max(percent_round), by(age_div)
    
    * Adjust only the category with the largest percent so the sum equals 100
	
    replace percent_round = percent_round + (100 - sum_round) if percent_round == max_percent & sum_round != 100

    * Store total N in a local macro
	
    sum total if !missing(hh_bank_account), meanonly
    local N : display %15.0fc r(sum)

    drop if percent_round < 1

    * Grouped bar chart with two bars per category
    graph bar percent_round, over(hh_bank_account, gap(0)) ///Grouped by Yes, No, Don't Know
        over(age_div) /// Bars for each age category (Less than 45 / More than 45)
        asyvars /// Ensures different colors for categories
        bar(1, color(navy))  /// Darkest blue
        bar(2, color(midblue)) /// Medium blue
        bar(3, color(ltblue))  /// Light blue
        bar(4, color(eltblue)) /// Extra light blue
        blabel(bar, format(%10.0gc) position(outside)) /// Labels percentage on bars
        ytitle("Percentage") ///
        title("Bank Account Ownership by Age Group") ///
        note("N=`N'") ///
        legend(order(1 "Yes" 2 "Yes, other person have" 3 "Yes, you and a family member" 4 "No")) /// Corrected legend labels
        ysize(6) xsize(10)

restore

	
  
	
*NFI01a: Please indicate the main reason why you choose to shop there instead of going to stores that issue receipts? age 

preserve

    drop if reason_no_receipt == .

    gen total = 1
    collapse (sum) total, by(reason_no_receipt age_div)

    egen total_sum = total(total), by(age_div)  
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Adjust rounding errors to ensure sum = 100%
	
    egen sum_round = total(percent_round), by(age_div)
    
    * Find the category with the largest percentage to adjust
	
    egen max_percent = max(percent_round), by(age_div)
    
    * Adjust only the category with the largest percent so the sum equals 100
	
    replace percent_round = percent_round + (100 - sum_round) if percent_round == max_percent & sum_round != 100

    * Store total N in a local macro
	
    sum total if !missing(reason_no_receipt), meanonly
    local N : display %15.0fc r(sum)

    * Grouped bar chart with two bars per category
	
    graph bar percent_round, over(reason_no_receipt, gap(0)) /// Grouped by reason
        over(age_div) /// Bars for each age category
        asyvars ascategory /// Ensures distinct colors for each category
        bar(1, color(navy))       /// Darkest blue  
        bar(2, color(royalblue))  /// Medium-dark blue  
        bar(3, color(dodgerblue)) /// Bright medium blue  
        bar(4, color(ltblue))     /// Light blue  
        bar(5, color(skyblue))    /// Softer light blue  
        bar(6, color(steelblue))  /// Grayish blue  
        blabel(bar, format(%10.0gc) position(outside)) /// Labels percentage on bars
        ytitle("Percentage") ///
        title("Reasons for Choosing Non-Receipt Stores by Age Group") ///
        note("N=`N'") ///
        legend(order(1 "Not ask for invoices" 2 "Stores are cheaper" 3 "Distance" 4 "Access" 5 "Other" 6 "Don't Know")) /// Legend labels
        ysize(6) xsize(10)

restore

	
*NFI04b: And when the attendant DOES NOT ask you if you want to include your CPF on the purchase invoice, how often do you ask to include your CPF on the invoice? by age group	

preserve
    
    gen total = 1
    collapse (sum) total, by(freq_cpf_na age_div)
	
    * Compute total observations per age group
    egen total_sum = total(total), by(age_div)  

    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Adjust rounding errors to ensure sum = 100%
    egen sum_round = total(percent_round), by(age_div)
    
    * Find the category with the largest percentage in each age group
    egen max_percent = max(percent_round), by(age_div)
    
    * Adjust only the category with the largest percent to make total = 100%
    replace percent_round = percent_round + (100 - sum_round) if percent_round == max_percent & sum_round != 100

    * Store total N in a local macro
    sum total if !missing(freq_cpf_na), meanonly
    local N : display %15.0fc r(sum)

    drop if percent_round < 1

    * Grouped bar chart with two bars per category 
    graph bar percent_round, over(freq_cpf_na, gap(0)) /// Rotate x-axis labels
        over(age_div, gap(50)) /// Grouped by Age
        asyvars /// Ensures different colors for groups
        bar(1, color(navy))  /// Always - Extra Light Blue
        bar(2, color(midblue))   /// Sometimes - Light Blue
        bar(3, color(ltblue))  /// Rarely - Medium Blue
        bar(4, color(eltblue))     /// Never - Dark Blue
        blabel(bar, format(%10.0gc) position(outside)) /// Label values above bars
        ytitle("Percentage") ///
        title("Frequency of Requesting CPF Inclusion When Not Asked, by Age Group") ///
        note("N=`N'") ///
        legend(order(1 "Always" 2 "Sometimes" 3 "Rarely" 4 "Never" 5 "Don't know")) ///
        ysize(6) xsize(12)

restore

   
   
*IET02: The government should collect more taxes from rich people and give more money to poor people. participants devolve   

preserve
	
   * Keep only observations where participates_devolve == 1
    keep if participates_devolve == 1

    * Generate a total count variable
    gen total = 1

    * Collapse data by payment method and participation
    collapse (sum) total, by(tax_collection)

    * Compute total sum to calculate percentages
    egen total_sum = total(total)
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Store total N for display
    sum total, meanonly
    local N : display %15.0fc r(sum)

    * Drop municipalities with very low percentage (optional)
    drop if percent_round < 1
   
 gen tax_label = string(tax_collection)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if tax_label == "Strongly Agree"
    replace order = 2 if tax_label == "Agree"
	replace order = 3 if tax_label == "Disagree"
    replace order = 4 if tax_label == "Strongly Disagree"
    replace order = 5 if tax_label == "Don't know"


   * Ensure the order is correctly applied
    gsort order
   
   
   * Create the bar graph
   
    graph hbar percent_round, over(tax_collection, sort(order)) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Support for Progressive Taxation Among Devolve Participants") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(15)  // Adjust size as needed

	restore			
	

*IET04: :We should pay less tax on essential goods like food compared to other products we buy- devolve participants

   preserve
	
   * Keep only observations where participates_devolve == 1
    keep if participates_devolve == 1

    * Generate a total count variable
    gen total = 1

    * Collapse data by payment method and participation
    collapse (sum) total, by(tax_essential_goods)

    * Compute total sum to calculate percentages
    egen total_sum = total(total)
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Store total N for display
    sum total, meanonly
    local N : display %15.0fc r(sum)

    * Drop municipalities with very low percentage (optional)
    drop if percent_round < 1
   
 gen tax_label = string(tax_essential_goods)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if tax_label == "Strongly Agree"
    replace order = 2 if tax_label == "Agree"
	replace order = 3 if tax_label == "Disagree"
    replace order = 4 if tax_label == "Strongly Disagree"
    replace order = 5 if tax_label == "Don't know"


   * Ensure the order is correctly applied
    gsort order
   
   
   * Create the bar graph
   
    graph hbar percent_round, over(tax_essential_goods, sort(order)) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Support for Lower Taxes on Essentials-Devolve Participants") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(15)  // Adjust size as needed

	restore			

*IET05a: How much is the ICMS charged on most of the things we buy in Rio Grande do Sul?  devolve participants


  preserve
	
   * Keep only observations where participates_devolve == 1
   
   drop if icms_rate_rgs==.
   
    keep if participates_devolve == 1
	
	

    * Generate a total count variable
    gen total = 1

    * Collapse data by payment method and participation
    collapse (sum) total, by(icms_rate_rgs)

    * Compute total sum to calculate percentages
    egen total_sum = total(total)
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Store total N for display
    sum total, meanonly
    local N : display %15.0fc r(sum)

    * Drop municipalities with very low percentage (optional)
    drop if percent_round < 1
   
 gen tax_label = string(icms_rate_rgs)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if tax_label == "Less than 5%"
    replace order = 2 if tax_label == "Between 5-10%"
	replace order = 3 if tax_label == "Between 10-20%"
    replace order = 4 if tax_label == "Between 20-30%"
    replace order = 5 if tax_label == "Between 30-40%"
	replace order = 6 if tax_label == "More than 40%"
	replace order = 7 if tax_label == "Don't know"


   * Ensure the order is correctly applied
    gsort order
   
   
   * Create the bar graph
   
    graph hbar percent_round, over(icms_rate_rgs, sort(order)) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Awareness of ICMS Rates –Devolve Participants") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(15)  // Adjust size as needed

	restore			

*IET07: Are you in favor of the government increasing the tax on food so that it is the same as on other products? That is, that all products have the same tax, even if it means spending more when buying food.- devolve participants

   preserve
	
   * Keep only observations where participates_devolve == 1
    keep if participates_devolve == 1

    * Generate a total count variable
    gen total = 1

    * Collapse data by payment method and participation
    collapse (sum) total, by(increase_tax_on_food)

    * Compute total sum to calculate percentages
    egen total_sum = total(total)
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Store total N for display
    sum total, meanonly
    local N : display %15.0fc r(sum)

    * Drop municipalities with very low percentage (optional)
    drop if percent_round < 1
   
 gen tax_label = string(increase_tax_on_food)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if tax_label == "Totally in favor"
    replace order = 2 if tax_label == "Favor"
	replace order = 3 if tax_label == "Against"
    replace order = 4 if tax_label == "Totally against"
    replace order = 5 if tax_label == "Don't know"


   * Ensure the order is correctly applied
    gsort order
   
   
   * Create the bar graph
   
    graph hbar percent_round, over(increase_tax_on_food, sort(order)) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Support for Equal Food Tax – Devolve Participants") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(15)  // Adjust size as needed

	restore			

	
*IET08: Are you in favor of the government increasing the tax on food so that it is equal to that on other products, only if participants in the Devolve program receive it back? devolve participants
	 preserve
	
   * Keep only observations where participates_devolve == 1
    keep if participates_devolve == 1

    * Generate a total count variable
    gen total = 1

    * Collapse data by payment method and participation
    collapse (sum) total, by(tax_on_foodreturned)

    * Compute total sum to calculate percentages
    egen total_sum = total(total)
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Store total N for display
    sum total, meanonly
    local N : display %15.0fc r(sum)

    * Drop municipalities with very low percentage (optional)
    drop if percent_round < 1
   
 gen tax_label = string(tax_on_foodreturned)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if tax_label == "Totally in favor"
    replace order = 2 if tax_label == "Favor"
	replace order = 3 if tax_label == "Against"
    replace order = 4 if tax_label == "Totally against"
    replace order = 5 if tax_label == "Don't know"


   * Ensure the order is correctly applied
    gsort order
   
   
   * Create the bar graph
   
    graph hbar percent_round, over(tax_on_foodreturned, sort(order)) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Support for Higher Food Tax with Devolve Reimbursement") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(15)  // Adjust size as needed

	restore		
	
	
*IET09: Are you in favor of the government increasing the tax on food so that it is equal to that on other products, only if all residents of Rio Grande do Sul receive back the amount paid in tax? devolve participants	

 preserve
	
   * Keep only observations where participates_devolve == 1
    keep if participates_devolve == 1

    * Generate a total count variable
    gen total = 1

    * Collapse data by payment method and participation
    collapse (sum) total, by(tax_food_all)

    * Compute total sum to calculate percentages
    egen total_sum = total(total)
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Store total N for display
    sum total, meanonly
    local N : display %15.0fc r(sum)

    * Drop municipalities with very low percentage (optional)
    drop if percent_round < 1
   
 gen tax_label = string(tax_food_all)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if tax_label == "Totally in favor"
    replace order = 2 if tax_label == "Favor"
	replace order = 3 if tax_label == "Against"
    replace order = 4 if tax_label == "Totally against"
    replace order = 5 if tax_label == "Don't know"


   * Ensure the order is correctly applied
    gsort order
   
   
   * Create the bar graph
   
    graph hbar percent_round, over(tax_food_all, sort(order)) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Support for Higher Food Tax with Universal Reimbursement") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(15)  // Adjust size as needed

	restore		

	
*IET10: Are you in favor of the government reducing the tax on perfumes and makeup so that it is the same as on other products? devolve participants
   
   preserve
	
   * Keep only observations where participates_devolve == 1
    keep if participates_devolve == 1

    * Generate a total count variable
    gen total = 1

    * Collapse data by payment method and participation
    collapse (sum) total, by(tax_perfumes_makeup)

    * Compute total sum to calculate percentages
    egen total_sum = total(total)
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Store total N for display
    sum total, meanonly
    local N : display %15.0fc r(sum)

    * Drop municipalities with very low percentage (optional)
    drop if percent_round < 1
   
 gen tax_label = string(tax_perfumes_makeup)
   
   * Assign a numeric order to categories
    gen order = .
    replace order = 1 if tax_label == "Totally in favor"
    replace order = 2 if tax_label == "Favor"
	replace order = 3 if tax_label == "Against"
    replace order = 4 if tax_label == "Totally against"
    replace order = 5 if tax_label == "Don't know"


   * Ensure the order is correctly applied
    gsort order
   
   
   * Create the bar graph
   
    graph hbar percent_round, over(tax_perfumes_makeup, sort(order)) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Support for Lower Beauty Product Tax – Devolve Participants") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N = `N'")  //
	ysize(6) xsize(15)  // Adjust size as needed

	restore		

*When the attendant asks you if you want to include your CPF on the purchase invoice, how often do you usually include your CPF on the invoice?(NFI04a) by income level 

preserve
	
    * Remove missing values
	
    drop if income_div == .
    drop if cpf_invoice_freq == .

    * Generate total count per group
	
    gen total = 1
    collapse (sum) total, by(cpf_invoice_freq income_div)

    * Compute total responses per income group
	
    egen total_sum = total(total), by(income_div)

    * Compute percentage within each income group
	
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Adjust rounding errors to ensure sum = 100%
	
    egen sum_round = total(percent_round), by(income_div)
    
    * Find the category with the largest percentage in each group
	
    egen max_percent = max(percent_round), by(income_div)
    
    * Adjust only the category with the largest percent
	
    replace percent_round = percent_round + (100 - sum_round) if percent_round == max_percent & sum_round != 100

    * Store total N in a local macro
	
    sum total if !missing(cpf_invoice_freq), meanonly
    local N : display %15.0fc r(sum)

    * Grouped bar chart with correct labels for Yes, No, and Don't Know
    graph bar percent_round, over(cpf_invoice_freq, gap(0)) ///Grouped by Yes, No, Don't Know
        over(income_div) /// Bars for each income category (Less than 600 / More than 600)
        asyvars /// Ensures different colors for categories
        bar(1, color(navy))  /// 
        bar(2, color(midblue))  /// 
        bar(3, color(ltblue))  /// 
        blabel(bar, format(%10.0gc) position(outside)) /// Labels percentage on bars
        ytitle("Percentage") ///
        title("Frequency of CPF Inclusion on Purchase Invoices by Income Level") ///
        note("N=`N'") ///
        legend(order(1 "Always" 2 "Sometimes" 3 "Rarely" 4 "Never")) /// Corrected legend labels
        ysize(6) xsize(10)

restore

*When the attendant asks you if you want to include your CPF on the purchase invoice, how often do you usually include your CPF on the invoice?(NFI04a) by for people that use cash as a payment_method

 preserve

    * Drop observations for plotting 
	
	drop if cpf_invoice_freq== .

    * Generate total count per group
    gen total = 1
    collapse (sum) total, by(cpf_invoice_freq payment_method_cash)

    * Compute total responses
    egen total_sum = total(total), by(payment_method_cash)

    * Compute percentage
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Store total N in a local macro
    sum total if !missing(cpf_invoice_freq), meanonly
    local N : display %15.0fc r(sum)

    * Define and apply labels for Cash Users and Non-Cash Users
    label define payment_lbl 1 "Cash Users" 2 "Non-Cash Users"
    label values payment_method_cash payment_lbl

    * Grouped bar chart with correct labels
    graph bar percent_round, over(cpf_invoice_freq, gap(0)) /// Grouped by Yes, No, Don't Know
        over(payment_method_cash, label(angle(0))) /// Bars for Cash vs. Non-Cash Users
        asyvars /// Ensures different colors for categories
        bar(1, color(navy)) /// 
        bar(2, color(midblue))  ///
        bar(3, color(ltblue))  ///
        blabel(bar, format(%10.0gc) position(outside)) /// Labels percentage on bars
        ytitle("Percentage") ///
        title("Frequency of CPF Inclusion on Purchase Invoices Among Cash Users") ///
        note("N=`N'") ///
        legend(order(1 "Always" 2 "Sometimes" 3 "Rarely" 4 "Never")) /// Corrected legend labels
        ysize(6) xsize(10)

restore


*See the amount of the observations for the income variable DEM04

preserve

   tab income
   
   asdoc tab income, replace title(Income Distribution Table)
   

restore


*Distribution table for income, Devolve beneficiaries and NFG beneficiaries

preserve

  
  asdoc tab income participates_devolve, row replace title(Income Distribution by Devolve Beneficiaries) save(Income_Distribution_Devolve.doc)
  
asdoc tab income participate_nfg, row append title(Income Distribution by NFG Beneficiaries) save(Income_Distribution_NFG.doc)



restore

*Figure income level PAG03a is consistent with the Caixa, Bolsa familia participants should have a bank account, lower income level. 

preserve


   drop if income_div==. 
   
   drop if bank_account_caixa==.
   
    * Compute total count per category
	
    gen total = 1

    * Collapse to sum total observations within each group
	
    collapse (sum) total, by(bank_account_caixa income_div)

    * Compute total observations per income group
	
    egen total_sum = total(total), by(income_div)  

    * Calculate percentage within each income group
	
    gen percent = (total / total_sum) * 100  
    gen percent_round = round(percent)

    * Store total N in a local macro
	
    sum total if !missing(bank_account_caixa), meanonly
    local N : display %15.0fc r(sum)

    * Drop very small percentages to clean up the graph
	
    drop if percent_round < 1
	
    * FINAL GRAPH FIX: Ensuring percentages sum to 100% within income groups
    graph bar percent_round, over(bank_account_caixa) /// Two bars per income group (Yes, No)
        over(income_div, gap(50) label(angle(0))) /// ✅ X-axis: Income Level
        asyvars /// Ensures different colors for groups
        bar(1, color(navy))  /// Yes (Has Caixa Account) - Dark Blue
        bar(2, color(blue))  /// No (Does not have Caixa Account) - Light Blue
        blabel(bar, format(%10.0gc) position(outside)) /// Labels percentage on bars
        ytitle("Percentage within Each Income Group") ///
        title("Caixa Bank Account Ownership by Income Level") ///
        note("N=`N'") ///
        legend(order(1 "Yes" 2 "No")) /// Ensures correct legend labels
        ysize(6) xsize(10)

restore

 


*Have you ever had any problems when trying to use your Citizen Card from the Devolve-ICMS program? does not currently participate 

preserve
	
	 keep if participates_devolve==3

     gen total = 1
	 
     collapse (sum) total, by(problem_card)

     egen total_sum = total(total) if !missing(problem_card)
   
     gen percent = (total / total_sum) * 100  
	
	 gen percent_round = round(percent)
	 
	 * Store total N in a local macro
	  
	 sum total if !missing(problem_card), meanonly
     local N : display %15.0fc r(sum)
	 
	 drop if percent_round<1
   

   * Create the bar graph
   
    graph hbar percent_round, over(problem_card, sort(percent_round) descending) /// 
    bar(1, color(navy)) bar(2, color(blue)) /// 
    title("Issues with Using the Devolve-ICMS Citizen Card") /// 
    ytitle("Percent") /// 
    blabel(bar) /// 
    note("N=`N'") ///
	ysize(6) xsize(10)  // Adjust size as needed

	
	restore
	
*-------------------------------------------------------------------------------	
* Graphs Part III
*------------------------------------------------------------------------------- 
 
*NFI01 and NFI01a
	


    * Keep relevant variables
    keep store_receipt reason_no_receipt

    * Create a count for collapsing
    gen total = 1

    * Collapse to get counts by store_receipt and reason
    collapse (sum) total, by(reason_no_receipt store_receipt)

    * Total by store_receipt group
    gen total_sum = .
    by store_receipt (reason_no_receipt), sort: replace total_sum = sum(total)
    by store_receipt (reason_no_receipt): replace total_sum = total_sum[_N]

    * Create proportion (0-1 scale for percent graph)
    gen prop = total / total_sum

    * Optional: drop very small values
    drop if prop < 0.01

    * Label variables if not already labeled
    label define reason_lbl 1 "Not ask for invoices" ///
                          2 "Stores are cheaper" ///
                          3 "Distance" ///
                          4 "Access" ///
                          5 "Other" ///
                          6 "Don't know"
    label values reason_no_receipt reason_lbl

    label define store_lbl 1 "Receipt" 2 "Reasons No Receipt"
    label values store_receipt store_lbl

    * Global graph styling options
    global graph_opts1 bgcolor(white) graphregion(color(white)) ///
        legend(region(lc(none) fc(none))) ///
        ylab(,angle(0) nogrid) ///
        subtitle(, justification(left) color(black) span pos(11)) ///
        title(, justification(center) color(black) span pos(17))

    * Y-axis ticks as percentage
    global pct `" 0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%" "'

    * Reshape to wide format: one row per store_receipt, columns for reasons
	keep store_receipt reason_no_receipt prop
    drop if missing(reason_no_receipt)
	

    reshape wide prop, i(store_receipt) j(reason_no_receipt)
* Step 1: Save reshaped dataset
tempfile reshaped
save `reshaped'

* Step 1: Go back to wide data (so prop1, prop2, etc. exist)
use `reshaped', clear
ds prop*, has(type numeric)
local propvars `r(varlist)'

* Step 2: Work in long format to sort proportions for group 2
preserve
    keep if store_receipt == 2
    keep `propvars'
    gen id = _n
    reshape long prop, i(id) j(reason_no_receipt)
    gsort -prop

    * Build sorted variable list
    tostring reason_no_receipt, gen(reason_str)
    gen varname = "prop" + reason_str
    levelsof varname, local(_sortedvars)

    * Clean the macro (remove quotes)
    local sortedvars ""
    foreach v of local _sortedvars {
        local sortedvars `sortedvars' `v'
    }
restore



    * Plot stacked bar chart (6 reasons, so prop1 to prop6)
   graph bar `sortedvars', ///
    stack over(store_receipt, label(angle(0))) nofill ///
    ylab(${pct}) ///
    legend(order(1 "Not ask for invoices" 2 "Stores are cheaper" ///
                 3 "Distance" 4 "Access" 5 "Other" 6 "Don't know") ///
           c(1) pos(3) symxsize(small) symysize(small) size(small)) ///
    ${graph_opts1} ///
    bar(1, color("midblue")) ///
    bar(2, color("ltblue")) ///
    bar(3, color("ebblue")) ///
    bar(4, color("dkteal")) ///
    bar(5, color("navy")) ///
    bar(6, color("blue")) ///
    subtitle("Main reasons for chosing a shop that don't issue receipts", color(black) justification(center) pos(12)) ///
    name(figure_receipt_reason, replace)






*CCD06 and CCD07
	
preserve

    * Create binary variables for each type of problem
   gen problem_yes_store     = problem_card_na == 1
   gen problem_yes_transfer  = problem_card_transfer == 1
   gen problem_yes_money     = problem_card_money == 1
   gen problem_yes_password  = problem_card_password == 1
   gen problem_yes_other     = problem_card_other == 1


    * Reshape the data to long format for graphing
    gen id = _n
   reshape long problem_yes_, i(id) j(problem_type) string

   
   * Keep only rows where a problem occurred
    keep if problem_yes_ == 1

    * Label the problems for the graph
    gen problem_label = ""
    replace problem_label = "Not accepted at the store" if problem_type == "store"
    replace problem_label = "Transfers are delayed" if problem_type == "transfer"
    replace problem_label = "Don't know balance of the card" if problem_type == "money"
    replace problem_label = "Don't know password" if problem_type == "password"
    replace problem_label = "Other" if problem_type == "other"


    * Rename value variable for clarity
    gen has_problem = 1  // since we only kept rows with a problem

    * Assume you have a variable `problem_card` (1 = had card problem, 0 = no problem)
    * If not already binary coded, generate it accordingly

    * Collapse to count problems by problem type and problem_card
    collapse (sum) has_problem, by(problem_card problem_label)

    * Get totals by problem_card group
    gen total = .
    by problem_card (problem_label), sort: replace total = sum(has_problem)
    by problem_card (problem_label): replace total = total[_N]

    * Create proportion
    gen prop = has_problem / total

    * Optional: drop very small values

    drop if prop < 0.01
	
	encode problem_label, gen(problem_code)
	
	keep problem_card problem_code prop


    * Reshape to wide format
   reshape wide prop, i(problem_card) j(problem_code)


    * Get list of prop variables
    ds prop*, has(type numeric)
    local propvars `r(varlist)'

    * Set graph styling
    global graph_opts1 bgcolor(white) graphregion(color(white)) ///
        legend(region(lc(none) fc(none))) ///
        ylab(,angle(0) nogrid) ///
        subtitle(, justification(left) color(black) span pos(11)) ///
        title(, justification(center) color(black) span pos(17))

    global pct `" 0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%" "'

    * Plot stacked bar chart
    graph bar `propvars', ///
        stack over(problem_card, label(angle(0))) nofill ///
        ylab(${pct}) ///
        legend(order(1 "Not accepted at the store" 2 "Transfers are delayed" ///
                     3 "Don't know balance of the card" 4 "Don't know password" 5 "Other") ///
               c(1) pos(3) symxsize(small) symysize(small) size(small)) ///
        ${graph_opts1} ///
        bar(1, color("midblue")) ///
        bar(2, color("ltblue")) ///
        bar(3, color("ebblue")) ///
        bar(4, color("blue")) ///
        bar(5, color("navy")) ///
        subtitle("Problems with the Card", color(black) justification(center) pos(12)) ///
        name(figure_card_problem, replace)

restore

//Graph of use of cash debit and pix by income 


preserve

* Filter out missing income
drop if missing(income_div)

drop if income_div==. 

* Generate indicator variables
gen total = 1
gen cash_user  = payment_method_cash == 1
gen debit_user = payment_method_debit == 1
gen pix_user   = payment_method_pix == 1

* Collapse to get total counts per income group per method
collapse (sum) cash_user debit_user pix_user total, by(income_div)

* Step 1: Rename variables so they have a common stub
rename cash_user  method_cash
rename debit_user method_debit
rename pix_user   method_pix

* Step 2: Reshape long using common stub 'method_'
reshape long method_, i(income_div) j(method) string

* Step 3: Clean up variable name
rename method_ method_user

gen method_clean = ""
replace method_clean = "Cash"  if method == "cash"
replace method_clean = "Debit" if method == "debit"
replace method_clean = "Pix"   if method == "pix"


* Compute percent within each group
bysort income_div (method_clean): gen group_total = sum(method_user)
bysort income_div: replace group_total = group_total[_N]
gen percent = (method_user / group_total) * 100
gen percent_round = round(percent)

* Adjust rounding to make sum = 100%
egen sum_round = total(percent_round), by(income_div)
replace percent_round = percent_round + (100 - sum_round) if _n == 1 & sum_round != 100

* Store total N
sum method_user if !missing(method_clean), meanonly
local N : display %15.0fc r(sum)

* Clean up: drop tiny bars
drop if percent_round < 1



* Final grouped bar graph
graph bar percent_round, over(method_clean, gap(0)) over(income_div) asyvars ///
    bar(1, color(navy)) bar(2, color(midblue)) bar(3, color(emerald)) ///
    blabel(bar, format(%10.0gc) position(outside)) ///
    ytitle("Percentage") ///
    title("Payment Method Use by Income Level") ///
    note("N=`N'") ///
    legend(order(1 "Cash" 2 "Debit" 3 "Pix")) ///
    ysize(6) xsize(10)

restore

* Pick up the card urban/rural 

   preserve

    // Step 1: Drop undesired responses
    drop if  CCD01 == 666

    // Step 2: Apply value labels
    label define card_own 1 "Yes" 2 "Yes, but not receive the benefit" 3 "No", replace
    label values CCD01 card_own

    label define urban_lbl 0 "Urban" 1 "Rural", replace
    label values urban urban_lbl

    // Step 3: Generate total variable for counting
    gen total = 1

    // Step 4: Collapse to get counts by card ownership and urban status
    collapse (count) total, by(urban CCD01)

  // Step 5: Share of each card status within urban/rural
egen group_total = total(total), by(urban)
gen percent = 100 * total / group_total
gen percent_round = round(percent)

// Step 6: Plot the graph
graph bar (asis) percent_round, ///
    over(CCD01, label(angle(45))) ///
    over(urban, label(labsize(small))) ///
    blabel(bar, size(small) format(%2.0f)) ///
    legend(off) ///
    title("Citizen Card Ownership by Urban/Rural") ///
    ytitle("Percent") ///
    bar(1, color(navy)) bar(2, color(midblue)) bar(3, color(gs14)) ///
    note("Shares within each urban/rural group", size(small))

restore





	
	
****************************************************************************end!
	