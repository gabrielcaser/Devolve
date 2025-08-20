* Description: This script processes the Devolve-ICMS survey data and labeling variables for analysis. 

* Loading dataset
use "${dropbox}\data\intermediary\devolve_survey_clean.dta", replace // 1,039 obs and 236 variables 

* Adding name of the variable at the begining of the label inside ()
foreach var of varlist _all {
	local label : variable label `var'
	if "`label'" != "" {
		local new_label = "(`var') `label'"
		label variable `var' "`new_label'"
	}
}

* Renaming variables for clarity
rename tipotelefone                 phone_type
rename idade1                       age_over18
rename telefone                     hh
rename DEV01                        know_devolve
rename DEVPAR01                     participates_devolve
rename DEVPAR02                     program_discovery
rename DEV02                        knows_participant
rename DEV02a_1                     other_beneficiaries_family
rename DEV02a_2                     other_beneficiaries_friends
rename DEV02a_3                     other_beneficiaries_leaders
rename DEV02a_555                   other_beneficiaries_other
rename DEV02a_666                   other_beneficiaries_dontknow
rename DEV03                        reason_money_accounts
rename DEV04                        program_eligilibility
rename DEV05                        deposit_frequency
rename DEV06                        quarterly_deposit
rename DEV07                        usage_increases
rename DEV08                        unused_funds
rename PAG01_1                      payment_method_cash
rename PAG01_2                      payment_method_debit
rename PAG01_3                      payment_method_credit
rename PAG01_4                      payment_method_pix
rename PAG01_5                      payment_method_mobile
rename PAG01_666                    payment_method_other
rename PAG04                        payment_method_daily
rename PAG02                        purchases_last_week
rename PAG03                        hh_bank_account
rename PAG03a_1                     bank_account_brasil
rename PAG03a_2                     bank_account_bradesco
rename PAG03a_3                     bank_account_itau
rename PAG03a_4                     bank_account_santander
rename PAG03a_5                     bank_account_nubank
rename PAG03a_6                     bank_account_inter
rename PAG03a_7                     bank_account_c6
rename PAG03a_8                     bank_account_banrisul
rename PAG03a_9                     bank_account_pagbank
rename PAG03a_10                    bank_account_picpay
rename PAG03a_11                    bank_account_agibank
rename PAG03a_12                    bank_account_sicredi
rename PAG03a_13                    bank_account_caixa
rename PAG03a_555                   bank_account_other
rename PAG03a_666                   bank_account_dontknow
rename NFI01                        store_receipt
rename NFI01a                       reason_no_receipt
rename NFI02                        consumption_receipt
rename NFI03                        type_cpf
rename NFI03a                       freq_cpf
rename NFI04                        cpf_invoice
rename NFI04a                       cpf_invoice_freq
rename NFI04a1_1                    reason_not_cpf_time
rename NFI04a1_2                    reason_not_cpf_number
rename NFI04a1_4                    reason_not_cpf_interest
rename NFI04a1_3                    reason_not_cpf_benefits
rename NFI04a1_5                    reason_not_cpf_inofrmation
rename NFI04a1_555                  reason_not_cpf_other
rename NFI04b                       freq_cpf_na
rename NFI04b1_1                    reason_not_cpf_time_da
rename NFI04b1_2                    reason_not_cpf_number_da
rename NFI04b1_4                    reason_not_cpf_interest_dat
rename NFI04b1_3                    reason_not_cpf_benefits_da
rename NFI04b1_5                    reason_not_cpf_inofrmation_da
rename NFI04b1_555                  reason_not_cpf_other_da
rename NFI05                        monthly_purchases
rename NFI05a                       monthly_spend
rename CCD01                        card_devolve
rename CCD02                        cpf_receipt_freq
rename CCD03                        spend_value
rename CCD04                        use_citizen_card
rename CCD05                        main_use_card
rename CCD06                        problem_card
rename CCD07_1                      problem_card_na
rename CCD07_2                      problem_card_transfer
rename CCD07_3                      problem_card_money
rename CCD07_4                      problem_card_password
rename CCD07_555                    problem_card_other
rename CCD07_666                    problem_card_dk
rename CCD08                        get_card
rename CCD09_1                      card_collection_l
rename CCD09_2                      card_collection_d
rename CCD09_3                      card_collection_k
rename CCD09_4                      card_collection_w
rename CCD09_5                      card_collection_t
rename CCD09_6                      card_collection_p
rename CCD09_7                      card_collection_dp
rename CCD09_555                    card_collection_other
rename CCD09_666                    card_collection_dk
rename CCD10                        stores_nearby
rename CCD11                        card_use_worry
rename CCD12                        worry_unauthorized_card
rename CCD13                        reason_card
rename IET01                        inequality_brazil
rename IET02                        tax_collection
rename IET03                        tax_revenue_preference
rename IET04                        tax_essential_goods
rename IET05                        icms_rate2
rename IET05a                       icms_rate_rgs
rename IET06                        cpf_on_invoice_rule
rename IET07                        increase_tax_on_food
rename IET08                        tax_on_foodreturned
rename IET09                        tax_food_all
rename IET10                        tax_perfumes_makeup
rename NFG01                        nota_fiscal_program
rename NFG02                        participate_nfg
rename NFG02A                       reason_nfg
rename NFG03                        send_information
rename NFG031                       send_information_method
rename DEM01                        municipality
rename DEM02                        age
rename DEM03                        gender
rename DEM04                        income
rename DEM05                        household_size
rename INU01                        flood_impact
rename INU02                        flood_impact2
rename INU03                        displaced_rains
rename INU03a                       displaced_rains_days
rename INU04                        flood_aid
rename INU04a_1                     aid_finance
rename INU04a_2                     aid_material
rename INU04a_3                     aid_medic
rename INU04a_4                     aid_cleaning
rename INU04a_5                     aid_reconstruction
rename INU04a_555                   aid_other
rename INU04a_666                   aid_dk
	
*-------------------------------------------------------------------------------	
* Creation of variables
*-------------------------------------------------------------------------------	
  
*Monthly purchases category (NEW CODE)
gen     monthly_purchases_cat = .
replace monthly_purchases_cat = 1  if monthly_purchases <  500
replace monthly_purchases_cat = 2  if monthly_purchases >= 500  & monthly_purchases < 1000
replace monthly_purchases_cat = 3  if monthly_purchases >= 1000 & monthly_purchases < 1500
replace monthly_purchases_cat = 4  if monthly_purchases >= 1500 & monthly_purchases < 2000
replace monthly_purchases_cat = 5  if monthly_purchases >= 2000
replace monthly_purchases_cat = .d if monthly_purchases == .d
  
label var monthly_purchases_cat "(NFI05) Monthly Spend Category"
la de lblmonthly_purchases_cat 1 "Less than R$500.00" 2 "From R$500.00 to R$1,000.00" 3 "From R$1,000.00 to R$1,500.00" 4 "From R$1,500.00 to R$2,000.00" 5 "More than R$ 2,000.00" .d "Don't know"
label values monthly_purchases_cat lblmonthly_purchases_cat

*Generate unit variable
gen unit = 1

*Date variable
gen date_part = substr(SubmissionDate, 1, strpos(SubmissionDate, " ") - 1)

gen day = substr(date_part, 1, strpos(date_part, "/") - 1)
gen month = substr(date_part, strpos(date_part, "/") + 1, strpos(substr(date_part, strpos(date_part, "/") + 1, .), "/") - 1)
gen year = substr(date_part, -4, .)  
 
*Duration of phone call 
gen double duration_ms = duration * 1000
format duration_ms %tcHH:MM:SS
gen double duration_sec = duration_ms / 1000
label var duration_ms "Duration of phone call (minutes)"

* Variable income_div is correctly defined
gen income_div = .
replace income_div = 0 if income == 1 
replace income_div = 1 if income >= 2 

label define lblincome_div 0 "Less than 600" 1 "More than 600"
label values income_div lblincome_div
label var income_div "Income Category"

* Variable age 
gen age_div = .
replace age_div = 0 if age < 45
replace age_div = 1 if age >= 45

label define lblage_div 0 "Less than 45 years" 1 "More than 45 years" 
label values age_div lblage_div
label var age_div "Age Category"

*ICMS rates
gen icms_rate2_div=.
replace icms_rate2_div=1 if icms_rate2 < 7
replace icms_rate2_div=2 if icms_rate2 >= 7 & icms_rate2 < 10
replace icms_rate2_div=3 if icms_rate2 >= 10 & icms_rate2 < 20
replace icms_rate2_div=4 if icms_rate2 >= 20 & icms_rate2 < 30
replace icms_rate2_div=5 if icms_rate2 >= 30 & icms_rate2 < 40
replace icms_rate2_div=6 if icms_rate2 >= 40

label define lblicms_rate2_div 1 "Less than 7%" 2 "From 7% to 10%" 3 "From 10% to 20%" 4 "From 20% to 30%" 5 "From 30% to 40%" 6 "More than 40%"
label values icms_rate2_div lblicms_rate2_div
label var icms_rate2_div "ICMS Rate Category"

*-------------------------------------------------------------------------------	
* Merge with urban/rural classification
*-------------------------------------------------------------------------------	

preserve   
	import excel using "${dropbox}\data\raw\muncipalities_brazil.xlsx", firstrow clear
	rename Municipality municipality 
	tempfile urbclass
	save `urbclass', replace
restore

* Merge
merge m:1 municipality using `urbclass', nogen keep(1 3)

rename Urban10 urban
label define lblurban 1 "Yes" 0 "No"
label values urban lblurban
label var urban "Urban"

*-------------------------------------------------------------------------------	
* Order Data set
*-------------------------------------------------------------------------------	
order day month year id_entrevista municipality age gender income

* Maintaining only relevant variables (used in the script)
keep ///
	id_entrevista ///
	phone_type ///
	age_over18 ///
	hh ///
	know_devolve ///
	participates_devolve ///
	program_discovery ///
	knows_participant ///
	other_beneficiaries_family ///
	other_beneficiaries_friends ///
	other_beneficiaries_leaders ///
	other_beneficiaries_other ///
	other_beneficiaries_dontknow ///
	reason_money_accounts ///
	program_eligilibility ///
	deposit_frequency ///
	quarterly_deposit ///
	usage_increases ///
	unused_funds ///
	payment_method_cash ///
	payment_method_debit ///
	payment_method_credit ///
	payment_method_pix ///
	payment_method_mobile ///
	payment_method_other ///
	payment_method_daily ///
	purchases_last_week ///
	hh_bank_account ///
	bank_account_brasil ///
	bank_account_bradesco ///
	bank_account_itau ///
	bank_account_santander ///
	bank_account_nubank ///
	bank_account_inter ///
	bank_account_c6 ///
	bank_account_banrisul ///
	bank_account_pagbank ///
	bank_account_picpay ///
	bank_account_agibank ///
	bank_account_sicredi ///
	bank_account_caixa ///
	bank_account_other ///
	bank_account_dontknow ///
	store_receipt ///
	reason_no_receipt ///
	consumption_receipt ///
	type_cpf ///
	freq_cpf ///
	cpf_invoice ///
	cpf_invoice_freq ///
	reason_not_cpf_time ///
	reason_not_cpf_number ///
	reason_not_cpf_interest ///
	reason_not_cpf_benefits ///
	reason_not_cpf_inofrmation ///
	reason_not_cpf_other ///
	freq_cpf_na ///
	reason_not_cpf_time_da ///
	reason_not_cpf_number_da ///
	reason_not_cpf_interest_dat ///
	reason_not_cpf_benefits_da ///
	reason_not_cpf_inofrmation_da ///
	reason_not_cpf_other_da ///
	monthly_purchases ///
	monthly_spend ///
	card_devolve ///
	cpf_receipt_freq ///
	spend_value ///
	use_citizen_card ///
	main_use_card ///
	problem_card ///
	problem_card_na ///
	problem_card_transfer ///
	problem_card_money ///
	problem_card_password ///
	problem_card_other ///
	problem_card_dk ///
	get_card ///
	card_collection_l ///
	card_collection_d ///
	card_collection_k ///
	card_collection_w ///
	card_collection_t ///
	card_collection_p ///
	card_collection_dp ///
	card_collection_other ///
	card_collection_dk ///
	stores_nearby ///
	card_use_worry ///
	worry_unauthorized_card ///
	reason_card ///
	inequality_brazil ///
	tax_collection ///
	tax_revenue_preference ///
	tax_essential_goods ///
	icms_rate2 ///
	icms_rate_rgs ///
	cpf_on_invoice_rule ///
	increase_tax_on_food ///
	tax_on_foodreturned ///
	tax_food_all ///
	tax_perfumes_makeup ///
	nota_fiscal_program ///
	participate_nfg ///
	reason_nfg ///
	send_information ///
	send_information_method ///
	municipality ///
	monthly_purchases_cat ///
	day ///
	month ///
	year ///
	duration_ms ///
	income_div ///
	age_div ///
	icms_rate2_div ///
	urban

*-------------------------------------------------------------------------------	
* Save data set
*-------------------------------------------------------------------------------	
   
save "${dropbox}\data\final\devolve_survey_constructed.dta", replace // 1039 observations and 117 variables
   
   
   
   
   
   
	