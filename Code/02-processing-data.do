* Description: This script processes the Devolve-ICMS survey data and labeling variables for analysis. 


*-------------------------------------------------------------------------------	
* Loading dataset
*------------------------------------------------------------------------------- 		
	
	use "C:\Users\gabri\Dropbox\Survey_DevolveICMS\Databases\devolve_survey_jan.dta", replace // 1,039 obs and 236 variables 

*-------------------------------------------------------------------------------	
* Cleaning process- label variables survey
*------------------------------------------------------------------------------- 		
 
 
   * Type of phone 
   
    gen phone_type=tipotelefone
	
	label var phone_type "Phone type of the call"
	
	la de lblphone_type 1 "Cellular" 2 "Landline telephone"
	
	label values phone_type lblphone_type
	
	*Age (over 18)
								
	gen age_over18=idade1
	
	label var age_over18 "Are you over 18?"
	
	la de lblage_over18 1 "Yes" 2 "No"
	
	label values age_over18 lblage_over18
    
	*Head of household 
	
	gen hh=telefone
	
	label var hh "Are you the adult responsible for decisions in your home or could you call someone else who you consider responsible?"
	
	la de lblhh 1 "Yes" 2 "No, but call transfered to the hh" 3 "No, and you did not transfer the call to hh"
	
	label values hh lblhh
	
	*Familiarity with Devolve-ICMS program 
	
	gen know_devolve= DEV01
	
	label var know_devolve "Are you familiar with the Devolve-ICMS program?"
	
	la de lblknow_devolve 1 "Yes" 2 "No" 666 "Don't know"
	
	label values know_devolve lblknow_devolve
	
	*Today, do you and your family who lives in the same household as you participate in the Devolve-ICMS program?
	
	gen participates_devolve= DEVPAR01
	
	label var participates_devolve "Do you and your family who lives in the same household as you participate in the Devolve?"
	
	la de lblparticipates_devolve 1 "Yes" 2 "No" 3 "Does not currently participate" 666 "Don't know"
	
	label values participates_devolve lblparticipates_devolve
	
	
	*How did you find out you were part of the program?
	
	gen program_discovery= DEVPAR02
	
	label var program_discovery "Do you and your family who lives in the same household as you participate in the Devolve?"
	
	la de lblprogram_discovery 1 "CRAS" 2 "Traditional media" 3 "Internet or Social Media" 4 "Family member or friend" 555 "Other" 666 "Don't know"
	
	label values program_discovery lblprogram_discovery
	
	*Does anyone you know participate in the program?
	
	gen knows_participant= DEV02
	
	label var knows_participant "Does anyone you know participate in the program?"
	
	la de lblknows_participant 1 "Yes" 2 "No" 666 "Don't know"
	
	label values knows_participant lblknows_participant
	
	
	*Who are the other participants in the program that you know?- Family
	
	 gen other_beneficiaries_family= DEV02a_1
	 
	recode other_beneficiaries_family 0=2
	
	label var other_beneficiaries_family "Who are the other participants in the program that you know?- Family"
	
	la de lblother_beneficiaries_family 1 "Yes" 2 "No" 
	
	label values other_beneficiaries_family lblother_beneficiaries_family
	
	*Who are the other participants in the program that you know?- Friends
	
	 gen other_beneficiaries_friends= DEV02a_2
	 
	recode other_beneficiaries_friends 0=2
	
	label var other_beneficiaries_friends "Who are the other participants in the program that you know?- Friends"
	
	la de lblother_beneficiaries_friends 1 "Yes" 2 "No" 
	
	label values other_beneficiaries_friends lblother_beneficiaries_friends
	
	*Who are the other participants in the program that you know?- community leaders
	
	 gen other_beneficiaries_leaders= DEV02a_3
	 
	recode other_beneficiaries_leaders 0=2
	
	label var other_beneficiaries_leaders "Who are the other participants in the program that you know?- leaders"
	
	la de lblother_beneficiaries_leaders 1 "Yes" 2 "No" 
	
	label values other_beneficiaries_leaders lblother_beneficiaries_leaders
	
	
	*Who are the other participants in the program that you know?- other
	
	 gen other_beneficiaries_other= DEV02a_555
	 
	recode other_beneficiaries_other 0=2
	
	label var other_beneficiaries_other "Who are the other participants in the program that you know?- leaders"
	
	la de lblother_beneficiaries_other 1 "Yes" 2 "No" 
	
	label values other_beneficiaries_other lblother_beneficiaries_other
	
	
	*Who are the other participants in the program that you know?- other
	
	 gen other_beneficiaries_dontknow= DEV02a_666
	 
	recode other_beneficiaries_dontknow 0=2
	
	label var other_beneficiaries_dontknow "Who are the other participants in the program that you know?- leaders"
	
	la de lblother_beneficiaries_dontknow 1 "Yes" 2 "No" 
	
	label values other_beneficiaries_dontknow lblother_beneficiaries_dontknow
	
	*Why does this money go into the participants' accounts?
	
	 gen reason_money_accounts= DEV03
	 
	label var reason_money_accounts "Requirements Devolve program"
	
	la de lblreason_money_accounts 1 "Money part of the Bolsa Família" 2 "Tax refund for purchases" 3 "Government aid for school attendance" 4 "State-level Bolsa Família" 555 "Other" 666 "Don't know"
	
	label values reason_money_accounts lblreason_money_accounts
	
	
	
	*According to your knowledge, choose the answer that shows everything a family living in Rio Grande do Sul needs to  participate in the Devolve-ICMS program:
	
	 gen program_eligilibility= DEV04
	 
	label var program_eligilibility "Requirements Devolve program"
	
	la de lblprogram_eligilibility  1 "Bolsa Familia/Highschool" 2 "Family Income < 3 Wages" 3 "Adult's CPF Active" 4 "All alternatives" 555 "Other" 666 "Don't know"
	
	label values program_eligilibility lblprogram_eligilibility
	
	*The Devolve-ICMS program deposits money into the Devolve ICMS Citizen Card of families participating in the program. Do you know how many times this deposit is made?
	
	 gen deposit_frequency= DEV05
	 
	label var deposit_frequency "Frequency payments program"
	
	la de lbldeposit_frequency 666 "Don't know"
	
	label values deposit_frequency lbldeposit_frequency
	
	
	*Every three months, at least 100 reais are deposited on the Citizen ICMS Return Card.
	
	 gen quarterly_deposit= DEV06
	 
	label var quarterly_deposit "Every three months, at least 100 reais are deposited on the Citizen ICMS Return Card"
	
	la de lblquarterly_deposit 1 "True" 2 "False" 666 "Don't know"
	
	label values quarterly_deposit lblquarterly_deposit
	
	*The more a family includes the CPF registered in the program on their purchase invoices, the more money they will be able to receive from the Devolve ICMS Program.
	
	 gen usage_increases= DEV07
	 
	label var usage_increases "CPF usage on invoices increases benefits in the Devolve ICMS Program."
	
	la de lblusage_increases 1 "True" 2 "False" 666 "Don't know"
	
	label values usage_increases lblusage_increases
	
	
	*Devolve-ICMS provides a debit card called Cartão Cidadão through which people receive reimbursement. What happens if the money on the Devolve-ICMS card is not used in full within a month?
	
	 gen unused_funds= DEV08
	 
	label var unused_funds "Unused funds on Devolve-ICMS card after a month."
	
	la de lblunused_funds 1 "All is lost" 2 "Some remains available n/m" 3 "All available for n/m" 555 "Other" 666 "Don't know"
	
	label values unused_funds lblunused_funds
	
	
	*Which of the following payment methods do you use to make purchases on a daily basis?-cash
	
	 gen payment_method_cash= PAG01_1
	 
	 recode payment_method_cash 0=2
	 
	label var payment_method_cash "Payment methods do you use to make purchases on a daily basis-cash"
	
	la de lblpayment_method_cash 1 "Yes" 2 "No" 
	
	label values payment_method_cash lblpayment_method_cash
	
	*Which of the following payment methods do you use to make purchases on a daily basis?-debit
	
	 gen payment_method_debit= PAG01_2
	 
	 recode payment_method_debit 0=2
	 
	label var payment_method_debit "Payment methods do you use to make purchases on a daily basis-debit"
	
	la de lblpayment_method_debit 1 "Yes" 2 "No" 
	
	label values payment_method_debit lblpayment_method_debit
	
	
	*Which of the following payment methods do you use to make purchases on a daily basis?-credit
	
	 gen payment_method_credit= PAG01_3
	 
	 recode payment_method_credit 0=2
	 
	label var payment_method_credit "Payment methods do you use to make purchases on a daily basis-credit"
	
	la de lblpayment_method_credit 1 "Yes" 2 "No" 
	
	label values payment_method_credit lblpayment_method_credit
	
	
	*Which of the following payment methods do you use to make purchases on a daily basis?-PIX
	
	 gen payment_method_pix= PAG01_4
	 
	 recode payment_method_pix 0=2
	 
	label var payment_method_pix "Payment methods do you use to make purchases on a daily basis-PIX"
	
	la de lblpayment_method_pix 1 "Yes" 2 "No" 
	
	label values payment_method_pix lblpayment_method_pix
	
	*Which of the following payment methods do you use to make purchases on a daily basis?-mobile apps
	
	 gen payment_method_mobile= PAG01_5
	 
	 recode payment_method_mobile 0=2
	 
	label var payment_method_mobile "Payment methods do you use to make purchases on a daily basis-mobile apps"
	
	la de lblpayment_method_mobile 1 "Yes" 2 "No" 
	
	label values payment_method_mobile lblpayment_method_mobile
	
	
	*Which of the following payment methods do you use to make purchases on a daily basis?-other
	
	 gen payment_method_other= PAG01_666
	 
	 recode payment_method_other 0=2
	 
	label var payment_method_other "Payment methods do you use to make purchases on a daily basis-other"
	
	la de lblpayment_method_other 1 "Yes" 2 "No" 
	
	label values payment_method_other lblpayment_method_other
	
	*What payment method do you consider most convenient for making your daily purchases?
	
	 gen payment_method_daily= PAG04
	 
	label var payment_method_daily "Payment methods daily purchases"
	
	la de lblpayment_method_daily 1 "Cash" 2 "Debit/Credit" 3 "PIX" 4 "Mobile apps" 666 "Other" 
	
	label values payment_method_daily lblpayment_method_daily
	
	*Purchases you made last week with cash 
	
	 gen purchases_last_week= PAG02
	 
	label var purchases_last_week "Purchases made last week"
	
	
	la de lblpurchases_last_week  1 "All or almost all" 2 "More than half" 3 "Half" 4 "Less than half" 5 "None or almost none" 666 "Don't know"
	
	label values purchases_last_week lblpurchases_last_week
	
	
	*Do you or other family members who live with you have an account at a bank or financial institution?
	
	 gen hh_bank_account= PAG03
	 
	label var hh_bank_account "Household has bank acount"
	
	la de lblhh_bank_account  1 "Yes, you have"  2 "Yes, other person have" 3 "Yes, you and other family members have" 4 "No, neither you nor anyone" 666 "Don't know"
	
	label values hh_bank_account lblhh_bank_account
	
	
	
	*What banks or financial institutions do you and other family members living with you have accounts at?- banco do brasil 
	
	 gen bank_account_brasil= PAG03a_1
	 
	 recode bank_account_brasil 0=2
	 
	label var bank_account_brasil "Bank account Banco do Brasil"
	
	la de lblbank_account_brasil 1 "Yes" 2 "No" 
	
	label values bank_account_brasil lblbank_account_brasil
	
	*What banks or financial institutions do you and other family members living with you have accounts at?- banco bradesco
	
	 gen bank_account_bradesco= PAG03a_2
	 
	 recode bank_account_bradesco 0=2
	 
	label var bank_account_bradesco "Bank account Banco Bradesco"
	
	la de lblbank_account_bradesco 1 "Yes" 2 "No" 
	
	label values bank_account_bradesco lblbank_account_bradesco
	
	*What banks or financial institutions do you and other family members living with you have accounts at?- banco itau
	
	 gen bank_account_itau= PAG03a_3
	 
	 recode bank_account_itau 0=2
	 
	label var bank_account_itau "Bank account Itau"
	
	la de lblbank_account_itau 1 "Yes" 2 "No" 
	
	label values bank_account_itau lblbank_account_itau
	
	*What banks or financial institutions do you and other family members living with you have accounts at?- banco santander
	
	 gen bank_account_santander= PAG03a_4
	 
	 recode bank_account_santander 0=2
	 
	label var bank_account_santander "Bank account Santander"
	
	la de lblbank_account_santander 1 "Yes" 2 "No" 
	
	label values bank_account_santander lblbank_account_santander
	
	*What banks or financial institutions do you and other family members living with you have accounts at?- nubank
	
	 gen bank_account_nubank= PAG03a_5
	 
	 recode bank_account_nubank 0=2
	 
	label var bank_account_nubank "Bank account Nubank"
	
	la de lblbank_account_nubank 1 "Yes" 2 "No" 
	
	label values bank_account_nubank lblbank_account_nubank
	
	
	*What banks or financial institutions do you and other family members living with you have accounts at?- banco inter
	
	 gen bank_account_inter= PAG03a_6
	 
	 recode bank_account_inter 0=2
	 
	label var bank_account_inter "Bank account banco Inter"
	
	la de lblbank_account_inter 1 "Yes" 2 "No" 
	
	label values bank_account_inter lblbank_account_inter
	
	*What banks or financial institutions do you and other family members living with you have accounts at?- C6 Bank
	
	 gen bank_account_c6= PAG03a_7
	 
	 recode bank_account_c6 0=2
	 
	label var bank_account_c6 "Bank account banco C6"
	
	la de lblbank_account_c6 1 "Yes" 2 "No" 
	
	label values bank_account_c6 lblbank_account_c6
	
	*What banks or financial institutions do you and other family members living with you have accounts at?- Banrisul
	
	 gen bank_account_banrisul= PAG03a_8
	 
	 recode bank_account_banrisul 0=2
	 
	label var bank_account_banrisul "Bank account banco Banrisul"
	
	la de lblbank_account_banrisul 1 "Yes" 2 "No" 
	
	label values bank_account_banrisul lblbank_account_banrisul
	
	
	*What banks or financial institutions do you and other family members living with you have accounts at?- Pagbank
	
	 gen bank_account_pagbank= PAG03a_9
	 
	 recode bank_account_pagbank 0=2
	 
	label var bank_account_pagbank "Bank account banco Pagbank"
	
	la de lblbank_account_pagbank 1 "Yes" 2 "No" 
	
	label values bank_account_pagbank lblbank_account_pagbank
	
	*What banks or financial institutions do you and other family members living with you have accounts at?- Picpagy
	
	 gen bank_account_picpay= PAG03a_10
	 
	 recode bank_account_picpay 0=2
	 
	label var bank_account_picpay "Bank account banco Picpay"
	
	la de lblbank_account_picpay 1 "Yes" 2 "No" 
	
	label values bank_account_picpay lblbank_account_picpay
	
	*What banks or financial institutions do you and other family members living with you have accounts at?- Agibank
	
	 gen bank_account_agibank= PAG03a_11
	 
	 recode bank_account_agibank 0=2
	 
	label var bank_account_agibank "Bank account banco Agibank"
	
	la de lblbank_account_agibank 1 "Yes" 2 "No" 
	
	label values bank_account_agibank lblbank_account_agibank
	
	
	*What banks or financial institutions do you and other family members living with you have accounts at?- Sicredi
	
	 gen bank_account_sicredi= PAG03a_12
	 
	 recode bank_account_sicredi 0=2
	 
	label var bank_account_sicredi "Bank account banco Sicredi"
	
	la de lblbank_account_sicredi 1 "Yes" 2 "No" 
	
	label values bank_account_sicredi lblbank_account_sicredi
	
	
	*What banks or financial institutions do you and other family members living with you have accounts at?- Caixa Econômica Federal
	
	 gen bank_account_caixa= PAG03a_13
	 
	 recode bank_account_caixa 0=2
	 
	label var bank_account_caixa "Bank account banco Caixa"
	
	la de lblbank_account_caixa 1 "Yes" 2 "No" 
	
	label values bank_account_caixa lblbank_account_caixa
	
	
	*What banks or financial institutions do you and other family members living with you have accounts at?- other
	
	 gen bank_account_other= PAG03a_555
	 
	 recode bank_account_other 0=2
	 
	label var bank_account_other "Bank account banco Other"
	
	la de lblbank_account_other 1 "Yes" 2 "No" 
	
	label values bank_account_other lblbank_account_other
	
	
	*What banks or financial institutions do you and other family members living with you have accounts at?- don't know
	
	 gen bank_account_dontknow= PAG03a_666
	 
	 recode bank_account_dontknow 0=2
	 
	label var bank_account_dontknow "Bank account banco don't know"
	
	la de lblbank_account_dontknow 1 "Yes" 2 "No" 
	
	label values bank_account_dontknow lblbank_account_dontknow
	
	
	*Does the store where you shop most often give you a receipt?
	
	 gen store_receipt= NFI01
	 
	label var store_receipt "Does the store where you shop most often give you a receipt?"
	
	la de lblstore_receipt 1 "Yes" 2 "No" 666 "Don't know"
	
	label values store_receipt lblstore_receipt
	
	
	*Please indicate the main reason why you choose to shop there instead of going to stores that issue receipts?
	
	 gen reason_no_receipt= NFI01a
	 
	label var reason_no_receipt "Main reason no receipt store"
	
	la de lblreason_no_receipt 1 "Not ask for invoices" 2 "Stores are cheaper" 3 "Distance"  4 "Access" 555  "Other" 666 "Don't know"
	
	label values reason_no_receipt lblreason_no_receipt
	
	*How much of your consumption comes from stores where the attendant asks if you want to include your CPF on the purchase receipt?
	
	 gen consumption_receipt= NFI02
	 
	label var consumption_receipt "Percentage of consumption from stores asking to include CPF on receipt"
	
	la de lblconsumption_receipt 1 "All or almost everythinhg" 2 "More than half" 3 "Half"  4 "Less than half" 5 "Nothing or almost nothing"  666 "Don't know"
	
	label values consumption_receipt lblconsumption_receipt
	
	*When you include the CPF on the purchase invoice, which CPF do you usually use?
	
	 gen type_cpf= NFI03
	 
	label var type_cpf "Type CPF for purchase invoice"
	
	la de lbltype_cpf 1 "Own" 2 "Family member" 3 "Don't use it" 555 "Other" 666 "Don't know"
	
	label values type_cpf lbltype_cpf
	
	
	*How often do you include someone else's CPF on the invoice?
	
	 gen freq_cpf= NFI03a
	 
	label var freq_cpf "Frequency CPF use"
	
	la de lblfreq_cpf 1 "Always" 2 "Sometimes" 3 "Rarely" 4 "Never" 666 "Don't know"
	
	label values freq_cpf lblfreq_cpf
	
	*How often do the store attendants you visit ask you if you want to include your CPF on your purchase receipt?
	
	 gen cpf_invoice= NFI04
	 
	label var cpf_invoice "Frequency CPF on the invoice"
	
	la de lblcpf_invoice 1 "Always" 2 "Sometimes" 3 "Rarely" 4 "Never" 666 "Don't know"
	
	label values cpf_invoice lblcpf_invoice
	
	
	*When the attendant asks you if you want to include your CPF on the purchase invoice, how often do you usually include your CPF on the invoice?
	
	 gen cpf_invoice_freq= NFI04a
	 
	label var cpf_invoice_freq "Frequency CPF on the invoice"
	
	la de lblcpf_invoice_freq 1 "Always" 2 "Sometimes" 3 "Rarely" 4 "Never" 666 "Don't know"
	
	label values cpf_invoice_freq lblcpf_invoice_freq
	
	
	*For what reason(s) do you not include your CPF number on the invoice?
	
	 gen reason_not_cpf_time= NFI04a1_1
	 
	 recode reason_not_cpf_time 0=2
	 
	label var reason_not_cpf_time "Reasons not to include CPF time"
	
	la de lblreason_not_cpf_time 1 "Yes" 2 "No"
	
	label values reason_not_cpf_time lblreason_not_cpf_time
	
	
	*For what reason(s) do you not include your CPF number on the invoice?
	
	 gen reason_not_cpf_number= NFI04a1_2
	 
	 recode reason_not_cpf_number 0=2
	 
	label var reason_not_cpf_number "Reasons not to include CPF don't know the number"
	
	la de lblreason_not_cpf_number 1 "Yes" 2 "No"
	
	label values reason_not_cpf_number lblreason_not_cpf_number
	
	*For what reason(s) do you not include your CPF number on the invoice?
	
	 gen reason_not_cpf_interest= NFI04a1_4
	 
	 recode reason_not_cpf_interest 0=2
	 
	label var reason_not_cpf_interest "Reasons not to include CPF not interested"
	
	la de lblreason_not_cpf_interest 1 "Yes" 2 "No"
	
	label values reason_not_cpf_interest lblreason_not_cpf_interest
	
	*For what reason(s) do you not include your CPF number on the invoice?
	
	 gen reason_not_cpf_benefits= NFI04a1_3
	 
	 recode reason_not_cpf_benefits 0=2
	 
	label var reason_not_cpf_benefits "Reasons not to include CPF don't know the benefits"
	
	la de lblreason_not_cpf_benefits 1 "Yes" 2 "No"
	
	label values reason_not_cpf_benefits lblreason_not_cpf_benefits
	
	*For what reason(s) do you not include your CPF number on the invoice?
	
	 gen reason_not_cpf_inofrmation= NFI04a1_5
	 
	 recode reason_not_cpf_inofrmation 0=2
	 
	label var reason_not_cpf_inofrmation "Reasons not to include CPF not sharing info"
	
	la de lblreason_not_cpf_inofrmation 1 "Yes" 2 "No"
	
	label values reason_not_cpf_inofrmation lblreason_not_cpf_inofrmation
	
	
	*For what reason(s) do you not include your CPF number on the invoice?
	
	 gen reason_not_cpf_other= NFI04a1_555
	 
	 recode reason_not_cpf_other 0=2
	 
	label var reason_not_cpf_other "Reasons not to include CPF other"
	
	la de lblreason_not_cpf_other 1 "Yes" 2 "No"
	
	label values reason_not_cpf_other lblreason_not_cpf_other
	
	
	*And when the attendant DOES NOT ask you if you want to include your CPF on the purchase invoice, how often do you ask to include your CPF on the invoice?
	
	 gen freq_cpf_na= NFI04b
	 
	label var freq_cpf_na "Frequency of CPF use when attendence does not ask"
	
	la de lblfreq_cpf_na 1 "Always" 2 "Sometimes" 3 "Rarely" 4 "Never" 666 "Don't know"
	
	label values freq_cpf_na lblfreq_cpf_na
	
	
	*For what reason(s) do you not include your CPF number on the invoice?
	
	 gen reason_not_cpf_time_da= NFI04b1_1
	 
	 recode reason_not_cpf_time_da 0=2
	 
	label var reason_not_cpf_time_da "Reasons not to include CPF time"
	
	la de lblreason_not_cpf_time_da 1 "Yes" 2 "No"
	
	label values reason_not_cpf_time_da lblreason_not_cpf_time_da
	
	
	*For what reason(s) do you not include your CPF number on the invoice?
	
	 gen reason_not_cpf_number_da= NFI04b1_2
	 
	 recode reason_not_cpf_number_da 0=2
	 
	label var reason_not_cpf_number_da "Reasons not to include CPF don't know the number"
	
	la de lblreason_not_cpf_number_da 1 "Yes" 2 "No"
	
	label values reason_not_cpf_number_da lblreason_not_cpf_number_da
	
	*For what reason(s) do you not include your CPF number on the invoice?
	
	 gen reason_not_cpf_interest_dat= NFI04b1_4
	 
	 recode reason_not_cpf_interest_dat 0=2
	 
	label var reason_not_cpf_interest_dat "Reasons not to include CPF not interested"
	
	la de lblreason_not_cpf_interest_dat 1 "Yes" 2 "No"
	
	label values reason_not_cpf_interest_dat lblreason_not_cpf_interest_dat
	
	*For what reason(s) do you not include your CPF number on the invoice?
	
	 gen reason_not_cpf_benefits_da= NFI04b1_3
	 
	 recode reason_not_cpf_benefits_da 0=2
	 
	label var reason_not_cpf_benefits_da "Reasons not to include CPF don't know the benefits"
	
	la de lblreason_not_cpf_benefits_da 1 "Yes" 2 "No"
	
	label values reason_not_cpf_benefits_da lblreason_not_cpf_benefits_da
	
	*For what reason(s) do you not include your CPF number on the invoice?
	
	 gen reason_not_cpf_inofrmation_da= NFI04b1_5
	 
	 recode reason_not_cpf_inofrmation_da 0=2
	 
	label var reason_not_cpf_inofrmation_da "Reasons not to include CPF not sharing info"
	
	la de lblreason_not_cpf_inofrmation_da 1 "Yes" 2 "No"
	
	label values reason_not_cpf_inofrmation_da lblreason_not_cpf_inofrmation_da
	
	
	*For what reason(s) do you not include your CPF number on the invoice?
	
	 gen reason_not_cpf_other_da= NFI04b1_555
	 
	 recode reason_not_cpf_other_da 0=2
	 
	label var reason_not_cpf_other_da "Reasons not to include CPF other"
	
	la de lblreason_not_cpf_other_da 1 "Yes" 2 "No"
	
	label values reason_not_cpf_other_da lblreason_not_cpf_other_da
	
	*Considering all the purchases you make for yourself and your family living with you throughout the month, approximately how much do you spend?
	
	 gen monthly_purchases= NFI05
	 
	label var monthly_purchases "Monthly Purchases"
	
	label values monthly_purchases lblmonthly_purchases
	
	
	
	*And according to the following options, considering all the purchases you make for yourself and your family who lives with you, how much approximately do you spend throughout the month?
	
	 gen monthly_spend= NFI05a
	 
	label var monthly_spend "Monthly Spend"
	
	la de lblmonthly_spend 1 "0-500" 2 "500-1,000" 3 "1,000-1,500" 4 "1,500-2,000" 5 "more than 2,000" 666 "Don't know"
	
	label values monthly_spend lblmonthly_spend
	
	
	*Do you have the Citizen Card from the Devolve-ICMS program?
	
	 gen card_devolve= CCD01
	 
	label var card_devolve "have the Citizen Card from the Devolve-ICMS program"
	
	label define lblcard_devolve 1 "Yes" ///
    2 "Yes, but NOT receive the benefit" ///
    3 "No" ///
    666 "Don't know"
	
	label values card_devolve lblcard_devolve
	
	
	
	*How often do you include your CPF on your purchase receipts today?
	
	gen cpf_receipt_freq= CCD02
	 
	label var cpf_receipt_freq "CPF Inclusion Frequency on Receipts"
	
	la de lblcpf_receipt_freq 1 "With more frequency" 2 "With the same frequency" 3 "With the less frequency" 666 "Don't know"
	
	label values cpf_receipt_freq lblcpf_receipt_freq
	
	
	
	
	*How long does it take to spend the amounts you receive on your Devolve card?
	
	 gen spend_value= CCD03
	 
	label var spend_value "Spend the amounts Devolve card"
	
	la de lblspend_value 1 "One day" 2 "One week" 3 "First weeks"  4 "One month" 5 "More than one month"  6 "Don't use it"   666 "Don't know"
	
	label values spend_value lblspend_value
	
	
	*How much of the money on your Citizen Card do you use?
	
	 gen use_citizen_card= CCD04
	 
	label var use_citizen_card "Use Citizen Card"
	
	la de lbluse_citizen_card 1 "All" 2 "More than half" 3 "Half"  4 "Less than half" 5 "Nothing or almost nothing"  666 "Don't know"
	
	label values use_citizen_card lbluse_citizen_card
	
	*What is the main use of your ICMS Return Citizen Card?
	
	 gen main_use_card= CCD05
	 
	label var main_use_card "Main use Citizen Card"
	
	la de lblmain_use_card 1 "Food" 2 "Hygiene" 3 "Meds"  4 "Clothes" 5 "Cleanng" 6 "Don't use the card"  7 "Save for bigger purchases" 555 "Other" 666 "Don't know"
	
	label values main_use_card lblmain_use_card
	
	
	*Have you ever had any problems when trying to use your Citizen Card from the Devolve-ICMS program?
	
	 gen problem_card= CCD06
	 
	label var problem_card "Problems using the card"
	
	la de lblproblem_card 1 "Yes" 2 "No" 666 "Don't know"
	
	label values problem_card lblproblem_card
	
	
	*What problems did you encounter when using your Citizen Card?
	
	 gen problem_card_na= CCD07_1
	 
	 recode problem_card_na 0=2
	 
	label var problem_card_na "Problems using the card-not accepted at the store/market"
	
	la de lblproblem_card_na 1 "Yes" 2 "No" 
	
	label values problem_card_na lblproblem_card_na
	
	
	
	*What problems did you encounter when using your Citizen Card?
	
	 gen problem_card_transfer= CCD07_2
	 
	 recode problem_card_transfer 0=2
	 
	label var problem_card_transfer "Transfers are delayed or do not arrive"
	
	la de lblproblem_card_transfer 1 "Yes" 2 "No" 
	
	label values problem_card_transfer lblproblem_card_transfer
	
	
	*What problems did you encounter when using your Citizen Card?
	
	 gen problem_card_money= CCD07_3
	 
	 recode problem_card_money 0=2
	 
	label var problem_card_money "Don't know how much money you have on your card"
	
	la de lblproblem_card_money 1 "Yes" 2 "No" 
	
	label values problem_card_money lblproblem_card_money
	
	
	*What problems did you encounter when using your Citizen Card?
	
	 gen problem_card_password= CCD07_4
	 
	 recode problem_card_password 0=2
	 
	label var problem_card_password "Don't know the password"
	
	la de lblproblem_card_password 1 "Yes" 2 "No" 
	
	label values problem_card_password lblproblem_card_password
	
	
	
	*What problems did you encounter when using your Citizen Card?
	
	 gen problem_card_other= CCD07_555
	 
	 recode problem_card_other 0=2
	 
	label var problem_card_other "Other"
	
	la de lblproblem_card_other 1 "Yes" 2 "No" 
	
	label values problem_card_other lblproblem_card_other
	
	
	*What problems did you encounter when using your Citizen Card?
	
	 gen problem_card_dk= CCD07_666
	 
	 recode problem_card_dk 0=2
	 
	label var problem_card_dk "Don't know"
	
	la de lblproblem_card_dkr 1 "Yes" 2 "No" 
	
	label values problem_card_dk lblproblem_card_dk
	
	*Have you tried to get the Citizen Card from the Devolve-ICMS program?
	
	 gen get_card= CCD08
	 
	label var get_card "Try to get the Citizen Card from the Devolve-ICMS program"
	
	la de lblget_card 1 "Yes" 2 "No" 666 "Don't know"
	
	label values get_card lblget_card
	
	
	
	*For what reason(s) did you not collect your card?
	
	 gen card_collection_l= CCD09_1
	 
	 recode card_collection_l 0=2
	 
	label var card_collection_l "Don't collect the card because of location"
	
	la de lblcard_collection_l 1 "Yes" 2 "No" 
	
	label values card_collection_l lblcard_collection_l
	
	
	
	*For what reason(s) did you not collect your card?
	
	 gen card_collection_d= CCD09_2
	 
	 recode card_collection_d 0=2
	 
	label var card_collection_d "Don't collect the card because of distance"
	
	la de lblcard_collection_d 1 "Yes" 2 "No" 
	
	label values card_collection_d lblcard_collection_d
	
	
	*For what reason(s) did you not collect your card?
	
	 gen card_collection_k= CCD09_3
	 
	 recode card_collection_k 0=2
	 
	label var card_collection_k "Don't collect the card because of take care kids"
	
	la de lblcard_collection_k 1 "Yes" 2 "No" 
	
	label values card_collection_k lblcard_collection_k
	
	
	*For what reason(s) did you not collect your card?
	
	 gen card_collection_w= CCD09_4
	 
	 recode card_collection_w 0=2
	 
	label var card_collection_w "Don't collect the card because of work"
	
	la de lblcard_collection_w 1 "Yes" 2 "No" 
	
	label values card_collection_w lblcard_collection_w
	
	*For what reason(s) did you not collect your card?
	
	 gen card_collection_t= CCD09_5
	 
	 recode card_collection_t 0=2
	 
	label var card_collection_t "Don't collect the card because money for transport"
	
	la de lblcard_collection_t 1 "Yes" 2 "No" 
	
	label values card_collection_t lblcard_collection_t
	
	*For what reason(s) did you not collect your card?
	
	 gen card_collection_p= CCD09_6
	 
	 recode card_collection_p 0=2
	 
	label var card_collection_p "Don't collect the card because didn't know could participate"
	
	la de lblcard_collection_p 1 "Yes" 2 "No" 
	
	label values card_collection_p lblcard_collection_p
	
	
	
	*For what reason(s) did you not collect your card?
	
	 gen card_collection_dp= CCD09_7
	 
	 recode card_collection_dp 0=2
	 
	label var card_collection_dp "Don't collect the card because didn't know the program"
	
	la de lblcard_collection_dp 1 "Yes" 2 "No" 
	
	label values card_collection_dp lblcard_collection_dp
	
	
	
	*For what reason(s) did you not collect your card?
	
	 gen card_collection_other= CCD09_555
	 
	 recode card_collection_other 0=2
	 
	label var card_collection_other "Don't collect the card because of other"
	
	la de lblcard_collection_other 1 "Yes" 2 "No" 
	
	label values card_collection_other lblcard_collection_other
	
	
	
	*For what reason(s) did you not collect your card?
	
	 gen card_collection_dk= CCD09_555
	 
	 recode card_collection_dk 0=2
	 
	label var card_collection_dk "Don't collect the card because don't know"
	
	la de lblcard_collection_dk 1 "Yes" 2 "No" 
	
	label values card_collection_dk lblcard_collection_dk
	
	
	
	*How worried would you be about there being NO stores nearby where you could use your card?
	
	 gen stores_nearby= CCD10
	 
	label var stores_nearby "Not stores nearby"
	
	la de lblstores_nearby 1 "Very worried" 2 "Worried" 3 "A little worried" 4 "No worried" 666 "Don't know"
	
	label values stores_nearby lblstores_nearby
	
	
	
	*How much would you worry about knowing how to use the card?
	
	 gen card_use_worry= CCD11
	 
	label var card_use_worry "Level of concern about using the card"
	
	la de lblcard_use_worry 1 "Very worried" 2 "Worried" 3 "A little worried" 4 "No worried" 666 "Don't know"
	
	label values card_use_worry lblcard_use_worry
	
	
	*How worried would you be about someone in your household using your card without your permission?
	
	 gen worry_unauthorized_card= CCD12
	 
	label var worry_unauthorized_card "Level of worry about unauthorized card use by household members"
	
	la de lblworry_unauthorized_card 1 "Very worried" 2 "Worried" 3 "A little worried" 4 "No worried" 666 "Don't know"
	
	label values worry_unauthorized_card lblworry_unauthorized_card
	
	*Please indicate the reason why you were unable to pick up the card.
	
	gen reason_card= CCD13
	 
	label var reason_card "Reason for not picking up the card"
	
	
	
	
	*Income inequality is a serious problem in Brazil.
	
	 gen inequality_brazil= IET01
	 
	label var inequality_brazil "Income inequality is a serious problem in Brazil."
	
	la de lblinequality_brazil 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree" 666 "Don't know"
	
	label values inequality_brazil lblinequality_brazil
	
	
	
	*The government should collect more taxes from rich people and give more money to poor people.
	
	 gen tax_collection= IET02
	 
	label var tax_collection "Tax Collection"
	
	la de lbltax_collection 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree" 666 "Don't know"
	
	label values tax_collection lbltax_collection
	
	
	*Most of the money the government receives should come from taxes on what people earn or have, such as income tax, not on what people
	
	 gen tax_revenue_preference= IET03
	 
	label var tax_revenue_preference "Preference for government revenue from taxes on income/wealth vs. consumption"
	
	la de lbltax_revenue_preference 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree" 666 "Don't know"
	
	label values tax_revenue_preference lbltax_revenue_preference
	
	
	*We should pay less tax on essential goods like food compared to other products we buy.
	
	 gen tax_essential_goods= IET04
	 
	label var tax_essential_goods "Support for lower taxes on essential goods like food"
	
	la de lbltax_essential_goods 1 "Strongly Agree" 2 "Agree" 3 "Disagree" 4 "Strongly Disagree" 666 "Don't know"
	
	label values tax_essential_goods lbltax_essential_goods
	
	*How much is the ICMS charged on most of the things we buy in Rio Grande do Sul?
	
	 gen icms_rate2= IET05
	 
	label var icms_rate2 "ICMS rate on most goods in Rio Grande do Sul"
	
	
	
	*How much is the ICMS charged on most of the things we buy in Rio Grande do Sul?
	
	 gen icms_rate_rgs= IET05a
	 
	label var icms_rate_rgs "ICMS rate on most goods in Rio Grande do Sul"
	
	la de lblicms_rate_rgs 1 "Less than 5%" 2 "Between 5-10%" 3 "Between 10-20%" 4 "Between 20-30%"  5 "Between 30-40%" 6 "More than 40%" 666 "Don't know"
	
	label values icms_rate_rgs lblicms_rate_rgs
	
	
	*To receive more money from the Devolve ICMS program, you must include your CPF on the invoice when making purchases. Knowing this, you should consider this rule:
	
	 gen cpf_on_invoice_rule= IET06
	 
	label var cpf_on_invoice_rule "Consideration of CPF inclusion rule for Devolve ICMS program"
	
	la de lblcpf_on_invoice_rule 1 "Strongly Fair" 2 "Fair" 3 "Not Fair" 4 "Strongly Unfair" 666 "Don't know"
	
	label values cpf_on_invoice_rule lblcpf_on_invoice_rule
	
	
	*Are you in favor of the government increasing the tax on food so that it is the same as on other products? That is, that all products have the same tax, even if it means spending more when buying food.
	
	 gen increase_tax_on_food= IET07
	 
	label var increase_tax_on_food "Support for equalizing tax on food with other products, even if it increases food costs"
	
	la de lblincrease_tax_on_food 1 "Totally in favor" 2 "Favor" 3 "Against" 4 "Totally against" 666 "Don't know"
	
	label values increase_tax_on_food lblincrease_tax_on_food
	
	
	*Are you in favor of the government increasing the tax on food so that it is equal to that on other products, only if participants in the Devolve program receive it back?
	
	 gen tax_on_foodreturned= IET08
	 
	label var tax_on_foodreturned "Support for increasing tax on food if Devolve program participants receive reimbursement"
	
	la de lbltax_on_foodreturned 1 "Totally in favor" 2 "Favor" 3 "Against" 4 "Totally against" 666 "Don't know"
	
	label values tax_on_foodreturned lbltax_on_foodreturned
	
	
	*Are you in favor of the government increasing the tax on food so that it is equal to that on other products, only if all residents of Rio Grande do Sul receive back the amount paid in tax?
	
	 gen tax_food_all= IET09
	 
	label var tax_food_all "Support for increasing tax on food if all residents of Rio Grande do Sul receive reimbursement"
	
	la de lbltax_food_all 1 "Totally in favor" 2 "Favor" 3 "Against" 4 "Totally against" 666 "Don't know"
	
	label values tax_food_all lbltax_food_all
	
	
		*Are you in favor of the government reducing the tax on perfumes and makeup so that it is the same as on other products?
	
	 gen tax_perfumes_makeup= IET10
	 
	label var tax_perfumes_makeup "Support for reducing tax on perfumes and makeup to match other products"
	
	la de lbltax_perfumes_makeup 1 "Totally in favor" 2 "Favor" 3 "Against" 4 "Totally against" 666 "Don't know"
	
	label values tax_perfumes_makeup lbltax_perfumes_makeup
	
	
	
	*Are you familiar with the Nota Fiscal Gaúcha program?
	
	 gen nota_fiscal_program= NFG01
	 
	label var nota_fiscal_program "Familiarity with the Nota Fiscal Gaúcha program"
	
	la de lblnota_fiscal_program 1 "Yes" 2 "No" 666 "Don't know"
	
	label values nota_fiscal_program lblnota_fiscal_program
	
	
	*Are you part of it?
	
	 gen participate_nfg= NFG02
	 
	label var participate_nfg "Participates Nota Fiscal Gaúcha program"
	
	recode participate_nfg 2=0
	
	la de lblparticipate_nfg 0 "No" 1 "Yes" 666 "Don't know"
	
	label values participate_nfg lblparticipate_nfg
	
	
	*What is the main reason you do not participate in the Nota Fiscal Gaúcha program?
	
	 gen reason_nfg= NFG02A
	 
	label var reason_nfg "Main reason for not participating in the Nota Fiscal Gaúcha program"
	
	la de lblreason_nfg 1 "Registration" 2 "Information" 3 "Government distrusts" 4 "Program requirements" 5 "Registration attempt failed" 555 "Other" 666 "Don't know"
	
	label values reason_nfg lblreason_nfg
	
	
	*If you would like, I can soon send you information on how to apply for the program. Would you like to receive it?
	
	 gen send_information= NFG03
	 
	label var send_information "Send information on how to apply for the program"
	
	la de lblsend_information 1 "Yes" 2 "No" 666 "Don't know"
	
	label values send_information lblsend_information
	
	
	*Do you prefer to receive information via SMS or Whatsapp?
	
	 gen send_information_method= NFG031
	 
	label var send_information_method "Preferred method of receiving information: SMS or Whatsapp"
	
	la de lblsend_information_method 1 "SMS" 2 "Whatsapp" 666 "Don't know"
	
	label values send_information_method lblsend_information_method
	
	
	*What municipality do you live in?
	
	 gen municipality= DEM01
	 
	label var municipality "Municipality"
	
	
	*Age
	
	 gen age= DEM02
	 
	 replace age=. if age<=0 
	 
	label var age "Age"
	
	
	*Gender
	
	 gen gender= DEM03
	 
	label var gender "Gender"
	
	la de lblgender 1 "Male" 2 "Female" 666 "Don't know"
	
	label values gender lblgender
	
	
	*Including benefits such as Bolsa Família, how much money do you and your family earn per month?
	
	 gen income= DEM04
	 
	label var income "Income including benefits per month"
	
	la de lblincome 1 "Less than 600" 2 "600-1,000" 3 "1,000-1,500" 4 "1,500-2,000" 5 "2,000-3,000" 6 "More than 3,000" 666 "Don't know"
	
	label values income lblincome
	
	
	*Including yourself, how many people live in your house?
	
	 gen household_size= DEM05
	 
	label var household_size "Total number of people living in the household (including yourself)"
	
	
	*Have you or anyone in your family been affected by this year's floods?
	
	 gen flood_impact= INU01
	 
	label var flood_impact "Impact of this year's floods on you or your family"
	
	la de lblflood_impact 1 "Yes" 2 "No" 666 "Don't know"
	
	label values flood_impact lblflood_impact
	
	
	*How do you assess the impact of floods on your life?
	
	 gen flood_impact2= INU02
	 
	label var flood_impact2 "Impact of this year's floods on you or your family"
	
	la de lblflood_impact2 1 "Small" 2 "Medium" 3 "Big" 4 "Very big" 666 "Don't know"
	
	label values flood_impact2 lblflood_impact2
	
	
	*Did you have to leave your home during the heavy rains this year in Rio Grande do Sul?
	
	 gen displaced_rains= INU03
	 
	label var displaced_rains "Had to leave home during heavy rains in Rio Grande do Sul this year"
	
	la de lbldisplaced_rains 1 "Yes" 2 "No" 666 "Don't know"
	
	label values displaced_rains lbldisplaced_rains
	
	*How many days were you unable to enter your home because of the floods?
	
	 gen displaced_rains_days= real(INU03a)
	 
	 replace displaced_rains_days = . if displaced_rains_days < 0
	 
	label var displaced_rains_days "Days Unable to Enter Home Due to Floods"
	
	
	
	*Did you receive any help (money, materials or otherwise) to recover from the floods?
	
	 gen flood_aid= INU04
	 
	label var flood_aid "Received assistance to recover from this year's floods"
	
	la de lblflood_aid 1 "Yes" 2 "No" 666 "Don't know"
	
	label values flood_aid lblflood_aid
	
	
	
	*What kind of assistance or help did you receive after the floods?
	
	 gen aid_finance= INU04a_1
	 
	 recode aid_finance 0=2
	 
	label var aid_finance "Received assistance to recover from this year's floods-money"
	
	la de lblaid_finance 0 "No" 1 "Yes"  666 "Don't know"
	
	label values aid_finance lblaid_finance
	
	
	
	*What kind of assistance or help did you receive after the floods?
	
	 gen aid_material= INU04a_2
	 
	 recode aid_material 0=2
	 
	label var aid_material "Received assistance to recover from this year's floods-material"
	
	la de lblaid_material 0 "No" 1 "Yes" 666 "Don't know"
	
	label values aid_material lblaid_material
	
	
	
	*What kind of assistance or help did you receive after the floods?
	
	 gen aid_medic= INU04a_3
	 
	 recode aid_medic 0=2
	 
	label var aid_medic "Received assistance to recover from this year's floods-medical assistance"
	
	la de lblaid_medic 0 "No" 1 "Yes" 666 "Don't know"
	
	label values aid_medic lblaid_medic
	
	
	*What kind of assistance or help did you receive after the floods?
	
	 gen aid_cleaning= INU04a_4
	 
	 recode aid_cleaning 0=2
	 
	label var aid_cleaning "Received assistance to recover from this year's floods-cleaning"
	
	la de lblaid_cleaning 0 "No" 1 "Yes" 666 "Don't know"
	
	label values aid_cleaning lblaid_cleaning
	
	
	*What kind of assistance or help did you receive after the floods?
	
	 gen aid_reconstruction= INU04a_5
	 
	 recode aid_reconstruction 0=2
	 
	label var aid_reconstruction "Received assistance to recover from this year's floods-reconstruction"
	
	la de lblaid_reconstruction 0 "No" 1 "Yes"  666 "Don't know"
	
	label values aid_reconstruction lblaid_reconstruction
	
	
	
	*What kind of assistance or help did you receive after the floods?
	
	 gen aid_other= INU04a_555
	 
	 recode aid_other 0=2
	 
	label var aid_other "Received assistance to recover from this year's floods-other"
	
	la de lblaid_other 0 "No" 1 "Yes" 666 "Don't know"
	
	label values aid_other lblaid_other
	
	
	*What kind of assistance or help did you receive after the floods?
	
	 gen aid_dk= INU04a_666
	 
	label var aid_dk "Received assistance to recover from this year's floods-don't know"
	
	la de lblaid_dk 1 "Yes" 2 "No" 666 "Don't know"
	
	label values aid_dk lblaid_dk
	
	
	
*-------------------------------------------------------------------------------	
* Text Variables
*-------------------------------------------------------------------------------		
	
 
	
	
*-------------------------------------------------------------------------------	
* Creation of variables
*-------------------------------------------------------------------------------	
  
  *Monthly purchases category 
  
  gen monthly_purchases_cat=.
  
  replace monthly_purchases_cat=1 if monthly_purchases<= 500
  
  replace monthly_purchases_cat = 2 if monthly_purchases >= 500 & monthly_purchases <= 1000
  
  replace monthly_purchases_cat=3 if monthly_purchases >=1000 &  monthly_purchases <=1500
  
  replace monthly_purchases_cat=4 if monthly_purchases >=1500 &  monthly_purchases <=2000
  
  replace monthly_purchases_cat=5 if monthly_purchases  >2000
  
  replace monthly_purchases_cat=. if monthly_purchases<0
  
  label var monthly_purchases_cat "Monthly Spend Category"
	
	la de lblmonthly_purchases_cat 1 "Less than R$500.00" 2 "From R$500.00 to R$1,000.00" 3 "From R$1,000.00 to R$1,500.00" 4 "From R$1,500.00 to R$2,000.00" 5 "More than R$ 2,000.00" 666 "Don't know"
	
	label values monthly_purchases_cat lblmonthly_purchases_cat
  
  
  
  
  *Generate unit variable 
  
  gen unit=1
  
  
  *Date variable 

  gen date_part = substr(SubmissionDate, 1, strpos(SubmissionDate, " ") - 1)

 gen day = substr(date_part, 1, strpos(date_part, "/") - 1)

 gen month = substr(date_part, strpos(date_part, "/") + 1, strpos(substr(date_part, strpos(date_part, "/") + 1, .), "/") - 1)

 gen year = substr(date_part, -4, .)  
 
 
*Duration of phone call 

* Assuming 'duration' is your variable in seconds
gen double duration_ms = duration * 1000

* Apply time format to 'duration_ms'
format duration_ms %tcHH:MM:SS

* Calculate mean duration in seconds

gen double duration_sec = duration_ms / 1000
* Assuming 'duration' is your variable in seconds

* Calculate mean duration in seconds
quietly summarize duration
scalar mean_duration_sec = r(mean)

* Convert mean duration to minutes
scalar mean_duration_min = mean_duration_sec / 60

* Display mean duration in minutes
display "Average Call Duration: " mean_duration_min " minutes"

 * Variable income_div is correctly defined
	
    gen income_div = .
    replace income_div = 0 if income==1 
    replace income_div = 1 if income >= 2 & income<666


   label define lblincome_div 0 "Less than 600" 1 "More than 600" 
   label values income_div lblincome_div

 * Variable age 
	
    gen age_div = .
    replace age_div = 0 if age < 45
    replace age_div = 1 if age >= 45

   label define lblage_div 0 "Less than 45 years" 1 "More than 45 years" 
   label values age_div lblage_div

 *IET05A
 
    gen icms_rate2_div=.

    replace icms_rate2_div=2 if icms_rate2>=7 & icms_rate2<10
	
	replace icms_rate2_div=3 if icms_rate2>=10 & icms_rate2<20
	
	replace icms_rate2_div=4 if icms_rate2>=20 & icms_rate2<30
	
	replace icms_rate2_div=5 if icms_rate2>=30 & icms_rate2<40
	
	replace icms_rate2_div=6 if icms_rate2>=40 

*-------------------------------------------------------------------------------	
* Merge with urban/rural classification
*-------------------------------------------------------------------------------	
   
   preserve 
   
  import excel using "C:\Users\wb631166\OneDrive - WBG\Desktop\Taxes\G2Px\Deliverable_Jan132025\muncipalities_brazil.xlsx", firstrow clear

  rename Municipality municipality 
  
  save "urban_rural_classification_rio_grande_do_sul.dta", replace
  
  restore
  
  *Merge
  
  merge m:1 municipality using "urban_rural_classification_rio_grande_do_sul.dta"
  
  keep if _merge==3 // 1,037 obs
  
  rename Urban10 urban

  
  
   
   
 *-------------------------------------------------------------------------------	
* Order Data set
*-------------------------------------------------------------------------------	
   
   order day month year id_entrevista municipality age gender income
  

*-------------------------------------------------------------------------------	
* Save data set
*-------------------------------------------------------------------------------	
   
   save "C:\Users\wb631166\OneDrive - WBG\Desktop\Taxes\G2Px\Deliverable_Jan132025\devolve_survey_jan_clean.dta", replace
   
   
   
   
   
   
	