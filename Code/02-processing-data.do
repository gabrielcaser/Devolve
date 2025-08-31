* Description: This script processes the Devolve-ICMS survey data and labeling variables for analysis. 

* Loading dataset
use "${dropbox}\data\intermediary\devolve_survey_clean.dta", replace // 1,039 obs and 236 variables

* Renaming vars to influence the label
rename INU04aoth INU04a_Other
rename PAG03aoth PAG03a_Other
rename CCD09oth  CCD09_Other
rename DEV02aoth DEV02a_Other
rename CCD07oth  CCD07_Other
rename NFG02Aaoth NFG02Aa_Other
rename NFI04a1oth NFI04a1_Other
rename NFI04b1oth NFI04b1_Other

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
rename PAG04                        payment_daily_method
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
rename NFI04a1_5                    reason_not_cpf_information
rename NFI04a1_555                  reason_not_cpf_other
rename NFI04b                       freq_cpf_na
rename NFI04b1_1                    reason_da_not_cpf_time
rename NFI04b1_2                    reason_da_not_cpf_number
rename NFI04b1_4                    reason_da_not_cpf_interest
rename NFI04b1_3                    reason_da_not_cpf_benefits
rename NFI04b1_5                    reason_da_not_cpf_information
rename NFI04b1_555                  reason_da_not_cpf_other
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
replace income_div = 0  if income == 1 
replace income_div = 1  if income >= 2 
replace income_div = .d if income == .d

label define lblincome_div 0 "Income < R$600" 1 "Income > R$600" .d "Don't know"
label values income_div lblincome_div
label var income_div "(DEM04) Income Category"

* Variable age 
gen age_div = .
replace age_div = 0 if age < 45
replace age_div = 1 if age >= 45

label define lblage_div 0 "Less than 45 years" 1 "More than 45 years" 
label values age_div lblage_div
label var age_div "(DEM02) Age Category"

*ICMS rates
gen     icms_rate2_div = .

replace icms_rate2_div = 1  if icms_rate2 < 5
replace icms_rate2_div = 2  if icms_rate2 >= 5  & icms_rate2 < 10
replace icms_rate2_div = 3  if icms_rate2 >= 10 & icms_rate2 < 20
replace icms_rate2_div = 4  if icms_rate2 >= 20 & icms_rate2 < 30
replace icms_rate2_div = 5  if icms_rate2 >= 30 & icms_rate2 < 40
replace icms_rate2_div = 6  if icms_rate2 >= 40
replace icms_rate2_div = .d if icms_rate2 == .d
replace icms_rate2_div = .  if icms_rate2 == .

* Displaced rainy days categories

gen     displaced_rains_days_cat = .
replace displaced_rains_days_cat = 1  if displaced_rains_days <= 7 & displaced_rains_days != .
replace displaced_rains_days_cat = 2  if displaced_rains_days > 7 & displaced_rains_days <= 14
replace displaced_rains_days_cat = 3  if displaced_rains_days > 14 & displaced_rains_days <= 30
replace displaced_rains_days_cat = 4  if displaced_rains_days > 30 & displaced_rains_days <= 60
replace displaced_rains_days_cat = 5  if displaced_rains_days > 60 & displaced_rains_days != .
replace displaced_rains_days_cat = .d if displaced_rains_days == .d

label define lbldisplaced_rains_days_cat 1 "1 week or less" 2 "1 - 2 weeks" 3 "2 - 4 weeks" 4 "4 - 8 weeks" 5 "More than 8 weeks" .d "Don't know"
label values displaced_rains_days_cat lbldisplaced_rains_days_cat
label var displaced_rains_days_cat "(INU03a) Days displaced due to rain (categories)"



label var icms_rate2_div "(IET05) Perceived ICMS Tax Rate on Purchases in RS"

label define lblicms_rate2_div 1 "Less than 05%" 2 "Between 05-10%" 3 "Between 10-20%" 4 "Between 20-30%" 5 "Between 30-40%" 6 "More than 40%" .d "Don't know"
label values icms_rate2_div lblicms_rate2_div

label var icms_rate_rgs "(IET05a) Perceived ICMS Tax Rate on Purchases in RS, IET05 = .d"

* Variable Municipality (change all the values to "Other" beside the top 5 more frequent)
* Find top 5 most frequent municipalities
preserve
	contract municipality
	gsort -_freq
	keep in 1/5
	levelsof municipality, local(top5) sep(",")
restore
gen municipality_top5 = municipality
replace municipality_top5 = "Other" if !inlist(municipality, `top5')
label var municipality_top5 "(DEM01) Top 5 municipalities where respondents live"

* Creating Top 5 municipalities that received flood_aid
preserve
	contract municipality flood_aid
	keep if flood_aid == 1
	gsort -_freq
	keep in 1/5
	levelsof municipality, local(top5) sep(",")
restore
gen municipality_top5_flood_aid = municipality
replace municipality_top5_flood_aid = "Other" if !inlist(municipality, `top5')
replace municipality_top5_flood_aid = "." if flood_aid != 1
label var municipality_top5_flood_aid "(DEM01_flood) Top 5 municipalities that received flood aid"

* Encoded vars that are openly filed when person answered "Other" 
foreach var in PAG03a_Other INU04a_Other CCD09_Other DEV02a_Other CCD07_Other NFG02Aa_Other NFI04a1_Other NFI04b1_Other {
	if `var' == PAG03a_Other {
		replace `var' = "Government aid"     if `var' == "Auxlio do governo"
		replace `var' = "Government aid"     if `var' == "Auxlio do Governo do Estado"
		replace `var' = "Building materials" if `var' == "Materiais de construção"
	}
	if `var' == CCD09_Other {
		replace CCD09_Other = "Participant has reduced mobility" ///
			if CCD09_Other == "Participante tem mobilidade reduzida e não consegue se deslocar até o local"
		replace CCD09_Other = "No interest in receiving" ///
			if CCD09_Other == "nao tem interesse de receber"
		replace CCD09_Other = "Card was not there when he went" ///
			if CCD09_Other == "chegou a tentar retirar mas não havia o cartão quando foi ao local"
		replace CCD09_Other = "Card at Banrisul, update pending" ///
			if CCD09_Other == "Recebeu informação da escola de que tinha direito e que o cartão estava no Banrisul, precisava desbloquear. Ligou para o 0800 e informaram que precisava atualizar cadastro. Não foi feito."
		replace CCD09_Other = "Does not live alone" ///
			if CCD09_Other == "Não mora sozinha"
		replace CCD09_Other = "Center confirmed no benefit" ///
			if CCD09_Other == "porque ligou na central e falaram que não tem direito ao beneficio"
		replace CCD09_Other = "Card reading error" ///
			if CCD09_Other == "Disse que está afastada/enconstada e não tem direito ao benefício"
		replace CCD09_Other = "Benefit requirements unmet" ///
			if CCD09_Other == "Considera que não cumpre os requisitos para receber o benefício"
	}
	if `var' == DEV02a_Other {
		replace DEV02a_Other = "Neighbors"     if DEV02a_Other == "Vizinhos"
		replace DEV02a_Other = "Coworkers"     if DEV02a_Other == "Colegas de trabalho"
		replace DEV02a_Other = "Acquaintances" if inlist(DEV02a_Other, "conhecidos", "Conhecidos", "Conhecidos.")
	}
	if `var' == CCD07_Other {
		replace CCD07_Other = "System down" if CCD07_Other == "Sistema fora do ar"
		replace CCD07_Other = "A Overload and deposit failure" if CCD07_Other == "Sistema fica fora do ar quando o dinheiro é depositado ou sobrecarga de usuários comparando"
		replace CCD07_Other = "Card reading error" if CCD07_Other == "Erro de leitura do cartão na máquina da loja/ Máquina da loja travou"
	}
	if `var' == NFG02Aa_Other {
		replace NFG02Aa_Other = "Does not know the program" if NFG02Aa_Other == "Não conhece bem o programa Nota Fiscal Gaúcha"
		replace NFG02Aa_Other = "Never tried to register" if NFG02Aa_Other == "Nunca tentou se cadastrar"
		replace NFG02Aa_Other = "Can't access the application" if NFG02Aa_Other == "Não consegue acessar o aplicativo"
		replace NFG02Aa_Other = "Lack of interest" if NFG02Aa_Other == "Não tem interesse em participar"
	}
	if `var' == NFI04a1_Other {
		replace NFI04a1_Other = "Forget to request" if NFI04a1_Other == "Esquece de solicitar"
		replace NFI04a1_Other = "Lack of time/hurry" if NFI04a1_Other == "Falta de tempo/ pressa"
		replace NFI04a1_Other = "Not included for small purchases" if NFI04a1_Other == "Compras de pequeno valor não inclui o CPF"
	}
	if `var' == NFI04b1_Other {
		replace NFI04b1_Other = "Forget to request" if NFI04b1_Other == "Esquece de solicitar"
		replace NFI04b1_Other = "Attendant didn't requested it" if NFI04b1_Other == "Não inclui o CPF quando o atendente não solicita"
		replace NFI04b1_Other = "Not included for small purchases" if NFI04b1_Other == "Compras de pequeno valor não inclui o CPF"
	}

	// Calculate percentage for each value to change small categories for "Other"
	preserve
		contract `var'
		drop if `var' == ""
		egen total_freq = sum(_freq)
		gen pct = 100 * _freq / total_freq
		drop _freq total_freq
		tempfile freqdata
		save `freqdata', replace
	restore
	merge m:1 `var' using `freqdata', nogen
	replace `var' = "Other" if pct < 10
	drop pct
	encode `var', gen(`var'_encoded)
}


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
	payment_daily_method ///
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
	reason_not_cpf_information ///
	reason_not_cpf_other ///
	freq_cpf_na ///
	reason_da_not_cpf_time ///
	reason_da_not_cpf_number ///
	reason_da_not_cpf_interest ///
	reason_da_not_cpf_benefits ///
	reason_da_not_cpf_information ///
	reason_da_not_cpf_other ///
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
	urban ///
	flood_impact ///
	flood_impact2 ///
	displaced_rains ///
	displaced_rains_days ///
	flood_aid ///
	gender ///
	municipality_top5 ///
	household_size ///
	aid_finance ///
	aid_cleaning ///
	aid_dk ///
	aid_material ///
	aid_medic ///
	aid_reconstruction /// 
	aid_other ///
	PAG03a_Other_encoded ///
	INU04a_Other_encoded ///
	CCD09_Other_encoded ///
	DEV02a_Other_encoded ///
	CCD07_Other_encoded ///
	NFG02Aa_Other_encoded ///
	NFI04a1_Other_encoded ///
	NFI04b1_Other_encoded ///
	displaced_rains_days_cat ///
	municipality_top5_flood_aid


*-------------------------------------------------------------------------------	
* Save data set
*-------------------------------------------------------------------------------	
   
save "${dropbox}\data\final\devolve_survey_constructed.dta", replace // 1039 observations and 117 variables
   
   
   
   
   
   
	