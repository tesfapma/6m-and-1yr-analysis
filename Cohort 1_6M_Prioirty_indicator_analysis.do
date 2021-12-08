/* PMA Ethiopia 6 month Indicators file
This .do file takes the deidentified recoded cohort 1 6 month panel data from PMA Ethiopia and exports; 
1. key FP and RMNCH indicators
2. COVID-19 related indicators  */


clear
clear matrix
clear mata
capture log close
set maxvar 15000
set more off
numlabel, add

*******************************************************************************
* SET MACROS 
*******************************************************************************

*Year Macros
local YEAR 2021

*local COHORT "Cohort1"

* Set macros for data sets
local baselinedata "C:\Users\etale\Dropbox (Gates Institute)\PMAET2_Datasets\1-Cohort1\1-Baseline\Prelim100\Cohort1_Baseline_WealthWeightAll_21Apr2021.dta"
local sixweekdata "C:\Users\etale\Dropbox (Gates Institute)\PMAET2_Datasets\1-Cohort1\2-6Week\Prelim100\Cohort1_NoName_6W_Clean_10May2021.dta"
local sixmonthdata "C:\Users\etale\Dropbox (Gates Institute)\PMAET2_Datasets\1-Cohort1\3-6Month\Prelim100\Cohort1_NoName_6M_Clean_5Nov2021.dta"
local oneyeardata  "C:\Users\etale\Dropbox (Gates Institute)\PMAET2_Datasets\1-Cohort1\4-1Year\Prelim100\Cohort1_NoName_1Y_Clean_5Nov2021.dta"


* Set directory for country and round
global datadir "C:\PMA_ET_GIT\6M analysis data folder"


*******************************************************************************
***PREPARATION OF DATA and Merge all the panel datasets
*******************************************************************************

cd "$datadir"

* Set local/global macros for current date
local today=c(current_date)
local c_today= "`today'"
global date=subinstr("`c_today'", " ", "",.)

local excel "`COHORT'6M_Priority_indicator_Analysis$date.xlsx"
*Prepare Baseline for merge
use "`baselinedata'", clear
keep if FRS_result!=.

*Create a dummy participant ID for women who did not complete the baseline
replace participant_id=EA+"_"+member_number if participant_id==""
duplicates drop participant_id, force

tempfile base
save `base'.dta, replace

*Prepare 6-week for Merge
use "`sixweekdata'" , clear
foreach var of varlist _all {
	rename `var' SW`var'
	}
rename SWSWmetainstanceID SWmetainstanceID
rename SWparticipant_id participant_id
rename SWSWFUweight SWFUweight

duplicates drop participant_id, force

tempfile sw
save `sw'.dta, replace

*Merge Baseline and 6 Week
use `base'.dta, clear

merge 1:1 participant_id using `sw'.dta, gen(sw_merge)
drop if sw_merge==2

tempfile merge
save `merge'.dta, replace

*Prepare 6-month for Merge
use "`sixmonthdata'" , clear
foreach var of varlist _all {
	rename `var' SM`var'
	}
rename SMSMmetainstanceID SMmetainstanceID
rename SMparticipant_id participant_id
rename SMSMFUweight SMFUweight

duplicates drop participant_id, force

tempfile sm 
save `sm'.dta, replace

*Merge Baseline, Panel Pregnancy, 6 Week, and 6 month
use `merge'.dta, clear

merge 1:1 participant_id using `sm'.dta, gen(sm_merge)
drop if sm_merge==2

save `merge'.dta, replace

*Prepare 1-Year for Merge
use "`oneyeardata'" , clear
foreach var of varlist _all {
	rename `var' OY`var'
	}
rename OYOYmetainstanceID OYmetainstanceID
rename OYparticipant_id participant_id

drop OY_merge

duplicates drop participant_id, force

tempfile oy 
save `oy'.dta, replace

*Merge Baseline, Panel Pregnancy, 6 Week, 6 month, and 1-Year
use `merge'.dta, clear

merge 1:1 participant_id using `oy'.dta, gen(oy_merge)
replace oy_merge=2 if oy_merge==3 & (sm_merge==2 | sw_merge==2)

*Replace dummy participant ID=.
replace participant_id="" if participant_id==EA+"_"+member_number & FRS_result!=1

capture drop sw_followup
gen sw_followup=.
replace sw_followup=1 if SWresult==1 & SWrefuse_future_followup!=1 
replace sw_followup=2 if SWconsent==1 & SWrefuse_future_followup!=1 & SWresult!=1
replace sw_followup=3 if SWresult==4
replace sw_followup=4 if SWrefuse_future_followup==1 & SWresult==1
replace sw_followup=5 if SWresult==8 | SWresult==9
replace sw_followup=6 if SWresult!=1 & sw_followup==. & SWresult!=.
replace sw_followup=7 if SWavailable==3 
replace sw_followup=8 if SWresult==13
replace sw_followup=9 if SWpregnancy_outcome1!=1 & SWpregnancy_outcome2!=1 & SWresult==1
label define fu_list 1 "Completed and consented to FU" 2 "Incomplete but consented to FU" 3 "Refused" 4 "Refused follow-up" 5 "Respondent/Household moved" 6 "Incomplete, did not refuse" 7 "Respondent died" 8 "False pregnancy" 9 "No live births"
label val sw_followup fu_list 
label var sw_followup "Does the woman consent to FU after 6-week"

capture drop fu_after_6w
gen fu_after_6w=0 if SWresult!=.
replace fu_after_6w=1 if sw_followup==1 | sw_followup==2
replace fu_after_6w=-88 if sw_followup==6 | sw_followup==5
label val fu_after_6w yes_no_dnk_nr_list
label var fu_after_6w "Should this woman be followed up after 6-week"

capture drop sm_followup
gen sm_followup=.
replace sm_followup=1 if (SMresult==1 | SMresult==2) & SMrefused_follow_up!=1
replace sm_followup=2 if (SMstill_consent_yn==1 | SMcaregiver_consent==1) & SMrefused_follow_up!=1 & SMresult!=1
replace sm_followup=3 if SMresult==4
replace sm_followup=4 if SMrefused_follow_up==1 & (SMresult==1 | SMresult==2)
replace sm_followup=5 if SMresult==9 | SMresult==10
replace sm_followup=6 if SMresult!=. & sm_followup==.
replace sm_followup=7 if SMavailable==3 
replace sm_followup=8 if SMresult==13
label val sm_followup fu_list 
label var sm_followup "Does the woman/caregiver consent to FU after 6-week"

capture drop fu_after_6m
gen fu_after_6m=0 if SMresult!=.
replace fu_after_6m=1 if sm_followup==1 | sm_followup==2
replace fu_after_6m=-88 if sm_followup==6 | sm_followup==5
label val fu_after_6m yes_no_dnk_nr_list
label var fu_after_6m "Should this woman/caregiver be followed up after 6-month"

save, replace

save `COHORT'_Base_6W_6M_1Y_Merged.dta, replace

local Mergeddata "C:\PMA_ET_GIT\6M analysis data folder\Cohort1_Base_6W_6M_1Y_Merged.dta"

*******************************************************************************
* Backgroud characteristics: 
******************************************************************************* 

use "`Mergeddata'", clear

* Creating background characteristics for panel women are 6M follow up : age
preserve

keep if SMresult==1

tabout OYbase_age_cat5[aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 1: Age) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Backgroud) location(1 1)

* Creating background characteristics for panel women are 6M follow up : School

recode OYschool (.=0) (3 4 =3), gen(wge_school)
label define wge_school_list 0 "Never attended" 1 "Primary" 2 "Secondary " 3"more than secondary"
label val wge_school wge_school_list
label var wge_school "Education level: recoded"

tabout wge_school[aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 2: Education) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Backgroud) location(14 1)

restore


*******************************************************************************
* Family planning and RH indicators

******************************************************************************* 
preserve

keep if SMresult==1

* Table 1: The proportion of women who are using a method to delay pregnancy

tabout SMcurrent_user[aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 1: Proportion of women who are using a method to delay pregnancy) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(1 1)

* Table 2 :The proportion of women who are using modern method of family planning

gen modernmethod=0 if SMcurrent_user==1
replace modernmethod=1 if SMfster==1 | SMmster==1 |SMimpl==1| SMiud==1| SMinjection==1| SMpill==1| SMec==1| SMmc==1 |SMfc==1 |SMbeads==1 |SMlam==1
label define modernmethod_list 1"modern method: user" 0 "modern method: non-user"
label val modernmethod modernmethod_list
label var modernmethod " Modern contaceptive method user"

tabout modernmethod[aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 2 :The proportion of women who are using modern method of family planning) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(9 1)


* Table 3 :The proportion of women who are using short acting family planning

gen short_fp_mehtod=0 if SMcurrent_user==1
replace short_fp_mehtod=1 if SMinjection==1| SMpill==1| SMec==1| SMmc==1 |SMfc==1 |SMbeads==1 |SMlam==1
label define short_fp_mehtod_list 1"short acting method : user" 0 "short acting method: non-user"
label val short_fp_mehtod short_fp_mehtod_list
label var short_fp_mehtod " short acting fp user"

tabout short_fp_mehtod[aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 3 :The proportion of women who are using short acting family planning) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(17 1)


* Table 4 :The proportion of women who are using long acting family planning

gen long_fp_mehtod=0 if SMcurrent_user==1
replace long_fp_mehtod=1 if SMfster==1 | SMmster==1 |SMimpl==1| SMiud==1
label define long_fp_mehtod_list 1"long acting method : user" 0 "long acting method: non-user"
label val long_fp_mehtod long_fp_mehtod_list
label var long_fp_mehtod " short acting fp user"

tabout long_fp_mehtod[aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 4 :The proportion of women who are using long acting family planning) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(25 1)


* Table 5 :The proportion of women who are using traditional methods of family planning


gen traditional_fp_mehtod=0 if SMcurrent_user==1
replace traditional_fp_mehtod=1 if SMrhyth==1 | SMwithd==1
label define traditional_fp_mehtod_list 1"traditional method : user" 0 "traditional method: non-user"
label val traditional_fp_mehtod traditional_fp_mehtod_list
label var traditional_fp_mehtod " short acting fp user"

tabout traditional_fp_mehtod[aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 5 :The proportion of women who are using traditional methods of family planning) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(34 1)

restore

* Table 6 :The proportion of women who indcated a reason for choosing the current method

local row=45
 foreach reason in SMwhy_current_fp_duration SMwhy_current_fp_nofollowup SMwhy_current_fp_othersunavail SMwhy_current_fp_recommendation SMwhy_current_fp_fewersidefx SMwhy_current_fp_ignoranthusband SMwhy_current_fp_other {
preserve
 local varlab : var label `reason'
 
 tabout `reason'[aw=SMFUweight] if SMcurrent_user==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 6 :The proportion of women who said  `varlab' for choosing the current method") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(`row' 1)
 
 restore
 
local row=`row'+8
 
  }

  
* Table 7: the percentage of current users who were using their desired method
preserve

keep if SMresult==1


 tabout SMfp_obtain_desired [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 7: the percentage of current users who were using their desired method) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(101 1)
 
 restore 
 * Table 8: average number of days a women used the current method without stopping
 
 gen fp_use_duration_days =   SMtodaySIF- SMbegin_usingSIF
 label var fp_use_duration_days "the numebr of days a women used the current contraceptive method without stopping"
 
 local excel "`COHORT'6M_Priority_indicator_Analysis$date.xlsx"
  
 putexcel set "`excel'", modify sheet("FP_RH")
 
 putexcel A108=("Table 8: average number of days a women used the current method without stopping"), font(14) bold 
 putexcel A109 =("mean number of days")
 
 preserve 
 
 collapse (mean) fp_use_duration_days
 mkmat fp_use_duration_days
 putexcel B109=matrix(fp_use_duration_days)
 
 restore
 
* Table 9: The proportion of women who resumed sexual activity after delivery
preserve
keep if SMresult==1

tabout SMresumed_sex [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(table 9: The proportion of women who resumed sexual activity after delivery) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(111 1)

*Table 10: the proportion of women who ould you like to have a/another child or prefer not to have any / any more children

tabout SMmore_children [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 10: the proportion of women who ould you like to have a/another child or prefer not to have any / any more children) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(121 1)

restore

* Table 11:How long would you like to wait before the birth of your next child

 gen waiting_for_next_child=SMwait_birth_value if SMresult==1 
 replace  waiting_for_next_child=  SMwait_birth_value/12 if SMwait_birth==1
 label var waiting_for_next_child "How long would you like to wait before the birth of your next child(in years)"
 
 putexcel set "`excel'", modify sheet("FP_RH")
 
 putexcel A130=("Table 11:How long would you like to wait before the birth of your next child(in years)"), font(14) bold 
 putexcel A131 =("Mean number of years"), font(14)
 
 preserve 
 
 collapse (mean) waiting_for_next_child
 mkmat waiting_for_next_child
 putexcel B131=matrix(waiting_for_next_child)
 
 restore
 
 *Table 12:  Days since resuming sexual activity
 
gen      SMlast_time_sex=SWlast_time_sex_value if SMresumed_sex==1 & SMresult==1
replace SMlast_time_sex=SMlast_time_sex_value*7 if SMlast_time_sex_units ==2
replace SMlast_time_sex=SMlast_time_sex_value*30 if SMlast_time_sex_units ==3
label var SMlast_time_sex "When was the last time you had sexual intercourse(in days)"

putexcel A136=("Table 12:When was the last time you had sexual intercourse(in days)"), font(14) bold 
putexcel A137=("Mean number of days"), font(14)
 
 preserve 
 
  collapse (mean) SMlast_time_sex
  mkmat SMlast_time_sex
  putexcel B137=matrix(SMlast_time_sex)
  
 restore
 
 *Table 13:  Months since mensus returned
gen      SM_mensus_return=SMcycle_return_value if SMcycle_returned==1 & SMresult==1
replace SM_mensus_return=SMcycle_return_value/4 if SMcycle_return_units ==2
replace SM_mensus_return=SMcycle_return_value/30 if SMcycle_return_units ==3
label var SM_mensus_return "since when your mensus returned after delivery(in months)"

putexcel A141=("Table 13:since when your mensus returned after delivery(in months)"), font(14) bold 
putexcel A142 =("Mean number of months"), font(14)
 
 preserve 
 
  collapse (mean) SM_mensus_return
  mkmat SM_mensus_return
  putexcel B142=matrix(SM_mensus_return)
  
 restore
 
 * Table 14: implant specific indicator
local row=145
 foreach var in SMimplant_protect SMtold_implant_cost SMtold_removal SMwant_implant_removed SMimplant_removed_attempt {
preserve
 local varlab : var label `var'
 
 tabout `var'[aw=SMFUweight] if SMresult==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 14 :implant specific indicator: `varlab' ") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(`row' 1)
 
 restore
 
local row=`row'+8
   }
 
 
* Table 15: The proportion of women who have got any family planning informaiton, referrals or services at a time of visit for health check or immunization


gen SMfp_sevice_integration=0 if SMvaccines_yn1==1 |SMmother_baby_check_yn==1 & (SMresult==1)
replace SMfp_sevice_integration=1 if SMfp_info_non_vaccine_visit==1 |SMfp_info_vaccine_visit==1

label define SMfp_sevice_integration_list 1"yes" 0 "no"
label val SMfp_sevice_integration fp_sevice_integration_list
label var SMfp_sevice_integration " Women who received any family planning informaiton, referrals or services at a time of visit for health check or immunization "

tabout SMfp_sevice_integration [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 15 :women who have got any family planning informaiton, referrals or services at a time of visit for health check or immunization") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(190 1)


* Table 16:The proportion of women who were told about the side effects of the current method she is using

tabout SMfp_side_effects [aw=SMFUweight] if SMcurrent_user==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 16:The proportion of women who were told about the side effects of the current method she is using") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(200 1)

 * Table 17: The percentage of women who are current user and experienced side effects 
tabout SMcur_sideeff_yn [aw=SMFUweight] if SMcurrent_user==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 17: The percentage of women who are current user and experienced side effects ") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(210 1)
 

* table 18: Fp side effects: 
local row=220
foreach var in SMcur_sideeff_lessbleed SMcur_sideeff_morebleed SMcur_sideeff_irregbleed SMcur_sideeff_abpain SMcur_sideeff_gainweight SMcur_sideeff_loseweight SMcur_sideeff_acne SMcur_sideeff_headache SMcur_sideeff_infection SMcur_sideeff_nausea SMcur_sideeff_menscramp SMcur_sideeff_lowersex SMcur_sideeff_lesspleasure SMcur_sideeff_vagdry SMcur_sideeff_weakness SMcur_sideeff_diarrhea SMcur_sideeff_partner SMcur_sideeff_insertpain SMcur_sideeff_mood SMcur_sideeff_back SMcur_sideeff_other {

preserve
 local varlab : var label `var'
 
 tabout `var'[aw=SMFUweight] if SMresult==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 14. Fp side effect: `varlab' ") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(`row' 1)
 
 restore
 
local row=`row'+8


}


*Table 19. Percentage of women whose menses returned and who have resumed sexual intercourse 


 gen SMmensus_resumedsex=0 if SMresult==1
 replace SMmensus_resumedsex =1 if SMcycle_returned==1 & SMresumed_sex==1
label define SMmensus_resumedsex_list 1"yes" 0 "no"
label val SMmensus_resumedsex SMmensus_resumedsex_list
label var SMmensus_resumedsex " women whose menses returned and who have resumed sexual intercourse after delivery"

 tabout SMmensus_resumedsex [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 19. Percentage of women whose menses returned and who have resumed sexual intercourse") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(390 1)
 
 *Table 20. The proportion of women who jointy decided with her husband/partner to use famliy planning method 
 
 gen fp_use_jointdecision = 0 if SMcurrent_user==1
 replace fp_use_jointdecision=1 if fp_use_jointdecision==3
 label define fp_use_jointdecision_list 1"joint decision:yes" 0 "Joint Decision:no"
label val fp_use_jointdecision fp_use_jointdecision_list
label var fp_use_jointdecision " women who jointly decuided with her partner to use current Family planning"
tabout fp_use_jointdecision [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 20. The proportion of women who jointy decided with her husband/partner to use famliy planning method") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(400 1)


*Table 21. The proportion of women who jointy decided with her husband/partner to not use famliy planning method 
 
 gen fp_notuse_jointdecision = 0 if SMcurrent_user==1
 replace fp_notuse_jointdecision=1 if SMwhy_not_decision==3
 label define fp_notuse_jointdecision_list 1"joint decision:yes" 0 "Joint Decision:no"
label val fp_notuse_jointdecision fp_notuse_jointdecision_list
label var fp_notuse_jointdecision " women who jointly decuided with her partner to not use current Family planning"
tabout fp_notuse_jointdecision [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 21. The proportion of women who jointy decided with her husband/partner to not use famliy planning method") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(410 1)

*Table 22. The proportion of women who discussed with her husband/partner to aviod or delay pregnancy

tabout SMpartner_discussion_before [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 22. The proportion of women who discussed with her husband/partner to aviod or delay pregnancy") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(420 1)

*Table 23. The proportion of women who would feel happy if they got pregnant
 gen SM_happy_ifpregnant = 0 if SMresult==1 & SMpregnant!=1
 replace SM_happy_ifpregnant=1 if SMpreg_now_reaction==1|SMpreg_now_reaction==2
 label define SM_happy_ifpregnant_list 1"would feel happy" 0 " would feel unhappy"
 label val SM_happy_ifpregnant SM_happy_ifpregnant_list
 label var SM_happy_ifpregnant "women who would feel happy if she got pregnant"
 
 tabout SM_happy_ifpregnant [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 23. The proportion of women who would feel happy if they got pregnant") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(430 1)
 
 * table 24. The proportion of women who were not told that she can could switch to a different method in the future
 
 tabout SMmethod_switch [aw=SMFUweight] if SMresult==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("table 24. The proportion of women who were not told that she can could switch to a different method in the future") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(430 1)
 
 * table 25. The proportion of women who felt pressured from a health service provider to accept the current method

 tabout SMfp_provider_forced [aw=SMFUweight] if SMresult==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 25.The proportion of women who felt pressured from a health service provider to accept the current method") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(440 1)
 
 
*******************************************************************************
* Nutrition indicators

******************************************************************************* 

 * table 1. Exclusive breastfeeding
 
 
 



 



 
 



















