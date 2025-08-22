* Description: This Stata script is used to clean and prepare survey data for analysis.
** It imports data from Excel files, destrings variables and creates labels for various survey responses.

* Authors: Josefina Silva (Original) and Gabriel Caser dos Passos (Updated)

* TODO:

*-------------------------------------------------------------------------------
* Cleaning Data:
*-------------------------------------------------------------------------------

* Import Excel file
import excel "${dropbox}\data\raw\Base Final BM Programa Devolve ICMS RS Coleta.xlsx", ///
	sheet("Consulta1") firstrow clear

* Save raw .dta file
save "${dropbox}\data\raw\devolve_survey_raw.dta", replace // 1039 obs and 236 vars

* Change variable types
destring, replace

* Check for duplicates
duplicates report id_entrevista
isid id_entrevista

* Creating labels and changing types
** droping old labels
label drop _all
foreach var of varlist _all {
	label variable `var' ""
}

* Replacing all dummies (yes and no or TRUE and FALSE) values with 0, 1 (2) and .d (666) 

local clean_vars tipotelefone idade1 DEV01 DEV02 DEV02a_* DEV06 DEV07 ///
	PAG01_* PAG03a_* NFI01 NFI04a1_* NFI04b1_* CCD06 CCD07_* CCD08 ///
	CCD09_* NFG01 NFG02 NFG03 DEM03 INU01 INU03 INU04 INU04a_*

foreach var of varlist `clean_vars' {
	replace `var' = 0 if `var' == 2
	replace `var' = .d if `var' == 666
}

* Phone type
label var tipotelefone "Phone type of the call"
label define lblphone_type 1 "Cellular" 2 "Landline telephone"
label values tipotelefone lblphone_type

* Age (over 18)
label var idade1 "Are you over 18?"
label define lblage_over18 1 "Yes" 0 "No"
label values idade1 lblage_over18

* Household responsible
label var telefone "Are you the adult responsible for decisions in your home or could you call someone else who you consider responsible?"
label define lblhh 1 "Yes" 2 "No, but call transferred to the hh" 3 "No, and you did not transfer the call to hh"
label values telefone lblhh

* Familiarity with Devolve-ICMS program
label var DEV01 "Are you familiar with the Devolve-ICMS program?"
label define lblknow_devolve 1 "Yes" 0 "No" .d "Don't know"
label values DEV01 lblknow_devolve

* Participation in Devolve-ICMS program
label var DEVPAR01 "Do you and your family who lives in the same household as you participate in the Devolve?"
replace DEVPAR01 = .d if DEVPAR01 == 666
label define lblparticipates_devolve 1 "Yes" 2 "No" 3 "Does not currently participate" .d "Don't know"
label values DEVPAR01 lblparticipates_devolve

* How did you find out about the program
label var DEVPAR02 "How did you find out you were part of the program?"
replace DEVPAR02 = .d if DEVPAR02 == 666
label define lblprogram_discovery 1 "CRAS" 2 "Traditional media" 3 "Internet or Social Media" 4 "Family member or friend" 555 "Other" .d "Don't know"
label values DEVPAR02 lblprogram_discovery

* Knows someone who participates in the program
label var DEV02 "Does anyone you know participate in the program?"
label define lblknows_participant 1 "Yes" 0 "No" .d "Don't know"
label values DEV02 lblknows_participant

* Other known beneficiaries - Family
label var DEV02a_1 "Who are the other participants in the program that you know?- Family"
label define lblother_beneficiaries_family 1 "Yes" 0 "No"
label values DEV02a_1 lblother_beneficiaries_family

* Other known beneficiaries - Friends
label var DEV02a_2 "Who are the other participants in the program that you know?- Friends"
label define lblother_beneficiaries_friends 1 "Yes" 0 "No"
label values DEV02a_2 lblother_beneficiaries_friends

* Other known beneficiaries - Leaders
label var DEV02a_3 "Who are the other participants in the program that you know?- Leaders"
label define lblother_beneficiaries_leaders 1 "Yes" 0 "No"
label values DEV02a_3 lblother_beneficiaries_leaders

* Other known beneficiaries - Other
label var DEV02a_555 "Who are the other participants in the program that you know?- Other"
label define lblother_beneficiaries_other 1 "Yes" 0 "No"
label values DEV02a_555 lblother_beneficiaries_other

* Other known beneficiaries - Don't know
label var DEV02a_666 "Who are the other participants in the program that you know?- Don't know"
label define lblother_beneficiaries_dontknow 1 "Yes" 0 "No"
label values DEV02a_666 lblother_beneficiaries_dontknow

* Reason for money in the account
label var DEV03 "Why does this money go into the participants' accounts?"
replace DEV03 = .d if DEV03 == 666
label define lblreason_money_accounts 1 "Money part of the Bolsa Família" 2 "Tax refund for purchases" 3 "Government aid for school attendance" 4 "State-level Bolsa Família" 555 "Other" .d "Don't know"
label values DEV03 lblreason_money_accounts

* Requirements to participate in Devolve-ICMS
label var DEV04 "Requirements Devolve program"
replace DEV04 = .d if DEV04 == 666
label define lblprogram_eligilibility 1 "Bolsa Familia/Highschool" 2 "Family Income < 3 Wages" 3 "Adult's CPF Active" 4 "All alternatives" 555 "Other" .d "Don't know"
label values DEV04 lblprogram_eligilibility

* Payment frequency
label var DEV05 "Frequency payments program"
replace DEV05 = .d if DEV05 == -9
*label define lbldeposit_frequency .d "Don't know"
label values DEV05 lbldeposit_frequency

* Quarterly deposit
label var DEV06 "Every three months, at least 100 reais are deposited on the Citizen ICMS Return Card"
label define lblquarterly_deposit 1 "True" 0 "False" .d "Don't know"
label values DEV06 lblquarterly_deposit

* CPF use increases benefit
label var DEV07 "Increased Earnings from the Program with CPF-RI"
label define lblusage_increases 1 "True" 0 "False" .d "Don't know"
label values DEV07 lblusage_increases

* Unused funds on the card
label var DEV08 "Unused funds on Devolve-ICMS card after a month."
replace DEV08 = .d if DEV08 == 666
label define lblunused_funds 1 "All is lost" 2 "Some remains available n/m" 3 "All available for n/m" 555 "Other" .d "Don't know"
label values DEV08 lblunused_funds

* Payment methods - cash
label var PAG01_1 "Payment methods do you use to make purchases on a daily basis-cash"
label define lblpayment_method_cash 1 "Yes" 0 "No"
label values PAG01_1 lblpayment_method_cash

* Payment methods - debit
label var PAG01_2 "Payment methods do you use to make purchases on a daily basis-debit"
label define lblpayment_method_debit 1 "Yes" 0 "No"
label values PAG01_2 lblpayment_method_debit

* Payment methods - credit
label var PAG01_3 "Payment methods do you use to make purchases on a daily basis-credit"
label define lblpayment_method_credit 1 "Yes" 0 "No"
label values PAG01_3 lblpayment_method_credit

* Payment methods - PIX
label var PAG01_4 "Payment methods do you use to make purchases on a daily basis-PIX"
label define lblpayment_method_pix 1 "Yes" 0 "No"
label values PAG01_4 lblpayment_method_pix

* Payment methods - mobile apps
label var PAG01_5 "Payment methods do you use to make purchases on a daily basis-mobile apps"
label define lblpayment_method_mobile 1 "Yes" 0 "No"
label values PAG01_5 lblpayment_method_mobile

* Payment methods - other
label var PAG01_666 "Payment methods do you use to make purchases on a daily basis-other"
label define lblpayment_method_other 1 "Yes" 0 "No"
label values PAG01_666 lblpayment_method_other

* Most convenient payment method
label var PAG04 "Payment methods daily purchases"
replace PAG04 = .d if PAG04 == 666
label define lblpayment_method_daily 1 "Cash" 2 "Debit/Credit" 3 "PIX" 4 "Mobile apps" .d "Don't know"
label values PAG04 lblpayment_method_daily

* Purchases last week in cash
label var PAG02 "Purchases made last week"
replace PAG02 = .d if PAG02 == 666
label define lblpurchases_last_week 1 "All or almost all" 2 "More than half" 3 "Half" 4 "Less than half" 5 "None or almost none" .d "Don't know"
label values PAG02 lblpurchases_last_week

* Household bank account
label var PAG03 "Household has bank acount"
replace PAG03 = .d if PAG03 == 666
label define lblhh_bank_account 1 "Yes, you have" 2 "Yes, other person have" 3 "Yes, you and other family members have" 4 "No, neither you nor anyone" .d "Don't know"
label values PAG03 lblhh_bank_account

* Banks - examples
label var PAG03a_1 "Bank account Banco do Brasil"
label define lblbank_account_brasil 1 "Yes" 0 "No"
label values PAG03a_1 lblbank_account_brasil

label var PAG03a_2 "Bank account Banco Bradesco"
label define lblbank_account_bradesco 1 "Yes" 0 "No"
label values PAG03a_2 lblbank_account_bradesco

label var PAG03a_3 "Bank account Itau"
label define lblbank_account_itau 1 "Yes" 0 "No"
label values PAG03a_3 lblbank_account_itau

label var PAG03a_4 "Bank account Santander"
label define lblbank_account_santander 1 "Yes" 0 "No"
label values PAG03a_4 lblbank_account_santander

label var PAG03a_5 "Bank account Nubank"
label define lblbank_account_nubank 1 "Yes" 0 "No"
label values PAG03a_5 lblbank_account_nubank

label var PAG03a_6 "Bank account banco Inter"
label define lblbank_account_inter 1 "Yes" 0 "No"
label values PAG03a_6 lblbank_account_inter

label var PAG03a_7 "Bank account banco C6"
label define lblbank_account_c6 1 "Yes" 0 "No"
label values PAG03a_7 lblbank_account_c6

label var PAG03a_8 "Bank account banco Banrisul"
label define lblbank_account_banrisul 1 "Yes" 0 "No"
label values PAG03a_8 lblbank_account_banrisul

label var PAG03a_9 "Bank account banco Pagbank"
label define lblbank_account_pagbank 1 "Yes" 0 "No"
label values PAG03a_9 lblbank_account_pagbank

label var PAG03a_10 "Bank account banco Picpay"
label define lblbank_account_picpay 1 "Yes" 0 "No"
label values PAG03a_10 lblbank_account_picpay

label var PAG03a_11 "Bank account banco Agibank"
label define lblbank_account_agibank 1 "Yes" 0 "No"
label values PAG03a_11 lblbank_account_agibank

label var PAG03a_12 "Bank account banco Sicredi"
label define lblbank_account_sicredi 1 "Yes" 0 "No"
label values PAG03a_12 lblbank_account_sicredi

label var PAG03a_13 "Bank account banco Caixa"
label define lblbank_account_caixa 1 "Yes" 0 "No"
label values PAG03a_13 lblbank_account_caixa

label var PAG03a_555 "Bank account banco Other"
label define lblbank_account_other 1 "Yes" 0 "No"
label values PAG03a_555 lblbank_account_other

label var PAG03a_666 "Bank account banco don't know"
label define lblbank_account_dontknow 1 "Yes" 0 "No"
label values PAG03a_666 lblbank_account_dontknow

* Receives receipt
label var NFI01 "Does the store where you shop most often give you a receipt?"
label define lblstore_receipt 1 "Yes" 0 "No" .d "Don't know"
label values NFI01 lblstore_receipt

* Reason for not asking for receipt
label var NFI01a "Main reason no receipt store"
replace NFI01a = .d if NFI01a == 666
label define lblreason_no_receipt 1 "Not ask for invoices" 2 "Stores are cheaper" 3 "Distance" 4 "Access" 555 "Other" .d "Don't know"
label values NFI01a lblreason_no_receipt

* Consumption in stores that ask for CPF
label var NFI02 "Percentage of consumption from stores asking to include CPF on receipt"
replace NFI02 = .d if NFI02 == 666
label define lblconsumption_receipt 1 "All or almost everything" 2 "More than half" 3 "Half" 4 "Less than half" 5 "Nothing or almost nothing" .d "Don't know"
label values NFI02 lblconsumption_receipt

* CPF used on the receipt
label var NFI03 "Type CPF for purchase invoice"
replace NFI03 = .d if NFI03 == 666
label define lbltype_cpf 1 "Own" 2 "Family member" 3 "Don't use it" 555 "Other" .d "Don't know"
label values NFI03 lbltype_cpf

* Frequency of using someone else's CPF
label var NFI03a "Frequency CPF use"
replace NFI03a = .d if NFI03a == 666
label define lblfreq_cpf 1 "Always" 2 "Sometimes" 3 "Rarely" 4 "Never" .d "Don't know"
label values NFI03a lblfreq_cpf

* Frequency of attendant asking for CPF
label var NFI04 "Frequency CPF on the invoice"
replace NFI04 = .d if NFI04 == 666
label define lblcpf_invoice 1 "Always" 2 "Sometimes" 3 "Rarely" 4 "Never" .d "Don't know"
label values NFI04 lblcpf_invoice

* Frequency of including CPF when asked
label var NFI04a "Frequency CPF on the invoice"
replace NFI04a = .d if NFI04a == 666
label define lblcpf_invoice_freq 1 "Always" 2 "Sometimes" 3 "Rarely" 4 "Never" .d "Don't know"
label values NFI04a lblcpf_invoice_freq

* Reasons for not including CPF (example)
label var NFI04a1_1 "Reasons not to include CPF time"
label define lblreason_not_cpf_time 1 "Yes" 0 "No"
label values NFI04a1_1 lblreason_not_cpf_time

label var NFI04a1_2 "Reasons not to include CPF don't know the number"
label define lblreason_not_cpf_number 1 "Yes" 0 "No"
label values NFI04a1_2 lblreason_not_cpf_number

label var NFI04a1_3 "Reasons not to include CPF don't know the benefits"
label define lblreason_not_cpf_benefits 1 "Yes" 0 "No"
label values NFI04a1_3 lblreason_not_cpf_benefits

label var NFI04a1_4 "Reasons not to include CPF not interested"
label define lblreason_not_cpf_interest 1 "Yes" 0 "No"
label values NFI04a1_4 lblreason_not_cpf_interest

label var NFI04a1_5 "Reasons not to include CPF not sharing info"
label define lblreason_not_cpf_information 1 "Yes" 0 "No"
label values NFI04a1_5 lblreason_not_cpf_information

label var NFI04a1_555 "Reasons not to include CPF other"
label define lblreason_not_cpf_other 1 "Yes" 0 "No"
label values NFI04a1_555 lblreason_not_cpf_other

* Frequency of asking for CPF when not asked by attendant
label var NFI04b "Frequency of CPF use when attendence does not ask"
replace NFI04b = .d if NFI04b == 666
label define lblfreq_cpf_na 1 "Always" 2 "Sometimes" 3 "Rarely" 4 "Never" .d "Don't know"
label values NFI04b lblfreq_cpf_na

* Reasons for not including CPF when not asked (example)
label var NFI04b1_1 "Reasons not to include CPF time"
label define lblreason_not_cpf_time_da 1 "Yes" 0 "No"
label values NFI04b1_1 lblreason_not_cpf_time_da

label var NFI04b1_2 "Reasons not to include CPF don't know the number"
label define lblreason_not_cpf_number_da 1 "Yes" 0 "No"
label values NFI04b1_2 lblreason_not_cpf_number_da

label var NFI04b1_3 "Reasons not to include CPF don't know the benefits"
label define lblreason_not_cpf_benefits_da 1 "Yes" 0 "No"
label values NFI04b1_3 lblreason_not_cpf_benefits_da

label var NFI04b1_4 "Reasons not to include CPF not interested"
label define lblreason_not_cpf_interest_da 1 "Yes" 0 "No"
label values NFI04b1_4 lblreason_not_cpf_interest_da

label var NFI04b1_5 "Reasons not to include CPF not sharing info"
label define lblreason_not_cpf_information_da 1 "Yes" 0 "No"
label values NFI04b1_5 lblreason_not_cpf_information_da

label var NFI04b1_555 "Reasons not to include CPF other"
label define lblreason_not_cpf_other_da 1 "Yes" 0 "No"
label values NFI04b1_555 lblreason_not_cpf_other_da

* Monthly purchases
label var NFI05 "Monthly Purchases"
replace NFI05 = .d if NFI05 == -9

* Monthly spending range
label var NFI05a "Monthly Spend"
replace NFI05a = .d if NFI05a == 666
label define lblmonthly_spend 1 "0-500" 2 "500-1,000" 3 "1,000-1,500" 4 "1,500-2,000" 5 "more than 2,000" .d "Don't know"
label values NFI05a lblmonthly_spend

* Has citizen card
label var CCD01 "Have the Citizen Card from the Devolve-ICMS program"
replace CCD01 = .d if CCD01 == 666
label define lblcard_devolve 1 "Yes" 2 "Yes, but NOT receive the benefit" 3 "No" .d "Don't know"
label values CCD01 lblcard_devolve

* Frequency of CPF inclusion on receipts
label var CCD02 "CPF Inclusion Frequency on Receipts"
replace CCD02 = .d if CCD02 == 666
label define lblcpf_receipt_freq 1 "With more frequency" 2 "With the same frequency" 3 "With the less frequency" .d "Don't know"
label values CCD02 lblcpf_receipt_freq

* Time to spend card value
label var CCD03 "Spend the amounts Devolve card"
replace CCD03 = .d if CCD03 == 666
label define lblspend_value 1 "One day" 2 "One week" 3 "First weeks" 4 "One month" 5 "More than one month" 6 "Don't use it" .d "Don't know"
label values CCD03 lblspend_value

* How much of the citizen card is used
label var CCD04 "Use Citizen Card"
replace CCD04 = .d if CCD04 == 666
label define lbluse_citizen_card 1 "All" 2 "More than half" 3 "Half" 4 "Less than half" 5 "Nothing or almost nothing" .d "Don't know"
label values CCD04 lbluse_citizen_card

* Main use of the card
label var CCD05 "Main use Citizen Card"
replace CCD05 = .d if CCD05 == 666
label define lblmain_use_card 1 "Food" 2 "Hygiene" 3 "Meds" 4 "Clothes" 5 "Cleaning" 6 "Don't use the card" 7 "Save for bigger purchases" 555 "Other" .d "Don't know"
label values CCD05 lblmain_use_card

* Has had problems with the card
label var CCD06 "Problems using the card"
label define lblproblem_card 1 "Yes" 0 "No" .d "Don't know"
label values CCD06 lblproblem_card

* Specific problems with the card (example)
label var CCD07_1 "Problems using the card-not accepted at the store/market"
label define lblproblem_card_na 1 "Yes" 0 "No"
label values CCD07_1 lblproblem_card_na

label var CCD07_2 "Transfers are delayed or do not arrive"
label define lblproblem_card_transfer 1 "Yes" 0 "No"
label values CCD07_2 lblproblem_card_transfer

label var CCD07_3 "Don't know how much money you have on your card"
label define lblproblem_card_money 1 "Yes" 0 "No"
label values CCD07_3 lblproblem_card_money

label var CCD07_4 "Don't know the password"
label define lblproblem_card_password 1 "Yes" 0 "No"
label values CCD07_4 lblproblem_card_password

label var CCD07_555 "Other"
label define lblproblem_card_other 1 "Yes" 0 "No"
label values CCD07_555 lblproblem_card_other

label var CCD07_666 "Don't know"
label define lblproblem_card_dk 1 "Yes" 0 "No"
label values CCD07_666 lblproblem_card_dk

* Tried to get the card
label var CCD08 "Try to get the Citizen Card from the Devolve-ICMS program"
label define lblget_card 1 "Yes" 0 "No" .d "Don't know"
label values CCD08 lblget_card

* Reasons for not getting the card (example)
label var CCD09_1 "Don't collect the card because of location"
label define lblcard_collection_l 1 "Yes" 0 "No"
label values CCD09_1 lblcard_collection_l

label var CCD09_2 "Don't collect the card because of distance"
label define lblcard_collection_d 1 "Yes" 0 "No"
label values CCD09_2 lblcard_collection_d

label var CCD09_3 "Don't collect the card because of take care kids"
label define lblcard_collection_k 1 "Yes" 0 "No"
label values CCD09_3 lblcard_collection_k

label var CCD09_4 "Don't collect the card because of work"
label define lblcard_collection_w 1 "Yes" 0 "No"
label values CCD09_4 lblcard_collection_w

label var CCD09_5 "Don't collect the card because money for transport"
label define lblcard_collection_t 1 "Yes" 0 "No"
label values CCD09_5 lblcard_collection_t

label var CCD09_6 "Don't collect the card because didn't know could participate"
label define lblcard_collection_p 1 "Yes" 0 "No"
label values CCD09_6 lblcard_collection_p

label var CCD09_7 "Don't collect the card because didn't know the program"
label define lblcard_collection_dp 1 "Yes" 0 "No"
label values CCD09_7 lblcard_collection_dp

label var CCD09_555 "Don't collect the card because of other"
label define lblcard_collection_other 1 "Yes" 0 "No"
label values CCD09_555 lblcard_collection_other

label var CCD09_666 "Don't collect the card because don't know"
label define lblcard_collection_dk 1 "Yes" 0 "No"
label values CCD09_666 lblcard_collection_dk

* Concern about nearby stores
label var CCD10 "Not stores nearby"
replace CCD10 = .d if CCD10 == 666
label define lblstores_nearby 1 "Very worried" 2 "Worried" 3 "A little worried" 4 "No worried" .d "Don't know"
label values CCD10 lblstores_nearby

* Concern about knowing how to use the card
label var CCD11 "Level of concern about using the card"
replace CCD11 = .d if CCD11 == 666
label define lblcard_use_worry 1 "Very worried" 2 "Worried" 3 "A little worried" 4 "No worried" .d "Don't know"
label values CCD11 lblcard_use_worry

* Concern about unauthorized use
label var CCD12 "Level of worry about unauthorized card use by household members"
replace CCD12 = .d if CCD12 == 666
label define lblworry_unauthorized_card 1 "Very worried" 2 "Worried" 3 "A little worried" 4 "No worried" .d "Don't know"
label values CCD12 lblworry_unauthorized_card

* Reason for not picking up the card
label var CCD13 "Reason for not picking up the card"

* Income inequality is a problem
label var IET01 "Income inequality is a serious problem in Brazil."
replace IET01 = .d if IET01 == 666
label define lblinequality_brazil 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree" .d "Don't know"
label values IET01 lblinequality_brazil

* Government should tax the rich more
label var IET02 "Tax Collection"
replace IET02 = .d if IET02 == 666
label define lbltax_collection 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree" .d "Don't know"
label values IET02 lbltax_collection

* Preference for income tax
label var IET03 "Preference for government revenue from taxes on income/wealth vs. consumption"
replace IET03 = .d if IET03 == 666
label define lbltax_revenue_preference 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree" .d "Don't know"
label values IET03 lbltax_revenue_preference

* Lower taxes on essentials
label var IET04 "Support for lower taxes on essential goods like food"
replace IET04 = .d if IET04 == 666
label define lbltax_essential_goods 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree" .d "Don't know"
label values IET04 lbltax_essential_goods

* ICMS rate
label var IET05 "ICMS rate on most goods in Rio Grande do Sul"
replace IET05 = .d if IET05 == -9

label var IET05a "ICMS rate on most goods in Rio Grande do Sul"
replace IET05a = .d if IET05a == 666
label define lblicms_rate_rgs 1 "Less than 5%" 2 "Between 5-10%" 3 "Between 10-20%" 4 "Between 20-30%" 5 "Between 30-40%" 6 "More than 40%" .d "Don't know"
label values IET05a lblicms_rate_rgs

* CPF on invoice rule
label var IET06 "Consideration of CPF inclusion rule for Devolve ICMS program"
replace IET06 = .d if IET06 == 666
label define lblcpf_on_invoice_rule 1 "Strongly Fair" 2 "Fair" 3 "Not Fair" 4 "Strongly Unfair" .d "Don't know"
label values IET06 lblcpf_on_invoice_rule

* Increase tax on food
label var IET07 "Support for equalizing tax on food with other products, even if it increases food costs"
replace IET07 = .d if IET07 == 666
label define lblincrease_tax_on_food 1 "Totally in favor" 2 "Favor" 3 "Against" 4 "Totally against" .d "Don't know"
label values IET07 lblincrease_tax_on_food

* Increase tax on food with reimbursement
label var IET08 "Support for increasing tax on food if Devolve program participants receive reimbursement"
replace IET08 = .d if IET08 == 666
label define lbltax_on_foodreturned 1 "Totally in favor" 2 "Favor" 3 "Against" 4 "Totally against" .d "Don't know"
label values IET08 lbltax_on_foodreturned

* Increase tax on food for all
label var IET09 "Support for increasing tax on food if all residents of Rio Grande do Sul receive reimbursement"
replace IET09 = .d if IET09 == 666
label define lbltax_food_all 1 "Totally in favor" 2 "Favor" 3 "Against" 4 "Totally against" .d "Don't know"
label values IET09 lbltax_food_all

* Reduce tax on perfumes/makeup
label var IET10 "Support for reducing tax on perfumes and makeup to match other products"
replace IET10 = .d if IET10 == 666
label define lbltax_perfumes_makeup 1 "Totally in favor" 2 "Favor" 3 "Against" 4 "Totally against" .d "Don't know"
label values IET10 lbltax_perfumes_makeup

* Familiarity with Nota Fiscal Gaúcha
label var NFG01 "Familiarity with the Nota Fiscal Gaúcha program"
replace NFG01 = .d if NFG01 == 666
label define lblnota_fiscal_program 1 "Yes" 0 "No" .d "Don't know"
label values NFG01 lblnota_fiscal_program

* Participates in NFG
label var NFG02 "Participates Nota Fiscal Gaúcha program"
replace NFG02 = .d if NFG02 == 666
label define lblparticipate_nfg 0 "No" 1 "Yes" .d "Don't know"
label values NFG02 lblparticipate_nfg

* Reason for not participating in NFG
label var NFG02A "Main reason for not participating in the Nota Fiscal Gaúcha program"
replace NFG02A = .d if NFG02A == 666
label define lblreason_nfg 1 "Registration" 2 "Information" 3 "Government distrusts" 4 "Program requirements" 5 "Registration attempt failed" 555 "Other" .d "Don't know"
label values NFG02A lblreason_nfg

* Wants to receive information about the program
label var NFG03 "Send information on how to apply for the program"
label define lblsend_information 1 "Yes" 0 "No" .d "Don't know"
label values NFG03 lblsend_information

* Preferred channel to receive information
label var NFG031 "Preferred method of receiving information: SMS or Whatsapp"
replace NFG031 = .d if NFG031 == 666
label define lblsend_information_method 1 "SMS" 2 "Whatsapp" .d "Don't know"
label values NFG031 lblsend_information_method

* Municipality
label var DEM01 "Municipality"

* Age
label var DEM02 "Age"
replace DEM02 = .d if DEM02 == -9

* Gender
label var DEM03 "Gender"
label define lblgender 1 "Male" 0 "Female" .d "Don't know"
label values DEM03 lblgender

* Income
label var DEM04 "Income including benefits per month"
replace DEM04 = .d if DEM04 == 666
label define lblincome 1 "Less than 600" 2 "600-1,000" 3 "1,000-1,500" 4 "1,500-2,000" 5 "2,000-3,000" 6 "More than 3,000" .d "Don't know"
label values DEM04 lblincome

* Number of people in the household
label var DEM05 "Total number of people living in the household (including yourself)"

* Impact of floods
label var INU01 "Impact of this year's floods on you or your family"
label define lblflood_impact 1 "Yes" 0 "No" .d "Don't know"
label values INU01 lblflood_impact

label var INU02 "Impact of this year's floods on you or your family"
replace INU02 = .d if INU02 == 666
label define lblflood_impact2 1 "Small" 2 "Medium" 3 "Big" 4 "Very big" .d "Don't know"
label values INU02 lblflood_impact2

label var INU03 "Had to leave home during heavy rains in Rio Grande do Sul this year"
label define lbldisplaced_rains 1 "Yes" 0 "No" .d "Don't know"
label values INU03 lbldisplaced_rains

label var INU03a "Days Unable to Enter Home Due to Floods"

label var INU04 "Received assistance to recover from this year's floods"
label define lblflood_aid 1 "Yes" 0 "No" .d "Don't know"
label values INU04 lblflood_aid

* Types of aid received (example)
label var INU04a_1 "Received assistance to recover from this year's floods-money"
label define lblaid_finance 0 "No" 1 "Yes" .d "Don't know"
label values INU04a_1 lblaid_finance

label var INU04a_2 "Received assistance to recover from this year's floods-material"
label define lblaid_material 0 "No" 1 "Yes" .d "Don't know"
label values INU04a_2 lblaid_material

label var INU04a_3 "Received assistance to recover from this year's floods-medical assistance"
label define lblaid_medic 0 "No" 1 "Yes" .d "Don't know"
label values INU04a_3 lblaid_medic

label var INU04a_4 "Received assistance to recover from this year's floods-cleaning"
label define lblaid_cleaning 0 "No" 1 "Yes" .d "Don't know"
label values INU04a_4 lblaid_cleaning

label var INU04a_5 "Received assistance to recover from this year's floods-reconstruction"
label define lblaid_reconstruction 0 "No" 1 "Yes" .d "Don't know"
label values INU04a_5 lblaid_reconstruction

label var INU04a_555 "Received assistance to recover from this year's floods-other"
label define lblaid_other 0 "No" 1 "Yes" .d "Don't know"
label values INU04a_555 lblaid_other

label var INU04a_666 "Received assistance to recover from this year's floods-don't know"
label define lblaid_dk 1 "Yes" 0 "No" .d "Don't know"
label values INU04a_666 lblaid_dk

* Dropping variables with only missing values
ds, has(type numeric)
foreach var of varlist `r(varlist)' {
	quietly count if `var' != .
	if r(N) == 0 {
		di as txt "Dropped numeric variable: `var'"
		drop `var'
	}
}

ds, has(type string)
foreach var of varlist `r(varlist)' {
	quietly count if !missing(`var')
	if r(N) == 0 {
		di as txt "Dropped string variable: `var'"
		drop `var'
	}
}

* Dropping internal vars
drop starttime endtime

* Save cleaned .dta file
save "${dropbox}\data\intermediary\devolve_survey_clean.dta", replace // 1039 obs and 232 vars


* End of the script