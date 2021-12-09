
/* PMA Ethiopia Cohort 1 12month Indicators 
This .do file takes the deidentified recoded 1-Year data from PMA Ethiopia, and exports identifed  key indicators analysis result 
The dataset produced by this .do file is COHORT_1year_Priority_Analysis_DATE

Generated indicators by category:
1. FP-RH
2. COVID & MCH service
3. PNC
4. Delivery
5. Vaccination
6. Nutrition
7. Infant
8. Continum of care
 */

clear
clear matrix
clear mata
capture log close
set maxvar 15000
set more off
numlabel, add

* Set local/global macros for current date
local today=c(current_date)
local c_today= "`today'"
global date=subinstr("`c_today'", " ", "",.)

**************************************************************
*   SET MACROS 
**************************************************************

*Year Macros
local COHORT Cohort1 

* Set macros for data sets
local 1Yeardata "C:\Users\Bedilu\Dropbox (Gates Institute)\PMAET2_Datasets\1-Cohort1\4-1Year\Prelim100\Cohort1_NoName_1Y_Clean_5Nov2021.dta"
local MergedData "C:\Users\Bedilu\Desktop\Bedilu\PMA\PMAsurvey\Cohort1\PremAnalysis\Combined_6W6M1Y\Data\Cohort1_Base_6W_6M_1Y_Merged.dta"

*Set directory for to save the output
global datadir "C:\Users\Bedilu\Desktop\Bedilu\PMA\PMAsurvey\Cohort1\PremAnalysis\Combined_6W6M1Y\Result\Analysis$date"
capture mkdir "$datadir"

**************************************************************
***PREPARATION OF DATA
**************************************************************
cd "$datadir"
*use "`1Yeardata'", clear
use "`MergedData'", clear
*Response rate among all women
gen responserate=0 
replace responserate=1 if OYresult==1|OYresult==2
label define responselist 0 "Not complete" 1 "Complete"
label val responserate responselist
tab responserate
tab region responserate,row
*Generate 0/1 urban/rural variable
gen urban=ur==1
label variable urban "Urban/rural place of residence"
label define urban 1 "Urban" 0 "Rural"
label value urban urban
tab urban, mis 

*********************************************
*   Sheet 1: Background characteristics     *
*********************************************
rename OYOYFUweight OYFUweight 
*Table 0: Response rate
tabout responserate region[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 0: One Year FU response rate) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Demo) location(1 1)

*Restrict analysis to women who completed 1Y questionnaire 
keep if OYresult==1|OYresult==2 /*2095*/
* Table 1:Age 
tabout OYbase_age_cat5[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 1: Age) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Demo) location(9 1)

* Table 2:School 
recode OYschool (.=0) (3 4 =2), gen(wge_school)
label define wge_school_list 0 "Never attended" 1 "Primary" 2 "Secondary or higher"
label val wge_school wge_school_list
label var wge_school "Education level: recoded"

tabout wge_school[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 2: Education) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Demo) location(20 1)

*Table 3: Parity
egen parity3=cut(total_births), at(0, 2, 4, 30) icodes
lab def parity3l 0 "0-1 children" 1 "2-3 children" 2 "4+ children"
lab val parity3 parity3l
replace parity3=0 if total_births==.|total_births==-99

tabout parity3[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 3: Parity) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Demo) location(27 1)

*Table 4:Region
tabout OYregion[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 4: Region) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Demo) location(35 1)

*Table 5: Residence
tabout urban[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 5: Residence) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Demo) location(47 1)
 
*Table 6: Wealth
tabout OYbase_wealthquintile[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 6: Wealth) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Demo) location(56 1)

*Table 7: Marital Status
recode OYbase_married2 (0 .=2)
tabout OYbase_married2[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 7: Marital Status) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Demo) location(67 1)

exit

*********************************************
*   Sheet 2: FP_RH                          *
*********************************************
*Table 1: Proportion of women who are using a method to delay pregnancy
tabout OYcc_current_user[aw=OYFUweight] if OYpregnant !=1 using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 1: Proportion of women who are using a method to delay pregnancy) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(FP_RH) location(1 1)

*Table 2: Proportion of women who are using modern method of family planning
gen modern_methods=0
replace modern_methods=1 if OYfster==1|OYmster==1|OYimpl==1|OYiud==1| OYinjection==1|OYpill==1|OYec==1|OYmc==1|OYfc==1|OYbeads==1|OYlam==1
label define modern_methodslist 0 "No" 1 "Yes"
label val modern_methods modern_methodslist
tabout modern_methods[aw=OYFUweight] if OYcc_current_user==1 using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 2: Proportion of women who are using modern method of family planning) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(FP_RH) location(9 1)

*Table 3:Proportion of women who are using short-acting methods of family planning
gen short_acting=0
replace short_acting=1 if OYinjection==1|OYpill==1|OYec==1|OYmc==1|OYfc==1|OYbeads==1|OYlam==1
label define short_actinglist 0 "No" 1 "Yes"
label val short_acting short_actinglist
tabout short_acting[aw=OYFUweight] if OYcc_current_user==1 using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 4: Proportion of women who are using short acting method of family planning) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(FP_RH) location(17 1)

*Table 4: Proportion of women who are using long acting method of family planning
gen long_acting=0
replace long_acting=1 if OYfster==1|OYmster==1|OYimpl==1|OYiud==1  
label define long_actinglist 0 "No" 1 "Yes"
label val long_acting long_actinglist

tabout long_acting[aw=OYFUweight] if OYcc_current_user==1 using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 4: Proportion of women who are using long acting method of family planning) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(FP_RH) location(25 1)

*Table 5: Proportion of women are using traditional methods of family planning
*Traditional methods: fRhythm method and withdrawal
gen trad_methods=0
replace trad_methods=1 if OYrhyth==1|OYwithd==1|OYtrad==1
label define trad_methodslist 0 "No" 1 "Yes"
label val trad_methods trad_methodslist
tabout trad_methods[aw=OYFUweight] if OYcc_current_user==1 using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 5:Proportion of women are using traditional methods of family planning) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(FP_RH) location(33 1)

*Table 6: The proportion of women who listed a reason for using current methods of family planning
local i=41 
foreach var in OYwhy_current_fp_duration OYwhy_current_fp_nofollowup OYwhy_current_fp_othersunavail OYwhy_current_fp_recommendation OYwhy_current_fp_fewersidefx OYwhy_current_fp_ignoranthusband OYwhy_current_fp_other {
	local `var' : variable label `var'
	recode `var' (-99 . =0) 
	tabout `var' [aw=OYFUweight] if OYcc_current_user==1 using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table X: `"`: var label `var''"') f(0 1) clab(n col_%) nwt(OYFUweight) sheet(FP_RH) location(`i' 1)
local i=`i'+7
	}	

*Table 7: Among women approximately 1Y PP who were currently using any method of FP at the time of the survey, the percentage who were using their desired method
tabout OYfp_obtain_desired[aw=OYFUweight] if OYcc_current_user==1 using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 7:Proportion of women who were using their desired method) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(FP_RH) location(90 1)

*Table 8:The proportion of current users who used the [Method] without stopping for [months]/[years] 

*Table 9: The proportion of women who resumed sexual activity after delivery
recode OYresumed_sex(-99=0)
tabout OYresumed_sex[aw=OYFUweight] if OYpregnant !=1 using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 9:The proportion of women who resumed sexual activity after delivery) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(FP_RH) location(106 1)

*Table 10: The proportion of women with unmet need 
recode OYmore_children (-88 .=0)
tabout OYmore_children[aw=OYFUweight] if OYpregnant !=1 using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 10:Would you like to have a/another child or would you prefer not to have any / any more children?) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(FP_RH) location(114 1)

*Table 11: How long would you like to wait before the birth of your next child
tabout OYwait_birth[aw=OYFUweight] if OYpregnant !=1 using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 10:Would you like to have a/another child or would you prefer not to have any / any more children?) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(FP_RH) location(123 1)

*Table 12: When was the last time you had sexual intercourse?
recode OYlast_time_sex_units(-88 -99=.)
tabout  OYlast_time_sex_units[aw=OYFUweight] if OYresumed_sex==1 using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 12: When was the last time you had sexual intercourse?) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(FP_RH) location(132 1)

*Table 13: When did your last menstural period start?
recode OYcycle_return_units(-88=.)
tabout OYcycle_return_units[aw=OYFUweight] if OYcycle_returned==1 using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 13: When did your last menstural period start?) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(FP_RH) location(141 1)

*Table 14: Were you told where you could go to have the implant removed?


*Table 15: Prportion of women who were told how much implant removal would cost 
tabout OYtold_implant_cost[aw=OYFUweight] if OYimpl==1 using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 15: Prportion of women who were told how much implant removal would cost) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(FP_RH) location(141 1)

*Table 16:


*Table 17:The proprtion of women who wnated to remove the implant
tabout OYwant_implant_removed[aw=OYFUweight] if OYimpl==1 using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 17: The proprtion of women who wnated to remove the implant) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(FP_RH) location(141 1)

*Table 18: Proportion of women who tried to remove the implant in the past 6 months
tabout OYimplant_removed_attempt[aw=OYFUweight] if OYimpl==1 using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 18: Proportion of women who tried to remove the implant in the past 6 months) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(FP_RH) location(141 1)

*Table 19: Proportion of implant using women who have tried to remove the implant in Health facilities
gen Imp_removalPlace=0
replace Imp_removalPlace=1 if OYimpl_removed_where_govthosp==1| OYimpl_removed_where_govtcenter==1| OYimpl_removed_where_govtpost==1| OYimpl_removed_where_otherpublic==1| OYimpl_removed_where_ngo==1| OYimpl_removed_where_otherngo==1| OYimpl_removed_where_privhosp==1| OYimpl_removed_where_privclinic==1| OYimpl_removed_where_pharm==1| OYimpl_removed_where_otherpriv==1| OYimpl_removed_where_drugvendor==1| OYimpl_removed_where_shop==1| OYimpl_removed_where_friend==1| OYimpl_removed_where_other==1

tab Imp_removalPlace

*Table 20: Who tried to remove the implant?
tabout OYwho_attempt_removal[aw=OYFUweight] if OYwant_implant_removed==1 using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 20: Who tried to remove the implant?) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(FP_RH) location(141 1)
*Table 21:

*********************************************
*   Sheet 4: COVID                          *
*********************************************
*Table 1: Percentage of mothers and caretakers who reported degree of awareness about the COVID otbreak.
tabout OYcovid_knowledge[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 1: Percentage of mothers and caretakers who reported degree of awareness about the COVID otbreak) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(COVID) location(1 1)

*Tabel 2: COVID awareness communication channel source (14 sources) 
local i=11 
foreach var in OYhow_learned_covid_news OYhow_learned_covid_radio OYhow_learned_covid_tv OYhow_learned_covid_poster OYhow_learned_covid_phone OYhow_learned_covid_ethio OYhow_learned_covid_family OYhow_learned_covid_friends OYhow_learned_covid_leaders  OYhow_learned_covid_hp OYhow_learned_covid_govt OYhow_learned_covid_school OYhow_learned_covid_other {
	local `var'_lab : variable label `var'
	recode `var' (-99 . =0) 
	tabout `var' [aw=OYFUweight] using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table X: `"`: var label `var''"') f(0 1) clab(n col_%) nwt(OYFUweight) sheet(COVID) location(`i' 1)
local i=`i'+7
	}	

tabout OYhow_learned_covid_socialmedia[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table X: Social Media) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(COVID) location(102 1)

*Trusted COVID Information Source
local i=110 
foreach var in OYcovid_trust_source_poster OYcovid_trust_source_phone OYcovid_trust_source_ethio OYcovid_trust_source_family OYcovid_trust_source_leaders OYcovid_trust_source_friends OYcovid_trust_source_socialmedia OYcovid_trust_source_hp OYcovid_trust_source_govt OYcovid_trust_source_school OYcovid_trust_source_other {
	local `var' : variable label `var'
	recode `var' (-99 . =0) 
	tabout `var' [aw=OYFUweight] using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table X: `"`: var label `var''"') f(0 1) clab(n col_%) nwt(OYFUweight) sheet(COVID) location(`i' 1)
local i=`i'+7
	}	

exit
	
tabout OYcovid_trust_source_leaders[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table X: Social Media) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(COVID) location(180 1)
	
tabout OYcovid_trust_source_friends[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table X: Social Media) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(COVID) location(187 1)

tabout OYcovid_trust_source_socialmedia[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table X: Social Media) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(COVID) location(194 1)

* COVID Community Risk Perception (Concern)

recode OYcommunity_spread_concern (.=0)

tabout OYcommunity_spread_concern[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table X: COVID Community Risk Perception (Concern)) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(COVID) location(202 1)

*COVID Self Risk Perception (Concern)
 recode OYself_covid_concern (.=0)
 tabout OYself_covid_concern [aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table X: COVID Self Risk Perception (Concern)) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(COVID) location(213 1)
 
*COVID Prevention Practice
recode OYable_to_distance (-99 .=0)
tabout OYable_to_distance[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table X: COVID Prevention Practice) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(COVID) location(225 1)

*Reason for non practice of COVID prevention
local i=233 
foreach var in  OYwhy_unable_to_distance_job OYwhy_unable_to_distance_market OYwhy_unable_to_distance_water OYwhy_unable_to_distance_school OYwhy_unable_to_distance_funeral OYwhy_unable_to_distance_church OYwhy_unable_to_distance_visit OYwhy_unable_to_distance_health OYwhy_unable_to_distance_other {
	local `var' : variable label `var'
	recode `var' (-99 . =0) 
	tabout `var' [aw=OYFUweight] using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table X: `"`: var label `var''"') f(0 1) clab(n col_%) nwt(OYFUweight) sheet(COVID) location(`i' 1)
local i=`i'+7
	}	

*Household Level COVID Economic Effect
gen COVID_Eco_effect=0 
replace COVID_Eco_effect=1 if OYhousehold_income_loss==2 | OYhousehold_income_loss==3
label define COVID_Eco_effectlist 0 "Not Change" 1 "Partial/Complete"
label val COVID_Eco_effect COVID_Eco_effectlist

tabout  COVID_Eco_effect [aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table X: COVID Prevention Practice) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(COVID) location(296 1)

*Individual Level COVID Economic Effect (For Partially affected HH)
tabout OYself_income_loss [aw=OYFUweight] if OYhousehold_income_loss==2  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table X:Individual Level COVID Economic Effect (For Partially affected HH)) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(COVID) location(304 1)

*Households with No Food Due to COVID
recode OYlack_food_4wks (-88=0)
tabout OYlack_food_4wks [aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table X:Households with No Food Due to COVID) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(COVID) location(315 1)

*Frequency of No Food Due to COVID
tabout OYlack_food_frequency [aw=OYFUweight] if OYlack_food_4wks==1 using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table X:Households with No Food Due to COVID) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(COVID) location(324 1)

*COVID Effect on Childhood Vaccination

* Type of Difficulties on Childhood Vaccination Due to COVID

*Missed Childhood Vaccination Due to COVID

*COVID Effect on Sick Child Health Care



*********************************************
*   Sheet 5: PNC                            *
*********************************************
*Table 1:  Percentage of women who visited a professional health worker for care themselves or their babies in the past 6 months
recode OYhealth_check_6m_yn(-88=0)
tabout OYhealth_check_6m_yn [aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 1: Percentage of women who visited a professional health worker for care themselves or their babies in the past 6 months) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(PNC) location(1 1)

*Table 2: Percentage of women who have been visited by a professional health worker for care themselves or their babies in the past 6 months
tabout OYcheck_you_6m_yn [aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 2: Percentage of women who have been visited by a professional health worker for care themselves or their babies in the past 6 months ) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(PNC) location(8 1)

*Table 3: Proportion of women who were counselled on diversified feeding (giving a variety of foods when the baby starts feeding after 6 months) by HEW or other professional health care provider at any health check point in the past 6 months

tabout OYfood_variety [aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 3: Proportion of women who were counselled on diversified feeding  by HEW or other professionals ) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(PNC) location(16 1)

*Table 4: Proportion of women who were counselled on feeding animal source foods by HEW or other professional health care provider at any health check point in the past 6 months

tabout OYanimal_foods [aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 4: Proportion of women who were counselled on feeding animal source foods by HEW or other professionals ) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(PNC) location(24 1)

*Table 5: Proportion of women who were counselled on frequency of feeding by HEW or other professional health care provider at any health check point in the past 6 months

tabout OYfood_frequency [aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 5:Proportion of women who were counselled on frequency of feeding by HEW or other professional ) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(PNC) location(32 1)
*Table 6: Proportion of women who were counselled on not to feed sugar-sweetened beverages by HEW or other professional health care provider at any health check point in the past 6 months 

tabout OYavoid_sugary_drinks [aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 6: Proportion of women who were counselled on not to feed sugar-sweetened beverages by HEW or other professional) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(PNC) location(40 1)

*Table 7: Percentage of women whose baby's weight was measured by any health care provider at any health check in the past 6 months
tabout OYmeasure_weight [aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 7: Percentage of women whose baby's weight was measured by any health care provider at any health check in the past 6 months) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(PNC) location(48 1)

*Table 8:Percentage of women whose baby's length was measured by any health care provider at any health check in the past 6 months
recode OYmeasure_height (-88=0)
tabout OYmeasure_height [aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 8:Percentage of women whose baby's length was measured by any health care provider at any health check in the past 6 months) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(PNC) location(56 1)

*Table 9: Percentage of women whose baby's upper arm circumference was measured by any health care provider at any health check in the past 6 months
recode OYmeasure_muac (-88=0)
tabout OYmeasure_muac [aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 9:Percentage of women whose baby's upper arm circumference was measured by any health care provider at any health check in the past 6 months) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(PNC) location(64 1)

*Table 10: Percenage of women who receive any family planning information, referrals or services, not including immunization visits at any health checks in the past 6 months for themselves or their babies
recode OYfp_info_non_vaccine_visit_6m(-88=0)
tabout OYfp_info_non_vaccine_visit_6m [aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 10: Percenage of women who receive any family planning information, referrals or services, not including immunization visits) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(PNC) location(72 1)

*Table 11: Percenage of women who receive any family planning information, referrals or services during any of immunization visits for their babies
tabout OYfp_info_vaccine_visit_6m [aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 11: Percenage of women who receive any family planning information, referrals or services during any of immunization visits for their babies) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(PNC) location(80 1)


*********************************************
*   Sheet 6: Delivery                       *
*********************************************

* First reshape the data
preserve
keep if OYresult==1|OYresult==2 

unab kid_var : OYgender1-OYnocard_vit_a_yn1
local stubs: subinstr local kid_var "1" "", all
local stubs: subinstr local stubs "OYpolio_" "OYpolio1_", all
local stubs: subinstr local stubs "OYpentavalent_" "OYpentavalent1_", all
local stubs: subinstr local stubs "OYpcv_" "OYpcv1_", all
local stubs: subinstr local stubs "OYrota_" "OYrota1_", all
local stubs: subinstr local stubs "OYmeasles_" "OYmeasles1_", all
gen mother_ID=OYmetainstanceID
foreach var in `kid_var' {
local `var'l : variable label `var'
}
reshape long `stubs', i(mother_ID) j(index)

*Table 1: Birth outcome pregnancy type
tabout OYpregnancy_type[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 1: Birth outcome pregnancy type) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Delivery) location(1 1)

*Table 2:Birth outcome gender
tabout OYgender[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 2: Birth outcome gender) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Delivery) location(8 1)

*Table 3: The proportion of live births
tabout OYstill_alive[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 3: The proportion of live births) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Delivery) location(16 1)

*Table 4: The proporton of births registered in the CRVS system
tabout OYbirth_registered[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 4: The proporton of births registered in the CRVS system) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Delivery) location(24 1)
*Table 5: Exactly how old  the child when (he/she) died?
tabout OYage_at_death_units[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 5: Exactly how old  the child when (he/she) died?) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Delivery) location(32 1)

*Table 6: The proportion of babies who died at home
recode OYwhere_died (3 4 5 =16), gen(deid_home)
label define deid_homelist 1 "Deid at home" 16 "Other place"
label val deid_home deid_homelist

tabout deid_home[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 6: The proportion of babies who died at home) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Delivery) location(40 1)

*Table 7: The proprotion of babies' death registered in the CRVS system
tabout OYdeath_registered[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 7: The proprotion of babies' death registered in the CRVS system) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Delivery) location(48 1)

*Table 8: The proportion of deceased babies who suffered from any injury or accident
tabout OYaccident_yn[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 8: The proportion of deceased babies who suffered from any injury or accident) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Delivery) location(56 1)

/*
*Table 9: The types of injury which led to the death of the baby 
    * No case
tabout OYaccident_type[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 9: The types of injury which led to the death of the baby) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Delivery) location(64 1)
*/

*Table 9: The proportion of babies who suffered from the listed symptioms before death 
local i=64
foreach var in  OYsymptoms_poorfeed OYsymptoms_eyeinfect OYsymptoms_skinles OYsymptoms_convusle OYsymptoms_lethargy OYsymptoms_unconsc OYsymptoms_fever OYsymptoms_cough OYsymptoms_sorethrt OYsymptoms_fastbreath OYsymptoms_difbreath OYsymptoms_diarrhea OYsymptoms_vomit OYsymptoms_nostool OYsymptoms_swelling OYsymptoms_other {
	local `var' : variable label `var'
	tabout `var' [aw=OYFUweight] using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table X: `"`: var label `var''"') f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Delivery) location(`i' 1)
local i=`i'+7
	}	

*Table 10: The proportion women who perceived the listed symptoms as a cause for the death of her baby
local i=176
foreach var in  OYcause_of_death_premie OYcause_of_death_delivery OYcause_of_death_sids OYcause_of_death_tetanus OYcause_of_death_malaria OYcause_of_death_pneumonia OYcause_of_death_measles OYcause_of_death_cough OYcause_of_death_giOYcause_of_death_malnut OYcause_of_death_meningitis OYcause_of_death_hep OYcause_of_death_typhus OYcause_of_death_tb OYcause_of_death_aids OYcause_of_death_unknown OYcause_of_death_negligence OYcause_of_death_evileye OYcause_of_death_coronavirus OYcause_of_death_other  {
	local `var' : variable label `var'
	tabout `var' [aw=OYFUweight] using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table X: `"`: var label `var''"') f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Delivery) location(`i' 1)
local i=`i'+7
	}	









*********************************************
*   Sheet 7:   Vaccination                        *
*********************************************
*Restrict the analysis for live births ONLY
keep if still_alive==1 

*tabout still_alive[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 1: Is[NAME] a still alive?) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(1 1)

*Reshape the child variable to account for twins
preserve
*still_alive1
unab kid_var : still_alive1-nocard_vit_a_yn1
local stubs: subinstr local kid_var "1" "", all
local stubs: subinstr local stubs "polio_" "polio1_", all
local stubs: subinstr local stubs "pentavalent_" "pentavalent1_", all
local stubs: subinstr local stubs "pcv_" "pcv1_", all
local stubs: subinstr local stubs "rota_" "rota1_", all
local stubs: subinstr local stubs "measles_" "measles1_", all

gen mother_ID=OYmetainstanceID
foreach var in `kid_var' {
local `var'l : variable label `var'
}
reshape long `stubs', i(mother_ID) j(index)


* Table 1: Vital Registration
recode birth_registered (-88=0)
tabout birth_registered[aw=OYFUweight] if still_alive==1   using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 1: Vital Registration) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(1 1)

*Table 2: Vaccinated Infants
* Proportion of alive infants who got some vaccines at age of 12 month, according to care takers claim.
tabout vaccines_yn[aw=OYFUweight] if still_alive==1   using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 2: Vaccinated Infants) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(8 1)

*Do you have a formal vaccination card with an official Ministry of Health logo where [NAME'S] vaccinations are written down?
 * Proportion of alive infants who have official vaccination cards at age of  12 month
 recode moh_vaccine_card (2=1), gen(Vaccine_card)
label var Vaccine_card " Ownership of official vaccination card"
label define Vaccine_card_list 1 " Yes " 0 " No"
label val Vaccine_card Vaccine_card_list
tabout Vaccine_card [aw=OYFUweight] if still_alive==1  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 3: Ownership of official vaccination card) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(15 1)
* Verified
 recode moh_vaccine_card (2=0), gen(Vaccine_cardRE)
 label var Vaccine_cardRE " Verified ownership of official vaccination card"
label define Vaccine_cardRE_list 1 " Yes " 0 " No"
label val Vaccine_cardRE Vaccine_cardRE_list

tabout Vaccine_cardRE [aw=OYFUweight]   using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 4: Verified ownership of official vaccination card) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(22 1)

*5. Ownership of non-official vaccination card at 12 months
recode unofficial_vaccine_card (2=1) (. -99=0), gen(non_official)
label var non_official "Non-official vaccination card"
label define non_official_list 1 " Yes " 0 " No"
label val non_official non_official_list
tabout non_official [aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 5: Ownership of non-official vaccination card at 6 months) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(29 1)

*6.Verified other vaccination card owning infants 
recode unofficial_vaccine_card (2 . -99 =0), gen(unofficial_vaccine_cardRE)
label var unofficial_vaccine_cardRE "Verified ownership of non-official vaccination card"
label define unofficial_vaccine_cardRE_list 1 " Yes " 0 " No"
label val unofficial_vaccine_cardRE unofficial_vaccine_cardRE_list
tabout unofficial_vaccine_cardRE [aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 6: Verified ownership of other non-official vaccination card at 12m) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(36 1)

*7. Any vaccination card owning infants 
gen Any_card=0
replace Any_card=1 if unofficial_vaccine_card==1|unofficial_vaccine_card==2|moh_vaccine_card==1|moh_vaccine_card==2
label var Any_card "Any vaccination card owning infants"
label define Any_card_list 1 " Have card " 0 " No card"
label val Any_card Any_card_list
tabout Any_card [aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 7: Ownership of any vaccination card (official or non-official) at 12 months) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(43 1)

*8. Any verfied vaccination card owning infants 
gen any_card_RE=0
replace any_card_RE=1 if unofficial_vaccine_card==1|moh_vaccine_card==1
label var any_card_RE "Any  verfied vaccination card owning infants"
label define any_card_RE_list 1 " Have verfied card " 0 " No verfied card"
label val any_card_RE any_card_RE_list
tabout any_card_RE[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 8: Verified ownership of any vaccination card at 12 months) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(50 1)

*9. BCG Vaccination coverage (by card)
recode bcg_card (. -99 =0) 
recode bcg_card (-88 =1) 
tabout  bcg_card [aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 9: BCG Vaccination coverage (by card)) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(57 1)

*10. BCG Vaccination coverage (by history)
recode nocard_bcg_yn (. -88 -99 =0) 
tabout nocard_bcg_yn[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 10: BCG Vaccination coverage (by history)) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(64 1)

*11. BCG Vaccination coverage (by card or by history)
gen BCG_both=0
replace BCG_both=1 if bcg_card==1|bcg_card==-88|nocard_bcg_yn==1
label var BCG_both " Vaccinated BCG either from card or by history"
label define BCG_both_list 1 " Yes " 0 " No"
label val BCG_both BCG_both_list
tabout BCG_both[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 11: BCG Vaccination coverage (by card or by history)) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(71 1)

*12. Penta 1 Vaccination coverage (by card)
recode pentavalent1_card (. -99 =0)
recode pentavalent1_card (-88 =1) 
tabout pentavalent1_card[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 12: Penta 1 Vaccination coverage (by card)) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(78 1)

*13. Penta 1 Vaccination coverage (by history)
recode nocard_pentavalent_yn1 (. -99 -88 =0)
gen penta1_hist=0
replace penta1_hist=1 if nocard_pentavalent_yn1==1&nocard_pentavalent_count1==1
label var penta1_hist " Penta 1 Vaccination by history"
label define penta1_hist_list 1 " Yes " 0 " No"
label val penta1_hist penta1_hist_list
tabout penta1_hist[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 13: Penta 1 Vaccination coverage (by history)) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(86 1)
*14. Penta 1 Vaccination coverage (by card or by history)
gen Penta1_both=0
replace Penta1_both=1 if (pentavalent1_card==1|pentavalent1_card==-88)|(nocard_pentavalent_yn1==1&nocard_pentavalent_count1==1)
label var Penta1_both" Vaccinated pentavalent either by card or by history"
label define Penta1_both_list 1 " Yes " 0 " No"
label val Penta1_both Penta1_both_list
tabout Penta1_both[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 14: Penta 1 Vaccination coverage (by card or by history)) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(93 1)

*15. Penta 3 Vaccination coverage (by card)
recode pentavalent3_card (. -99 =0)
recode pentavalent3_card (. -88 =0)
tabout pentavalent3_card [aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 15: Penta 3 Vaccination coverage (by card)) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(100 1)

*16. Penta 3 Vaccination coverage (by history)
recode nocard_pentavalent_yn1 (. -99 -88 =0)
gen penta3_hist=0
replace penta3_hist=1 if nocard_pentavalent_yn1==1 & nocard_pentavalent_count1>=3
label var penta3_hist " Penta 3 Vaccination by history"
label define penta3_hist_list 1 " Yes " 0 " No"
label val penta3_hist penta3_hist_list
tabout penta3_hist[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 16: Penta 3 vaccination coverage (by history)) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(107 1)

*17. Penta 3 Vaccination coverage (by card or by history)
gen Penta3_both=0
replace Penta3_both=1 if (pentavalent3_card==1|pentavalent3_card==-88)|(nocard_pentavalent_yn1==1&nocard_pentavalent_count1>=3)
label var Penta3_both" Vaccinated pentavalent either by card or by history"
label define Penta3_both_list 1 " Yes " 0 " No"
label val Penta3_both Penta3_both_list
tabout Penta3_both[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 17: Penta 3 vaccination coverage (by card or by history)) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(114 1)

*18. Measles Vaccination coverage (by card)
gen measles_card=measles1_card
recode measles_card (. -99 =0)
recode measles_card (. -88 =0)
tabout measles_card[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 18: Measles Vaccination coverage (by card)) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(121 1)

*19. Measles Vaccination coverage (by history)
recode nocard_measles_yn1 (. -99 -88 =0)
gen measles_hist=0
replace measles_hist=1 if nocard_measles_yn1==1 
label var measles_hist " Measles vaccination by history"
label define measles_hist_list 1 " Yes " 0 " No"
label val measles_hist measles_hist_list
tabout measles_hist[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 19: Measles vaccination coverage (by history)) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(128 1)

*20. Measles Vaccination coverage (by card or by history)
gen Measles_both=0
replace Measles_both=1 if measles1_card==1|measles1_card==-88|nocard_measles_yn1==1
label var Measles_both " Vaccinated Measles either from card or by history"
label define Measles_both_list 1 " Yes " 0 " No"
label val Measles_both Measles_both_list
tabout Measles_both[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 20: Measles Vaccination coverage (by card or by history)) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(135 1)

*21. Fully Vaccinated coverage (by card)
gen Fully_Vaccinated1=0
replace Fully_Vaccinated1=1 if (bcg_card==1|bcg_card==-88) & (polio1_card==1|polio1_card==-88)& (pentavalent1_card==1|pentavalent1_card==-88)& (pcv1_card==1|pcv1_card==-88) & (rota1_card==1|rota1_card==-88) & (polio2_card==1|polio2_card==-88) & (pentavalent2_card==1|pentavalent2_card==-88) & (pcv2_card==1|pcv2_card==-88) & (rota2_card==1|rota2_card==-88) & (polio3_card==1|polio3_card==-88)& (pentavalent3_card==1|pentavalent3_card==-88)& (pcv3_card==1|pcv3_card==-88) & (measles1_card==1|measles1_card==-88)
label var Fully_Vaccinated1 "Infants who got 13 vaccines"
label define Fully_Vaccinated1_list 1 " Yes " 0 " No"
label val Fully_Vaccinated1 Fully_Vaccinated1_list
tabout Fully_Vaccinated1[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 21: Fully  vaccinated coverage (by card)) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(142 1)

*22. Fully Vaccinated coverage (by history)
gen Fully_Vaccinated_hist=0
replace Fully_Vaccinated_hist=1 if nocard_bcg_yn==1 & nocard_polio_count1>=3 & nocard_pentavalent_count1>=3 & nocard_pcv_count1>=3 & nocard_rota_count1>=2 &nocard_measles_yn1==1
label var Fully_Vaccinated_hist "Infant who  fully vaccinated by history"
label define Fully_Vaccinated_hist_list 1 " Yes " 0 " No"
label val Fully_Vaccinated_hist Fully_Vaccinated_hist_list
tabout Fully_Vaccinated_hist[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 22: Fully Vaccinated coverage (by history)) and which is documented on any vaccination cards verified by REs) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(149 1)

*23. Fully Vaccinated coverage (by card or by history)
gen Fully_Vaccinated_both=0
replace Fully_Vaccinated_both=1 if ((bcg_card==1|bcg_card==-88) & (polio1_card==1|polio1_card==-88)& (pentavalent1_card==1|pentavalent1_card==-88)& (pcv1_card==1|pcv1_card==-88) & (rota1_card==1|rota1_card==-88) & (polio2_card==1|polio2_card==-88) & (pentavalent2_card==1|pentavalent2_card==-88) & (pcv2_card==1|pcv2_card==-88) & (rota2_card==1|rota2_card==-88) & (polio3_card==1|polio3_card==-88)& (pentavalent3_card==1|pentavalent3_card==-88)& (pcv3_card==1|pcv3_card==-88) & (measles1_card==1|measles1_card==-88))|(nocard_bcg_yn==1&nocard_polio_count1>=3& nocard_pentavalent_count1>=3&nocard_pcv_count1>=3&nocard_rota_count1>=2&nocard_measles_yn1==1)
label var Fully_Vaccinated_both "Infant who fully vaccinated(by card or history)"
label define Fully_Vaccinated_both_list 1 " Yes " 0 " No"
label val Fully_Vaccinated_both Fully_Vaccinated_both_list
tabout Fully_Vaccinated_both [aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 23: Fully Vaccinated coverage (by card or by history)) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(156 1)
**********************************************
*24. Fully Vaccinated coverage (by card)
gen Fully_Vaccinated8=0
replace Fully_Vaccinated8=1 if (bcg_card==1|bcg_card==-88) & (polio1_card==1|polio1_card==-88)& (pentavalent1_card==1|pentavalent1_card==-88) & (polio2_card==1|polio2_card==-88) & (pentavalent2_card==1|pentavalent2_card==-88) &  (polio3_card==1|polio3_card==-88)& (pentavalent3_card==1|pentavalent3_card==-88)& (measles1_card==1|measles1_card==-88)
label var Fully_Vaccinated8 "Infants who got 8 vaccines"
label define Fully_Vaccinated8_list 1 " Yes " 0 " No"
label val Fully_Vaccinated8 Fully_Vaccinated8_list
tabout Fully_Vaccinated8[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 24: Fully  vaccinated coverage (by card)-8 vaccinces) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(163 1)

*25. Fully Vaccinated coverage (by history)
gen Fully_Vaccinated_hist8=0
replace Fully_Vaccinated_hist8=1 if nocard_bcg_yn==1 & nocard_polio_count1>=3 & nocard_pentavalent_count1>=3 & nocard_measles_yn1==1
label var Fully_Vaccinated_hist8 "Infant who  fully vaccinated by history"
label define Fully_Vaccinated_hist8_list 1 " Yes " 0 " No"
label val Fully_Vaccinated_hist8 Fully_Vaccinated_hist8_list
tabout Fully_Vaccinated_hist8[aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 25: Fully Vaccinated coverage (by history)-8 vaccinces) and which is documented on any vaccination cards verified by REs) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(170 1)

*26. Fully Vaccinated coverage (by card or by history)
gen Fully_Vaccinated_both8=0
replace Fully_Vaccinated_both8=1 if ((bcg_card==1|bcg_card==-88) & (polio1_card==1|polio1_card==-88)& (pentavalent1_card==1|pentavalent1_card==-88)& (polio2_card==1|polio2_card==-88) & (pentavalent2_card==1|pentavalent2_card==-88) &  (polio3_card==1|polio3_card==-88)& (pentavalent3_card==1|pentavalent3_card==-88)& (measles1_card==1|measles1_card==-88))|(nocard_bcg_yn==1&nocard_polio_count1>=3& nocard_pentavalent_count1>=3&nocard_measles_yn1==1)
label var Fully_Vaccinated_both8 "Infant who fully vaccinated(by card or history)"
label define Fully_Vaccinated_both8_list 1 " Yes " 0 " No"
label val Fully_Vaccinated_both8 Fully_Vaccinated_both8_list
tabout Fully_Vaccinated_both8 [aw=OYFUweight]  using "`COHORT'_1Y_Priority_Analysis_$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 26: Fully Vaccinated coverage (by card or by history)-8 vaccinces) f(0 1) clab(n col_%) nwt(OYFUweight) sheet(Vaccination) location(177 1)

restore
exit










