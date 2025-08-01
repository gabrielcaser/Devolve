# Devolve

- Firm Survey data: (Base Final BM Programa Devolve ICMS RS Coleta.xlsx) Data sent by the Survey Firm without any data management by DIME.
- Raw data: (devolve_survey_raw.dta) The same as the Firms Survey data file, but in .dta format.
- Clean data – (devolve_survey_clean.dta) The same as Raw data, but with the following alterations
    - Duplicates removed (if any)
    - Recoded missing values (ex. .d instead of 666)
    - Recoded dummies (0,1 instead of 1,2)
    - Variables with english labels
    - Variable values with english labels (ex. “Yes/No” instead of 1/0)
- Constructed data: (devolve_survey_constructed.dta) The same as Clean data, but with the following alterations
    - Variables renamed with comprehensible names (ex. flood_impact instead of INU01)
    - New variables created to be used in the analysis
    - Variables not useful for the analysis dropped 

