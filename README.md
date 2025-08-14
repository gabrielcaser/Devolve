# Devolve

## Files Produced Description

---

### 📄 Raw Data
**Filename:** `devolve_survey_raw.dta`  
Identical to the Firm Survey Data `.xlsx` (Excel), but converted to `.dta` (Stata) format.

---

### 📄 Clean Data
**Filename:** `devolve_survey_clean.dta`  
Based on the Raw Data, with the following modifications:

- Anonymization of personally identifiable information (if applicable)
- Removal of duplicate entries (if any)
- Standardization of missing values (e.g., `.d` instead of `666`)
- Recoding of binary variables (e.g., `0/1` instead of `1/2`)
- Variables labeled in English
- Value labels translated to English (e.g., `"Yes/No"` instead of `1/0`)

---

### 📄 Constructed Data
**Filename:** `devolve_survey_constructed.dta`  
Based on the Clean Data, with further processing for analysis:

- Variables renamed using descriptive names (e.g., `flood_impact` instead of `INU01`)
- Original variable names included in the labels of renamed variables
- New variables created for analysis
- Irrelevant variables removed
