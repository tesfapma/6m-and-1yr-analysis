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

*Year and cohort Macros
local YEAR 2021
local COHORT "Cohort1"
* Set data directory
global datadir "C:\PMA_ET_GIT\6M analysis data folder"

* Set local/global macros for current date
local today=c(current_date)
local c_today= "`today'"
global date=subinstr("`c_today'", " ", "",.)

local excel "`COHORT'6M_Priority_indicator_Analysis$date.xlsx"

local Mergeddata "C:\PMA_ET_GIT\6M analysis data folder\Cohort1_Base_6W_6M_1Y_Merged.dta"

*******************************************************************************
* Backgroud characteristics: 
******************************************************************************* 
cd "$datadir"
use "`Mergeddata'", clear

* Table 1. background characteristics for panel women : age
preserve

keep if SMresult==1 |SMresult==2
*Generate 0/1 urban/rural variable
gen urban=ur==1
label variable urban "Urban/rural place of residence"
label define urban 1 "Urban" 0 "Rural"
label value urban urban
tab urban, mis 



tabout OYbase_age_cat5[aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 1: Age) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Backgroud) location(1 1)

* Table 2. background characteristics for panel women : age School

recode OYschool (.=0) (3 4 =3), gen(wge_school)
label define wge_school_list 0 "Never attended" 1 "Primary" 2 "Secondary " 3"more than secondary"
label val wge_school wge_school_list
label var wge_school "Education level: recoded"

tabout wge_school[aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 2: Education) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Backgroud) location(14 1)


*Table3. background characteristics for panel women : Parity
egen parity3=cut(total_births), at(0, 2, 4, 30) icodes
lab def parity3l 0 "0-1 children" 1 "2-3 children" 2 "4+ children"
lab val parity3 parity3l
replace parity3=0 if total_births==.|total_births==-99

tabout parity3[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 3: Parity) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Backgroud) location(27 1)

*Table 4. background characteristics for panel women : Region
tabout SMregion[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 4: Region) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Backgroud) location(35 1)

*Table 5: background characteristics for panel women :  Residence
tabout urban[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 5: Residence) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Backgroud) location(47 1)
 
*Table 6: background characteristics for panel women :  Wealth
tabout wealthquintile[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 6: Wealth) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Backgroud) location(56 1)

*Table 7: background characteristics for panel women :  Marital Status
recode OYbase_married2 (0 .=2)
tabout OYbase_married2[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 7: Marital Status) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Backgroud) location(67 1)


*******************************************************************************
* Family planning and RH indicators

******************************************************************************* 
label define yesno_list 1"yes" 0 "no"

* Table 1: The proportion of women who are using a method to delay pregnancy

tabout SMcurrent_user[aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 1: Proportion of women who are using a method to delay pregnancy) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(1 1)

* Table 2 :The proportion of women who are using modern method of family planning

gen modernmethod=0 
replace modernmethod=1 if SMfster==1 | SMmster==1 |SMimpl==1| SMiud==1| SMinjection==1| SMpill==1| SMec==1| SMmc==1 |SMfc==1 |SMbeads==1 |SMlam==1
label define modernmethod_list 1"modern method: user" 0 "modern method: non-user"
label val modernmethod modernmethod_list
label var modernmethod " Modern contaceptive method user"

tabout modernmethod[aw=SMFUweight] if SMcurrent_user==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 2 :The proportion of women who are using modern method of family planning) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(9 1)


* Table 3 :The proportion of women who are using short acting family planning

gen short_fp_mehtod=0 
replace short_fp_mehtod=1 if SMinjection==1| SMpill==1| SMec==1| SMmc==1 |SMfc==1 |SMbeads==1 |SMlam==1
label define short_fp_mehtod_list 1"short acting method : user" 0 "short acting method: non-user"
label val short_fp_mehtod short_fp_mehtod_list
label var short_fp_mehtod " short acting fp user"

tabout short_fp_mehtod[aw=SMFUweight] if SMcurrent_user==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 3 :The proportion of women who are using short acting family planning) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(17 1)


* Table 4 :The proportion of women who are using long acting family planning

gen long_fp_mehtod=0 if SMcurrent_user==1
replace long_fp_mehtod=1 if SMfster==1 | SMmster==1 |SMimpl==1| SMiud==1
label define long_fp_mehtod_list 1"long acting method : user" 0 "long acting method: non-user"
label val long_fp_mehtod long_fp_mehtod_list
label var long_fp_mehtod " short acting fp user"

tabout long_fp_mehtod[aw=SMFUweight] if SMcurrent_user==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 4 :The proportion of women who are using long acting family planning) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(25 1)


* Table 5 :The proportion of women who are using traditional methods of family planning


gen traditional_fp_mehtod=0 if SMcurrent_user==1
replace traditional_fp_mehtod=1 if SMrhyth==1 | SMwithd==1
label define traditional_fp_mehtod_list 1"traditional method : user" 0 "traditional method: non-user"
label val traditional_fp_mehtod traditional_fp_mehtod_list
label var traditional_fp_mehtod " short acting fp user"

tabout traditional_fp_mehtod[aw=SMFUweight] if SMcurrent_user==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 5 :The proportion of women who are using traditional methods of family planning) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(34 1)



* Table 6 :The proportion of women who indcated a reason for choosing the current method

local row=45
 foreach reason in SMwhy_current_fp_duration SMwhy_current_fp_nofollowup SMwhy_current_fp_othersunavail SMwhy_current_fp_recommendation SMwhy_current_fp_fewersidefx SMwhy_current_fp_ignoranthusband SMwhy_current_fp_other {
 
local varlab : var label `reason'
 
 tabout `reason'[aw=SMFUweight] if SMcurrent_user==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 6 :The proportion of women who said  `varlab' for choosing the current method") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(`row' 1)
 
local row=`row'+8
 
  }

  
* Table 7: the percentage of current users who were using their desired method

 tabout SMfp_obtain_desired [aw=SMFUweight] if SMcurrent_user==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 7: the percentage of current users who were using their desired method) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(101 1)
 
 restore 
 * Table 8: average number of days a women used the current method without stopping
 preserve
 keep if SMresult==1 |SMresult==2
 gen fp_use_duration_days =   SMtodaySIF- SMbegin_usingSIF
  label var fp_use_duration_days "the numebr of days a women used the current contraceptive method without stopping"
 
 putexcel set "`excel'", modify sheet("FP_RH")
 
 putexcel A108=("Table 8: average number of days a women used the current method without stopping"), font(14) bold 
 putexcel A109 =("mean number of days")
 
 collapse (mean) fp_use_duration_days if fp_use_duration_days>0
 mkmat fp_use_duration_days
 putexcel B109=matrix(fp_use_duration_days)
 
 restore
 
* Table 9: The proportion of women who resumed sexual activity after delivery
preserve
keep if SMresult==1 |SMresult==2
recode SMresumed_sex(-99=0)
tabout SMresumed_sex [aw=SMFUweight] if SMpregnant==0 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(table 9: The proportion of women who resumed sexual activity after delivery) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(111 1)

*Table 10: the proportion of women who ould you like to have a/another child or prefer not to have any / any more children
recode SMmore_children (-88 .=0)
tabout SMmore_children [aw=SMFUweight] if SMpregnant==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 10: the proportion of women who ould you like to have a/another child or prefer not to have any / any more children) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(121 1)

*Table 11: How long would you like to wait before the birth of your next child
tabout SMwait_birth[aw=SMFUweight] if SMpregnant !=1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 11:Would you like to have a/another child or would you prefer not to have any / any more children?) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(129 1)
restore

* Table 11a: The average number of years a women would like to wait for her next child
 preserve
 keep if SMresult==1 |SMresult==2
 gen waiting_for_next_child=SMwait_birth_value 
 replace  waiting_for_next_child=  SMwait_birth_value/12 if SMwait_birth==1
 label var waiting_for_next_child "The average number of years a women would like to wait for her next child"
 
 putexcel set "`excel'", modify sheet("FP_RH")
 
 putexcel A139=("Table 11a:How long would you like to wait before the birth of your next child(in years)"), font(14) bold 
 putexcel A140 =("Mean number of years"), font(14)
 
 collapse (mean) waiting_for_next_child if SMpregnant==0
 mkmat waiting_for_next_child
 putexcel B140=matrix(waiting_for_next_child)
 
 restore
 
*Table 12: When was the last time you had sexual intercourse?
 
preserve
keep if SMresult==1 |SMresult==2 
recode SMlast_time_sex_units(-88 -99=.)
tabout  SMlast_time_sex_units[aw=SMFUweight] if OYresumed_sex==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 12: When was the last time you had sexual intercourse?) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(146 1)
 
 
 *Table 12a:  When was the last time you had sexual intercourse(in days)
 
gen      SMlast_time_sex=SWlast_time_sex_value if SMresumed_sex==1
replace SMlast_time_sex=SMlast_time_sex_value*7 if SMlast_time_sex_units ==2
replace SMlast_time_sex=SMlast_time_sex_value*30 if SMlast_time_sex_units ==3
label var SMlast_time_sex "When was the last time you had sexual intercourse(in days)"

putexcel A154=("Table 12a:When was the last time you had sexual intercourse(in days)"), font(14) bold 
putexcel A155=("Mean number of days"), font(14)
 
  collapse (mean) SMlast_time_sex if SMpregnant==0
  mkmat SMlast_time_sex
  putexcel B155=matrix(SMlast_time_sex)
  
 restore
*Table 13: When did your last menstural period start?
 
preserve
keep if SMresult==1 |SMresult==2 
recode SMcycle_return_units(-88=.)
tabout SMcycle_return_units [aw=SMFUweight] if SMcycle_returned==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 13: When did your last menstural period start?) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(163 1)
 
 *Table 13a:  Months since mensus returned
gen      SM_mensus_return=SMcycle_return_value if SMcycle_returned==1
replace SM_mensus_return=SMcycle_return_value/4 if SMcycle_return_units ==2
replace SM_mensus_return=SMcycle_return_value/30 if SMcycle_return_units ==3
label var SM_mensus_return "since when your mensus returned after delivery(in months)"

putexcel A171=("Table 13a:since when your mensus returned after delivery(in months)"), font(14) bold 
putexcel A172 =("Mean number of months"), font(14)
 
collapse (mean) SM_mensus_return if SMpregnant==0
mkmat SM_mensus_return
putexcel B172=matrix(SM_mensus_return)
  
restore
 
 * Table 14: implant specific indicator
preserve
keep if SMresult==1 |SMresult==2 
 
local row=180
 foreach var in SMimplant_protect SMtold_implant_cost SMtold_removal SMwant_implant_removed SMimplant_removed_attempt {
 local varlab : var label `var'
 
 tabout `var'[aw=SMFUweight] if SMimpl==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 14x :implant specific indicator: `varlab' ") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(`row' 1)
local row=`row'+8
   }
 
 
* Table 15: The proportion of women who have got any family planning informaiton, referrals or services at a time of visit for health check or immunization

gen SMfp_sevice_integration=0 if SMvaccines_yn1==1 |SMmother_baby_check_yn==1
replace SMfp_sevice_integration=1 if SMfp_info_non_vaccine_visit==1 |SMfp_info_vaccine_visit==1

label val SMfp_sevice_integration yesno_list
label var SMfp_sevice_integration " Women who received any family planning informaiton, referrals or services at a time of visit for health check or immunization "

tabout SMfp_sevice_integration [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 15 :women who have got any family planning informaiton, referrals or services at a time of visit for health check or immunization") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(223 1)

* Table 16:The proportion of women who were told about the side effects of the current method she is using
tabout SMfp_side_effects [aw=SMFUweight] if SMcurrent_user==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 16:The proportion of women who were told about the side effects of the current method she is using") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(236 1)

 * Table 17: The percentage of women who are current user and experienced side effects 
tabout SMcur_sideeff_yn [aw=SMFUweight] if SMcurrent_user==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 17: The percentage of women who are current user and experienced side effects ") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(244 1)
 
* Table 18: Fp side effects: 
local row=252
foreach var in SMcur_sideeff_lessbleed SMcur_sideeff_morebleed SMcur_sideeff_irregbleed SMcur_sideeff_abpain SMcur_sideeff_gainweight SMcur_sideeff_loseweight SMcur_sideeff_acne SMcur_sideeff_headache SMcur_sideeff_infection SMcur_sideeff_nausea SMcur_sideeff_menscramp SMcur_sideeff_lowersex SMcur_sideeff_lesspleasure SMcur_sideeff_vagdry SMcur_sideeff_weakness SMcur_sideeff_diarrhea SMcur_sideeff_partner SMcur_sideeff_insertpain SMcur_sideeff_mood SMcur_sideeff_back SMcur_sideeff_other {

 local varlab : var label `var'
 
 tabout `var'[aw=SMFUweight] if SMresult==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 18x. Fp side effect: `varlab' ") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(`row' 1)
 
local row=`row'+8
}

*Table 19. Percentage of women whose menses returned and who have resumed sexual intercourse 

 gen SMmensus_resumedsex=0 if SMresult==1
 replace SMmensus_resumedsex =1 if SMcycle_returned==1 & SMresumed_sex==1
label define SMmensus_resumedsex_list 1"yes" 0 "no"
label val SMmensus_resumedsex SMmensus_resumedsex_list
label var SMmensus_resumedsex " women whose menses returned and who have resumed sexual intercourse after delivery"

 tabout SMmensus_resumedsex [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 19. Percentage of women whose menses returned and who have resumed sexual intercourse") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(420 1)
 
 *Table 20. The proportion of women who jointy decided with her husband/partner to use famliy planning method 
 
 gen SMfpuse_jointdecision = 0 if SMcurrent_user==1
 replace SMfpuse_jointdecision=1 if SMwhy_decision==3
 label define fp_use_jointdecision_list 1"joint decision:yes" 0 "Joint Decision:no"
label val SMfpuse_jointdecision fp_use_jointdecision_list
label var SMfpuse_jointdecision " women who jointly decided with her partner to use current Family planning"
tabout SMfpuse_jointdecision [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 20. The proportion of women who jointy decided with her husband/partner to use famliy planning method") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(428 1)


*Table 21. The proportion of women who jointy decided with her husband/partner to not use famliy planning method 
 
 gen SMfp_notuse_jointdecision = 0 if SMcurrent_user==1
 replace SMfp_notuse_jointdecision=1 if SMwhy_not_decision==3
 label define fp_notuse_jointdecision_list 1"joint decision:yes" 0 "Joint Decision:no"
label val SMfp_notuse_jointdecision fp_notuse_jointdecision_list
label var SMfp_notuse_jointdecision " women who jointly decuided with her partner to not use current Family planning"
tabout SMfp_notuse_jointdecision [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 21. The proportion of women who jointy decided with her husband/partner to not use famliy planning method") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(436 1)

*Table 22. The proportion of women who discussed with her husband/partner to aviod or delay pregnancy

tabout SMpartner_discussion_before [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 22. The proportion of women who discussed with her husband/partner to aviod or delay pregnancy") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(444 1)

*Table 23. The proportion of women who would feel happy if they got pregnant
 gen SM_happy_ifpregnant = 0 if SMresult==1 & SMpregnant!=1
 replace SM_happy_ifpregnant=1 if SMpreg_now_reaction==1|SMpreg_now_reaction==2
 label define SM_happy_ifpregnant_list 1"would feel happy" 0 " would feel unhappy"
 label val SM_happy_ifpregnant SM_happy_ifpregnant_list
 label var SM_happy_ifpregnant "women who would feel happy if she got pregnant"
 
 tabout SM_happy_ifpregnant [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 23. The proportion of women who would feel happy if they got pregnant") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(452 1)
 
*Table 24. The proportion of women who were not told that she can could switch to a different method in the future
 
 tabout SMmethod_switch [aw=SMFUweight] if SMresult==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("table 24. The proportion of women who were not told that she can could switch to a different method in the future") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(460 1)
 
*Table 25. The proportion of women who felt pressured from a health service provider to accept the current method

 tabout SMfp_provider_forced [aw=SMFUweight] if SMresult==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 25.The proportion of women who felt pressured from a health service provider to accept the current method") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(FP_RH) location(468 1)

restore
 
********************************************************************************
* COVID-19 related indicators
*
*******************************************************************************

preserve
keep if SMresult==1|SMresult==2 
*Table 1: Percentage of mothers and caretakers who reported degree of awareness about the COVID otbreak.
tabout SMcovid_knowledge[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 1: Percentage of mothers and caretakers who reported degree of awareness about the COVID outbreak) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(1 1)

*Tabel 2: COVID awareness communication channel source *Percentage of mothers and caretakers with self reported awareness of COVID, who identified [Communication Channel] as their source of awareness.
local row=10 
foreach var in SMhow_learned_covid_news SMhow_learned_covid_radio SMhow_learned_covid_tv SMhow_learned_covid_poster SMhow_learned_covid_phone SMhow_learned_covid_ethio SMhow_learned_covid_family SMhow_learned_covid_friends SMhow_learned_covid_leaders SMhow_learned_covid_socialmedia SMhow_learned_covid_hp SMhow_learned_covid_govt SMhow_learned_covid_school SMhow_learned_covid_other {
	local varlab : var label `var'
	recode `var' (-99 . =0) 
	tabout `var' [aw=SMFUweight] if (SMcovid_knowledge==1|SMcovid_knowledge==2|SMcovid_knowledge==3) using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 2X:COVID Awareness Source: `varlab') f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(`row' 1)
local row=`row'+7
	}	

* Tabel 3:Trusted COVID Information Source
*Percentage of mothers and caretakers with self reported awareness of COVID, who identified [Communication Channel] as their trusted source of awareness.
local row=108 
foreach var in SMcovid_trust_source_news SMcovid_trust_source_radio SMcovid_trust_source_tv SMcovid_trust_source_poster SMcovid_trust_source_phone SMcovid_trust_source_ethio SMcovid_trust_source_family SMcovid_trust_source_friends SMcovid_trust_source_leaders SMcovid_trust_source_socialmedia SMcovid_trust_source_hp SMcovid_trust_source_govt SMcovid_trust_source_school SMcovid_trust_source_other {
	local varlab : var label `var'
	recode `var' (-99 . =0) 
	tabout `var' [aw=SMFUweight] if (SMcovid_knowledge==1|SMcovid_knowledge==2|SMcovid_knowledge==3) using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 3X:Trusted COVID Information Source `"`: var label `var''"') f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(`row' 1)
local row=`row'+7
	}	

* Table 4: COVID Community Risk Perception (Concern)
recode SMcommunity_spread_concern (.=0)
tabout SMcommunity_spread_concern[aw=SMFUweight] if (SMcovid_knowledge==1|SMcovid_knowledge==2|SMcovid_knowledge==3) using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 4: Percentage of mothers and caretakers with some awareness of COVID, who reported concern of COVID spread in their community.) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(206 1)

*Table 5: COVID Self Risk Perception (Concern)
 recode SMself_covid_concern (.=0)
 tabout SMself_covid_concern [aw=SMFUweight] if (SMcovid_knowledge==1|SMcovid_knowledge==2|SMcovid_knowledge==3) using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 5: Percentage of mothers and caretakers with some awareness of COVID, who reported concern of getting COVID.) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(216 1)
 
* Table 6: COVID Prevention Practice
recode SMable_to_distance (-99 .=0)
tabout SMable_to_distance[aw=SMFUweight] if (SMcovid_knowledge==1|SMcovid_knowledge==2|SMcovid_knowledge==3) using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 6: Percentage of mothers and caretakers with self reported awareness of COVID, who reported avoiding contact with non household persons to prevent getting COVID.) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(227 1)

*Table 7: Reason for non practice of COVID prevention
local row=235 
foreach var in  SMwhy_unable_to_distance_job SMwhy_unable_to_distance_market SMwhy_unable_to_distance_water SMwhy_unable_to_distance_school SMwhy_unable_to_distance_funeral SMwhy_unable_to_distance_church SMwhy_unable_to_distance_visit SMwhy_unable_to_distance_health SMwhy_unable_to_distance_other {
	local varlab : var label `var'
	recode `var' (-99 . =0) 
	tabout `var' [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 7X:Reason for non practice of COVID prevention :`varlab') f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(`row' 1)
local row=`row'+7
	}	

*Table 8: Household Level COVID Economic Effect
gen COVID_Eco_effect=0 
replace COVID_Eco_effect=1 if SMhousehold_income_loss==2 | SMhousehold_income_loss==3
label define COVID_Eco_effectlist 0 "Not Change" 1 "Partial/Complete"
label val COVID_Eco_effect COVID_Eco_effectlist
label var COVID_Eco_effect "Household Level COVID Economic Effect"

tabout  COVID_Eco_effect [aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 8: Percentage of mothers and caretakers who reported partial or complete loss of income to their household due to COVID otbreak.) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(299 1)

*Table 9: Individual Level COVID Economic Effect (For Partially affected HH)
tabout SMself_income_loss [aw=SMFUweight] if SMhousehold_income_loss==2  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 9:Percentage of mothers and caretakers who reported some level of personal loss of income due to COVID otbreak) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(306 1)

*Table 10: Households with No Food Due to COVID
recode SMlack_food_4wks (-88=0)
tabout SMlack_food_4wks [aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 10:Percentage of women who reported themselves or a member of family to eat nothing for a day due to COVID otbreak) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(316 1)

*Table 11: Frequency of No Food Due to COVID
tabout SMlack_food_frequency [aw=SMFUweight] if SMlack_food_4wks==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 11:Percentage of women with no food who reported such lack of food [Rarely/Sometimes/Often] in a month) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(326 1)
restore
 * First reshape the data to accoun for twins for COVID indicators related to infants
preserve
keep if SMresult==1|SMresult==2 

unab kid_var : SMgender1-SMfever_trt_other1
local stubs: subinstr local kid_var "1" "", all
local stubs: subinstr local stubs "SMpolio_" "SMpolio1_", all
local stubs: subinstr local stubs "SMpentavalent_" "SMpentavalent1_", all
local stubs: subinstr local stubs "SMpcv_" "SMpcv1_", all
local stubs: subinstr local stubs "SMrota_" "SMrota1_", all
local stubs: subinstr local stubs "SMmeasles_" "SMmeasles1_", all
gen mother_ID=SMmetainstanceID
reshape long `stubs', i(mother_ID) j(index)
 
*Table 12: COVID Effect on Childhood Vaccination
tabout SMvax_access_diff_yn [aw=SMFUweight] if SMstill_alive==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 12:ercentage of mothers and caretakers with alive infant, who experienced difficulties of getting vaccination service for their infant during COVID pandemic) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(334 1)

*Table 13: Percentage of mothers and caretakers who experienced difficulties of vaccination service mainly due to [TYPE of DIFFICULTY].
label var SMvax_diff_closed "Healthcare facility or doctor’s office close or services not available"
label var SMvax_diff_nohew "HEW stopped visiting community"
label var SMvax_diff_husbopp "Partner does not approve"
label var SMvax_diff_notransport "No transportation to access healthcare services"
label var SMvax_diff_govt "Unable to access services because of government restrictions on movement"
label var SMvax_diff_cost "Unable to afford healthcare services"
label var SMvax_diff_fearinfect "Fear of getting or spreading COVID-19"
label var SMvax_diff_interrupt "Vaccination outreach program interrupted"
label var SMvax_diff_other "Other"

local row=344 
foreach var in  SMvax_diff_closed SMvax_diff_nohew SMvax_diff_husbopp SMvax_diff_notransport SMvax_diff_govt SMvax_diff_cost SMvax_diff_fearinfect SMvax_diff_interrupt SMvax_diff_other {
	local varlab : var label `var'
	tabout `var' [aw=SMFUweight] if SMvax_access_diff_yn==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 13X: Experienced difficulties of vaccination service mainly due:`varlab'") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(`row' 1)
local row=`row'+8
	}	
*Table 14:Percentage of mothers and caretakers with alive infant, who reported missing a vaccination for their infant during COVID pandemic.
tabout SMmiss_vacc [aw=SMFUweight] if SMstill_alive==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 14:Percentage of mothers and caretakers with alive infant, who reported missing a vaccination for their infant during COVID pandemic.) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(423 1)

*Table 15: Percentage of mothers and caretakers with sick infant in last two weeks, who experienced difficulties of getting health care for their sick infant during COVID pandemic.
gen mother_with_illchild = 0 if SMstill_alive==1
replace mother_with_illchild=1 if SMill_poorfeed==1 | SMill_eyeinfect==1 | SMill_skinles==1 | SMill_convusle==1 | SMill_lethargy==1 | SMill_unconsc==1 | SMill_fever==1 | SMill_cough==1 | SMill_sorethrt==1 | SMill_fastbrth==1 | SMill_difbreath==1 | SMill_diarrhea==1 | SMill_vomit==1 | SMill_nostool==1 | SMill_swelling==1 | SMill_other==1 
label var mother_with_illchild "A mother and caretaker with sick infant in the last two weeks" 
label valu mother_with_illchild  yesno_list

tabout  SMhc_child_access_diff_yn [aw=SMFUweight] if mother_with_illchild==1  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 15: Percentage of mothers and caretakers with sick infant in last two weeks, who experienced difficulties of getting health care for their sick infant during COVID pandemic) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(430 1)

*Table 16: Percentage of mothers and caretakers who experienced difficulties of sick child health care service mainly due to [TYPE of DIFFICULTY].
label var SMhc_child_diff_closed "Healthcare facility or doctor’s office close or services not available"
label var SMhc_child_diff_nohew"HEW stopped visiting community"
label var SMhc_child_diff_husbopp "Partner does not approve"
label var SMhc_child_diff_notransport "No transportation to access healthcare services"
label var SMhc_child_diff_govt "Unable to access services because of government restrictions on movement"
label var SMhc_child_diff_cost "Unable to afford healthcare services"
label var SMhc_child_diff_fearinfect "Fear of getting or spreading COVID-19"
label var SMhc_child_diff_other "Other"

local row=438 
foreach var in  SMhc_child_diff_closed SMhc_child_diff_nohew SMhc_child_diff_husbopp SMhc_child_diff_notransport SMhc_child_diff_govt SMhc_child_diff_cost SMhc_child_diff_fearinfect SMhc_child_diff_other {
	local varlab : var label `var'
	tabout `var' [aw=SMFUweight] if SMvax_access_diff_yn==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 16X: experienced difficulties of sick child health care service mainly due:  `varlab') f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(`row' 1)
local row=`row'+8
	}	
	
restore


*Table 17:Percentage of postpartum women, who experienced difficulties of getting postnatal care during COVID pandemic.
preserve
keep if SMresult==1|SMresult==2 

recode SMpnc_access_diff_yn (-88=3)
tabout  SMpnc_access_diff_yn [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 17:Percentage of postpartum women, who experienced difficulties of getting postnatal care during COVID pandemic.) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(510 1)

*Table 18:Percentage of mothers and caretakers who experienced difficulties of PNC service mainly due to [TYPE of DIFFICULTY].

label var SMpnc_diff_closed "Healthcare facility or doctor’s office close or services not available"
label var SMpnc_diff_nohew"HEW stopped visiting community"
label var SMpnc_diff_husbopp "Partner does not approve"
label var SMpnc_diff_notransport "No transportation to access healthcare services"
label var SMpnc_diff_govt "Unable to access services because of government restrictions on movement"
label var SMpnc_diff_cost "Unable to afford healthcare services"
label var SMpnc_diff_fearinfect "Fear of getting or spreading COVID-19"
label var SMpnc_diff_interrupt "Vaccination outreach program interrupted"
label var SMpnc_diff_other "Other"

local row=518
foreach var in SMpnc_diff_closed SMpnc_diff_nohew SMpnc_diff_husbopp SMpnc_diff_notransport SMpnc_diff_govt SMpnc_diff_cost SMpnc_diff_fearinfect SMpnc_diff_interrupt SMpnc_diff_other {
	local varlab : var label `var'
	tabout `var' [aw=SMFUweight] if  SMpnc_access_diff_yn==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 18X: mothers and caretakers who experienced difficulties of PNC service mainly due to: `varlab') f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(`row' 1)
local row=`row'+8
	}	


*Table 19: Percentage of postpartum women whose fertility preference is affected by COVID pandemic
 
 tabout  SMcovid19_more_child [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 19: Percentage of postpartum women whose fertility preference is affected by COVID pandemic) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(598 1)
 
 *Table 20: Percentage of postpartum women whose pregnancy spacing preference is affected by COVID pandemic

 tabout  SMcovid19_impact_wait [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 20: Percentage of postpartum women whose pregnancy spacing preference is affected by COVID pandemic) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(606 1)

**Table 21:Percentage of postpartum women whose pregnancy spacing preference is [Shorter/longer] than before due to COVID pandemic
tabout SMsooner_later [aw=SMFUweight] if SMcovid19_impact_wait==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 21:Percentage of postpartum women whose pregnancy spacing preference is [Shorter/longer] than before due to COVID pandemic) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(614 1)

*Table 22:Percentage of postpartum women who used emergency contraception during COVID pandemic
tabout SMcovid_ec_used [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 22:Percentage of postpartum women who used emergency contraception during COVID pandemic) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(622 1)


*Table 23:Percentage of postpartum women, who experienced difficulties of accessing FP services during COVID pandemic
recode SMfp_access_diff_yn (-88=3)
tabout  SMfp_access_diff_yn [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 23:Percentage of postpartum women, who experienced difficulties of accessing FP services during COVID pandemic) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(630 1)


*Table 24:Percentage of postpartum women who experienced difficulties of accessing FP service mainly due to [Type of difficulties]


label var SMfp_diff_closed "Healthcare facility or doctor’s office close or services not available"
label var SMfp_diff_nohew"HEW stopped visiting community"
label var SMfp_diff_husbopp "Partner does not approve"
label var SMfp_diff_cost "Unable to afford FP services"
label var SMfp_diff_notransport "No transportation to access healthcare services"
label var SMfp_diff_prfnotavail "Preferred method not available"
label var SMfp_diff_worrynostaff "Concern that no medical staff will be available"
label var SMfp_diff_govt "Unable to access services because of government restrictions on movement"
label var SMfp_diff_fearinfect "Fear of getting or spreading COVID-19 at healthcare facilities"
label var SMpnc_diff_cost "Unable to afford healthcare services"

local row=638 
foreach var in SMfp_diff_closed SMfp_diff_nohew SMfp_diff_husbopp SMfp_diff_cost SMfp_diff_notransport SMfp_diff_prfnotavail SMfp_diff_worrynostaff SMfp_diff_govt SMfp_diff_fearinfect SMfp_diff_other {
	local varlab : var label `var'
tabout `var' [aw=SMFUweight] if  SMpnc_access_diff_yn==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 24X: experienced difficulties of accessing FP service mainly due to: `varlab') f(0 1) clab(n col_%) nwt(SMFUweight) sheet(COVID) location(`row' 1)
local row=`row'+8
	}	

restore
*******************************************************************************
* PNC indicators
******************************************************************************* 	
preserve
keep if SMresult==1|SMresult==2 


*Table 1. the proportion of women delivered at health facilities and  stayed in the health facility after delivery
gen delivery_at_healthfacility = 0 
replace delivery_at_healthfacility=1 if SMdelivery_place==11 | SMdelivery_place==12 |SMdelivery_place==13 |SMdelivery_place==16 |SMdelivery_place==21 |SMdelivery_place==31 | SMdelivery_place==36
label value delivery_at_healthfacility yesno_list
label var delivery_at_healthfacility "women who delivered at health facilities"
 
recode SMfacility_stay_units (-88 -99 = .)
tabout  SMfacility_stay_units [aw=SMFUweight] if delivery_at_healthfacility==1  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 1. the proportion of women delivered at health facilities and  stayed in the health facility after delivery") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(PNC) location(1 1)

*Table 2. the proportion of women who went to maternity waiting home in the health facility after delivery
tabout  SMmaternity_home_yn [aw=SMFUweight] if delivery_at_healthfacility==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 2. the percentage of women who went to maternity waiting home in the health facility after delivery) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(PNC) location(10 1)

*Table 3. The proportion of women who staeyd in maternity waiting home in the health facility after delivery

recode SMmaternity_stay_units (-88 -99 = .)
tabout  SMfacility_stay_units [aw=SMFUweight] if  SMmaternity_home_yn==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 3. The percentage of women who staeyd in maternity waiting home in the health facility after delivery) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(PNC) location(18 1)

*Table 4.The Proportion of women who reported receipt of health checks from HEW or other professional health care provider either for themselves or for their babies
recode SMmother_baby_check_yn (-88=0)

tabout  SMmother_baby_check_yn [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 4.The Proportion of women who reported receipt of health checks either for themselves or for their babies) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(PNC) location(26 1)

* Table 5. The percentage of women who were counselled about infant nutrition at any health check after delivery 

local row = 34 
foreach var in SMhc_breastfeeding SMhc_liquids_before_6m SMhc_foods_after_6m SMhc_dietary_diversity SMhc_animal_source_foods SMhc_feeding_frequency SMhc_no_sugary_drinks {
local varlab : var label `var'
tabout `var' [aw=SMFUweight] if SMpnc_hew_visit_2m==1| SMpnc_seek_hew_2m==1 | SMpnc_seek_phcp_2m==1| SMmother_baby_check_yn==1 | SMcaregiver_baby_check_yn==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 5x: PNC nutrition counseling : `varlab') f(0 1) clab(n col_%) nwt(SMFUweight) sheet(PNC) location(`row' 1)
local row=`row'+8
}


* Table 6. History on antropometry measurement : Weight 
recode SMmeasure_weight (-88 =0)
tabout SMmeasure_weight [aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 6: Percentage of women whose baby's weight was measured by any health care provider at any health check since delivery) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(PNC) location(98 1)

* Table 7. History on antropometry measurement : Height
recode SMmeasure_height (-88 -99 =.) 
tabout SMmeasure_height [aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 7: Percentage of women whose baby's height was measured by any health care provider at any health check since delivery) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(PNC) location(106 1)

* Table 8. History on antropometry measurement : upper arm circumference  

recode SMmeasure_muac (-88 -99 =.) 
tabout SMmeasure_muac [aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 8: Percentage of women whose baby's  upper arm circumference was measured by any health care provider at any health check since delivery) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(PNC) location(114 1)

*table 9. Percentage of women who ever breastfed their babies since birth

tabout SMever_bf [aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(table 9. Percentage of women who ever breastfed their babies since birth) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(PNC) location(122 1)


*Table 10. Percentage of women who experienced difficulties in breastfeeding

recode SMbf_difficulty_yn( -99 -88 = .)

tabout SMbf_difficulty_yn [aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(table 10.  Percentage of women who experienced difficulties in breastfeeding) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(PNC) location(130 1)
 * Table 11. types of difficulties experienced while breastfeeding

local row = 138 
foreach var in SMbf_difficulty_crackednipples SMbf_difficulty_lowmilk SMbf_difficulty_engorgement SMbf_difficulty_mastitis SMbf_difficulty_latch SMbf_difficulty_other {
local varlab : var label `var'
tabout `var' [aw=SMFUweight] if SMbf_difficulty_yn==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 11x: difficulties experienced : `varlab') f(0 1) clab(n col_%) nwt(SMFUweight) sheet(PNC) location(`row' 1)
local row=`row'+8
}
 * Table 12. Percentage of women who sought help for difficulties encounterd in breastfeeding
   
tabout SMbf_difficulty_trt [aw=SMFUweight] if SMbf_difficulty_yn==1  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 12. Percentage of women who sought help for difficulties encounterd in breastfeeding) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(PNC) location(194 1)


* table 13. the type of professional the women sought help 


local row = 204 
foreach var in SMbf_difficulty_trt_doctor SMbf_difficulty_trt_ho SMbf_difficulty_trt_nurse SMbf_difficulty_trt_otherskilled SMbf_difficulty_trt_hew SMbf_difficulty_trt_had SMbf_difficulty_trt_tradbirth SMbf_difficulty_trt_tradheal SMbf_difficulty_trt_family SMbf_difficulty_trt_other {
local varlab : var label `var'
tabout `var' [aw=SMFUweight] if SMbf_difficulty_trt==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 13x: sought help from : `varlab') f(0 1) clab(n col_%) nwt(SMFUweight) sheet(PNC) location(`row' 1)
local row=`row'+8
}


*Table 14: Percenage of women who receive any family planning information, referrals or services, not including immunization visits at any health checks in the past 6 months for themselves or their babies
tabout SMfp_info_non_vaccine_visit [aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 14: Percenage of women who receive any family planning information, referrals or services, not including immunization visits) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(PNC) location(283 1)

*Table 15: Percenage of women who receive any family planning information, referrals or services during any of immunization visits for their babies
tabout SMfp_info_vaccine_visit [aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 15: Percenage of women who receive any family planning information, referrals or services during any of immunization visits for their babies) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(PNC) location(291 1)

restore
*******************************************************************************
* Nutrition indicators
******************************************************************************* 
* Reshape the data to account for the twin births
  * First reshape the data
preserve
keep if SMresult==1

unab kid_var : SMgender1-SMnocard_vit_a_yn1
local stubs: subinstr local kid_var "1" "", all
local stubs: subinstr local stubs "SMpolio_" "SMpolio1_", all
local stubs: subinstr local stubs "SMpentavalent_" "SMpentavalent1_", all
local stubs: subinstr local stubs "SMpcv_" "SMpcv1_", all
local stubs: subinstr local stubs "SMrota_" "SMrota1_", all
local stubs: subinstr local stubs "SMmeasles_" "SMmeasles1_", all
gen mother_ID=SMmetainstanceID

reshape long `stubs', i(mother_ID) j(index)


* Table1. Exclusive breastfeeding
 
gen exclusive_breastfeeding_baby =0 
replace exclusive_breastfeeding_baby=1 if SMyl_breast_milk==1 & SMyl_water==0 & SMyl_unsweetjuice==0 & SMyl_sugar_juice==0 & SMyl_honey_juice==0 & SMyl_broth==0 & SMyl_honey_tea==0 & SMyl_sugar_tea==0 & SMyl_unsweettea==0 & SMyl_unsweetgruel==0 & SMyl_sugar_gruel==0 & SMyl_honey_gruel==0 & SMyl_sweetother==0 &SMyl_unsweetother==0 & SMyl_unsweetfenugreek==0 & SMyl_sugar_fenugreek==0 & SMyl_honey_fenugreek==0 & SMyl_porridge==0 & SMyl_formula==0 & SMyl_yogurt==0 & SMyl_milk==0 &SMfy_fort==0 & SMfy_grain==0 & SMfy_bean==0 & SMfy_dairy==0 &  SMfy_ylw_veg==0 & SMfy_wht_veg==0 & SMfy_grn_veg==0 & SMfy_ripe_frt==0 & SMfy_oth_frt_veg==0 & SMfy_org==0 & SMfy_meat==0 & SMfy_egg==0 &  SMfy_fish==0 & SMfy_other==0

label define exclu_breastfeeding_baby_list 1 "exclusive breastfeeding : yes" 0 "exclusive breastfeeding : no" 

label val exclusive_breastfeeding_baby exclu_breastfeeding_baby_list
label var exclusive_breastfeeding_baby "exclusive breastfeeding for all alive infants"

tabout exclusive_breastfeeding_baby [aw=SMFUweight] if SMstill_alive==1  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 1. The proportion of infants who were excludively breastfed at approximaltey six months of age") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Nutrition) location(1 1)


*Table 2. partially breastfed 

gen partial_breastfeeding_baby =0 
replace partial_breastfeeding_baby=1 if (SMyl_breast_milk==1) & (SMyl_water==1 | SMyl_unsweetjuice==1 | SMyl_sugar_juice==1 | SMyl_honey_juice==1 | SMyl_broth==1 | SMyl_honey_tea==1 | SMyl_sugar_tea==1 | SMyl_unsweettea==1 | SMyl_unsweetgruel==1 | SMyl_sugar_gruel==1 | SMyl_honey_gruel==1 | SMyl_sweetother==1 | SMyl_unsweetother==1) & ((SMyl_porridge==0 & SMfy_fort==0 & SMfy_grain==0 & SMfy_bean==0 & SMfy_dairy==0 & SMfy_ylw_veg==0 & SMfy_wht_veg==0 & SMfy_grn_veg==0 & SMfy_ripe_frt==0 & SMfy_oth_frt_veg==0 & SMfy_org==0 & SMfy_meat==0 & SMfy_egg==0 &  SMfy_fish==0 & SMfy_other==0) | (SMyl_milk==0 & SMyl_formula==0 & SMyl_yogurt==0 & SMyl_unsweetfenugreek==0 & SMyl_sugar_fenugreek==0 & SMyl_honey_fenugreek==0))



label define partial_breastfeeding_baby_list 1"partial breastfeeding : yes" 0"partial breastfeeding : no" 

label val partial_breastfeeding_baby partial_breastfeeding_baby_list
label var partial_breastfeeding_baby "partial breastfeeding for all alive infants"

tabout partial_breastfeeding_baby [aw=SMFUweight] if SMstill_alive==1  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 2. The proportion of infants who were partially breastfed at approximaltey six months of age") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Nutrition) location(10 1)

*Table 3. predominantly breastfed 

gen predominantly_breastfed_baby =0 
replace predominantly_breastfed_baby=1 if (SMyl_breast_milk==1) & (SMyl_water==1 | SMyl_unsweetjuice==1 | SMyl_sugar_juice==1 | SMyl_honey_juice==1 | SMyl_broth==1 | SMyl_honey_tea==1 | SMyl_sugar_tea==1 | SMyl_unsweettea==1 | SMyl_unsweetgruel==1 | SMyl_sugar_gruel==1 | SMyl_honey_gruel==1 | SMyl_sweetother==1 | SMyl_unsweetother==1) & (SMyl_milk==1 | SMyl_formula==1 | SMyl_yogurt==1  | SMyl_unsweetfenugreek==1 | SMyl_sugar_fenugreek==1 & SMyl_honey_fenugreek==1) & (SMyl_porridge==0 & SMfy_fort==0 & SMfy_grain==0 & SMfy_bean==0 & SMfy_dairy==0 & SMfy_ylw_veg==0 & SMfy_wht_veg==0 & SMfy_grn_veg==0 & SMfy_ripe_frt==0 & SMfy_oth_frt_veg==0 & SMfy_org==0 & SMfy_meat==0 & SMfy_egg==0 &  SMfy_fish==0 & SMfy_other==0) 

label define predom_breastfed_baby_list 1"predominantly breastfeeding : yes" 0"predominantly breastfeeding : no" 

label val predominantly_breastfed_baby predom_breastfed_baby_list
label var predominantly_breastfed_baby "predominantly breastfed for all alive infants"

tabout predominantly_breastfed_baby [aw=SMFUweight]  if SMstill_alive==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 3. The proportion of infants who were predominantly breastfed at approximaltey six months of age") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Nutrition) location(20 1)


*Table 4. Not breastfed
recode SMyl_breast_milk(-88=0)
tabout SMyl_breast_milk [aw=SMFUweight] if SMstill_alive==1  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 4. The proportion of infants who were not breastfed at approximaltey six months of age") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Nutrition) location(30 1)

 
*Table 5. The proportion of  infants who are approximaltey 6 months of age who received grain, roots and tuber food groups during the previous day

gen SMgrain_roots_tuber =0 if SMstill_alive==1 & SMresult==1
replace SMgrain_roots_tuber=1 if SMfy_wht_veg==1 | SMyl_unsweetgruel==1| SMyl_unsweetfenugreek==1| SMyl_porridge==1 |SMyl_sugar_gruel==1 | SMyl_honey_gruel==1 | SMyl_sugar_fenugreek==1 | SMyl_honey_fenugreek==1 | SMfy_grain==1 | SMfy_fort==1 
label define SMgrain_roots_tuber_list 1 "comsumed Grain, roots and tuber food group:yes" 0 " comsumed Grain, roots and tuber food group:no" 

label val SMgrain_roots_tuber SMgrain_roots_tuber_list
label var SMgrain_roots_tuber "infants who consumed Grain, roots and tuber food group"

tabout SMgrain_roots_tuber [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 5. The proportion of  infants who are approximaltey 6 months of age who received grain, roots and tuber food groups during the previous day") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Nutrition) location(40 1)

* Table 6. The proportion of  infants who are approximaltey 6 months of age who received Legumes and nut food group during the previous day

gen SMlegumes_nut =0 if SMstill_alive==1  & SMresult==1
replace SMlegumes_nut=1 if SMfy_bean==1 
label define SMlegumes_nut_list 1 " consumed Legumes and nut food group:yes" 0 " consumed Legumes and nut food group:no"

label val SMlegumes_nut SMlegumes_nut_list
label var SMlegumes_nut "infants who consumed legumes and nut food group"

tabout SMlegumes_nut [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 6. The proportion of  infants who are approximaltey 6 months of age who received Legumes and nut food groups during the previous day") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Nutrition) location(50 1)


* Table 7. The proportion of  infants who are approximaltey 6 months of age who received Dairy products food group during the previous day 

gen SMdiary =0 if SMstill_alive==1 & SMresult==1
replace SMdiary=1 if SMyl_milk==1| SMyl_formula==1 | SMyl_yogurt==1| SMfy_dairy==1 | SMfy_fort==1
label define SMdiary_list 1 " consumed diary food group:yes" 0 " consumed diary food group:no"
label val SMdiary SMdiary_list 
label var SMdiary "infants who consumed diary food group"

tabout SMdiary [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 7. The proportion of  infants who are approximaltey 6 months of age who received Dairy products during the previous day") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Nutrition) location(60 1)

* Table 8. The proportion of  infants who are approximaltey 6 months of age who received Flesh foods food group during the previous day 

gen SMflesh_food =0 if SMstill_alive==1 & SMresult==1
replace SMflesh_food=1 if SMfy_fish==1 | SMfy_org==1 | SMfy_meat==1 

label define SMflesh_food_list 1 " consumed flesh food group:yes" 0 " consumed flesh food group:no"
label val SMflesh_food SMflesh_food_list 
label var SMflesh_food "infants who consumed flesh food group"

tabout SMflesh_food [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("table 8. The proportion of  infants who are approximaltey 6 months of age who received Dairy products during the previous day") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Nutrition) location(70 1)

* Table 9. The proportion of  infants who are approximaltey 6 months of age who received eggs during the previous day 

gen SMeggs =0 if SMstill_alive==1  & SMresult==1
replace SMeggs=1 if SMfy_egg==1 
label define SMeggs_list 1 " consumed eggs :yes" 0 "consumed eggs :no"
label val SMeggs SMeggs_list 
label var SMeggs "infants who consumed eggs"

tabout SMeggs [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("table 9. The proportion of  infants who are approximaltey 6 months of age who received eggs during the previous day") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Nutrition) location(80 1)

* Table 9. The proportion of  infants who are approximaltey 6 months of age who received Vitamin-A rich fruits during the previous day 

gen SMvitaminA_rich_fruits =0 if SMstill_alive==1  & SMresult==1
replace SMvitaminA_rich_fruits=1 if SMfy_ylw_veg==1 | SMfy_grn_veg==1 | SMfy_ripe_frt==1 

label define SMvitaminA_rich_fruits_list 1 " consumed vitamin-A rich fruits :yes" 0 "consumed vitamin-A rich fruits:no"
label val SMvitaminA_rich_fruits SMvitaminA_rich_fruits_list 
label var SMvitaminA_rich_fruits "infants who consumed vitamin-A rich fruits"

tabout SMvitaminA_rich_fruits [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 10. The proportion of  infants who are approximaltey 6 months of age who received vitaminA_rich_fruits during the previous day") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Nutrition) location(90 1)

* Table 10. The proportion of  infants who are approximaltey 6 months of age who received other fruits or vegetables during the previous day 

gen SMother_fru_veg =0 if SMstill_alive==1 & SMresult==1
replace SMother_fru_veg=1 if SMfy_oth_frt_veg==1 
label define SMother_fru_veg_list 1 " consumed other fruits or vegetables :yes" 0 "consumed other fruits or vegetables :no"
label val SMother_fru_veg SMother_fru_veg_list 
label var SMother_fru_veg "infants who consumed other fruits or vegetables"

tabout SMother_fru_veg [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 10. The proportion of  infants who are approximaltey 6 months of age who received other fruits or vegetables during the previous day") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Nutrition) location(100 1)

* Table 11. Minimum Dietary Diversity (MDD); The proportion of  Children 6–12 months of age who received foods from ≥ 4 food groups during the previous day


egen SMfood_group_consumed_no = rowtotal( SMgrain_roots_tuber SMlegumes_nut SMdiary SMflesh_food SMeggs SMvitaminA_rich_fruits SMother_fru_veg) if 	SMstill_alive==1  & SMresult==1

gen SM_mdd = 0 if SMstill_alive==1  & SMresult==1
replace SM_mdd=1 if SMfood_group_consumed_no >=4
label define SM_mdd_list 1 "received morethan 4 food groups: yes " 0 "received morethan 4 food groups: no " 
label val SM_mdd SM_mdd_list
label var SM_mdd "infants who received more than 4 food groups"

tabout SM_mdd [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 11. The proportion of  infants who are approximaltey 6 months of age who received received morethan 4 food groups during the previous day") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Nutrition) location(110 1)

* Table 12. the proportion of infnats whose complementary feeding initiated timely

gen SMtimely_complemnet_feeding = 0 if SMstill_alive==1 & SMresult==1
replace SMtimely_complemnet_feeding=1 if SMage_begin_food==6 
label define SMtimely_complemnet_feeding_list 1"timely initiated comp.feeding:yes" 0 "timely initiated comp.feeding:no"
label val SMtimely_complemnet_feeding SMtimely_complemnet_feeding_list
label var SMtimely_complemnet_feeding " infants who started complementary feeding at 6 months of age"

tabout SMtimely_complemnet_feeding [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 12. the proportion of infnats who whose complementary feeding initiated timely") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Nutrition) location(120 1)

restore 
*******************************************************************************
* Delivery
******************************************************************************* 
*Table 1: Birth outcome pregnancy type
preserve
keep if SMresult==1 |SMresult==2

tabout SMpregnancy_type[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 1: Birth outcome pregnancy type) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(1 1)

* Data reshape 
unab kid_var : SMgender1-SMtraditional_meds2
local stubs: subinstr local kid_var "1" "", all
local stubs: subinstr local stubs "SMpolio_" "SMpolio1_", all
local stubs: subinstr local stubs "SMpentavalent_" "SMpentavalent1_", all
local stubs: subinstr local stubs "SMpcv_" "SMpcv1_", all
local stubs: subinstr local stubs "SMrota_" "SMrota1_", all
local stubs: subinstr local stubs "SMmeasles_" "SMmeasles1_", all
gen mother_ID=SMmetainstanceID

reshape long `stubs', i(mother_ID) j(index)

*Table 2:Birth outcome gender
tabout SMgender[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 2: Birth outcome gender) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(8 1)

*Table 3: The proportion of live births
tabout SMstill_alive[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 3: The proportion of live births) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(16 1)

*Table 4: The proporton of births registered in the CRVS system
tabout SMbirth_registered[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 4: The proporton of births registered in the CRVS system) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(24 1)
*Table 5: Exactly how old  the child when (he/she) died?
tabout SMage_at_death_units[aw=SMFUweight] if  SMstill_alive==0 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 5: Exactly how old  the child when (he/she) died?) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(32 1)

*Table 6: The proportion of babies who died at home
recode SMwhere_died (11 12 36 48 =0) (2=1), gen(died_home)
label define died_homelist 1 "Died at home" 0 "Other place"
label val died_home died_homelist

tabout died_home[aw=SMFUweight] if SMstill_alive==0 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 6: The proportion of babies who died at home) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(40 1)

*Table 7: The proprotion of babies' death registered in the CRVS system
tabout SMdeath_registered[aw=SMFUweight] if SMstill_alive==0  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 7: The proprotion of babies' death registered in the CRVS system) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(48 1)

*Table 8: The proportion of deceased babies who suffered from any injury or accident
tabout SMaccident_yn[aw=SMFUweight] if SMstill_alive==0  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 8: The proportion of deceased babies who suffered from any injury or accident) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(56 1)

/*
*Table 9: The types of injury which led to the death of the baby 
    * No case
tabout SMaccident_type[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 9: The types of injury which led to the death of the baby) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(64 1)
*/

*Table 9: The proportion of babies who suffered from the listed symptioms before death 

/*local i=64
foreach var in  SMsymptoms_poorfeed SMsymptoms_eyeinfect SMsymptoms_skinles SMsymptoms_convusle SMsymptoms_lethargy SMsymptoms_unconsc SMsymptoms_fever SMsymptoms_cough SMsymptoms_sorethrt SMsymptoms_fastbreath SMsymptoms_difbreath SMsymptoms_diarrhea SMsymptoms_vomit SMsymptoms_nostool SMsymptoms_swelling SMsymptoms_other {
	local `var' : variable label `var'
	tabout `var' [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table X: `"`: var label `var''"') f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(`i' 1)
local i=`i'+7
	}	
*/
tabout SMsymptoms_poorfeed[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 9a: The proportion of babies who suffered from Difficulties feeding/unable to suck  symptioms before death) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(64 1)

tabout SMsymptoms_skinles[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 9b: The proportion of babies who suffered from Skin rash/skin lesion  symptioms before death) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(72 1)

tabout SMsymptoms_convusle[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 9c: The proportion of babies who suffered from Convulsion  symptioms before death) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(80 1)

tabout SMsymptoms_lethargy[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 9d: The proportion of babies who suffered from lethargy symptioms before death) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(88 1)

tabout SMsymptoms_unconsc[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 9e: The proportion of babies who suffered from Unconscious symptioms before death) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(96 1)

tabout SMsymptoms_fever[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 9f: The proportion of babies who suffered from fever symptioms before death) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(104 1)

tabout SMsymptoms_cough[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 9g: The proportion of babies who suffered from cough symptioms before death) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(112 1)

tabout SMsymptoms_sorethrt[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 9h: The proportion of babies who suffered from Sore throat/Tonsillitis  symptioms before death) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(120 1)

tabout SMsymptoms_fastbreath[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 9i: The proportion of babies who suffered from Fast breathing  symptioms before death) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(128 1)

tabout SMsymptoms_difbreath[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 9j: The proportion of babies who suffered from Difficulty in breathing  symptioms before death) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(136 1)

tabout SMsymptoms_diarrhea[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 9k: The proportion of babies who suffered from Diarrhea symptioms before death) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(144 1)

tabout SMsymptoms_diarrhea[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 9l: The proportion of babies who suffered from vomiting symptioms before death) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(152 1)

tabout SMsymptoms_nostool[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 9m: The proportion of babies who suffered from Constipation symptioms before death) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(160 1)

tabout SMsymptoms_swelling[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 9n: The proportion of babies who suffered from Abdominal/body swelling symptioms before death) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(168 1)

tabout SMsymptoms_other[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 9o: The proportion of babies who suffered from other symptioms before death) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(176 1)

*Table 10: The proportion women who perceived the listed symptoms as a cause for the death of her baby

* No cases for: SMcause_of_death_tetanus SMcause_of_death_malaria SMcause_of_death_measles SMcause_of_death_malnut SMcause_of_death_meningitis SMcause_of_death_hep SMcause_of_death_typhus SMcause_of_death_tb SMcause_of_death_aids SMcause_of_death_coronavirus

/*
local i=176
foreach var in  SMcause_of_death_premie SMcause_of_death_delivery SMcause_of_death_sids  SMcause_of_death_pneumonia  SMcause_of_death_cough SMcause_of_death_gi  SMcause_of_death_negligence SMcause_of_death_evileye  SMcause_of_death_other  {
	local `var' : variable label `var'
	tabout `var' [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table X: `"`: var label `var''"') f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(`i' 1)
local i=`i'+7
	}	
*/

tabout SMcause_of_death_premie[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 10a: The proportion women who perceived Premature birth as a cause for the death of her baby) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(184 1)
	
tabout SMcause_of_death_delivery [aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 10b: The proportion women who perceived  Pregnancy/delivery related as a cause for the death of her baby) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(191 1)

tabout SMcause_of_death_sids [aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 10c: The proportion women who perceived  Sudden death  as a cause for the death of her baby) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(198 1)

tabout SMcause_of_death_pneumonia [aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 10d: The proportion women who perceived  Pneumonia as a cause for the death of her baby) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(205 1)

tabout SMcause_of_death_cough [aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 10e: The proportion women who perceived  Whooping cough as a cause for the death of her baby) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(212 1)

tabout SMcause_of_death_gi[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 10f: The proportion women who perceived  Diarrhea as a cause for the death of her baby) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(219 1)

tabout SMcause_of_death_negligence[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 10g: The proportion women who perceived  Provider negligence as a cause for the death of her baby) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(226 1)

tabout SMcause_of_death_evileye[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 10h: The proportion women who perceived  Evil eye/witchcraft as a cause for the death of her baby) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(233 1)

tabout SMcause_of_death_other[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 10h: The proportion women who perceived  other as a cause for the death of her baby) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Delivery) location(240 1)
         
restore
*********************************************
*   Vaccination                        *
*********************************************
preserve
keep if SMresult==1 | SMresult==1
*Reshape the child variable to account for twins
*still_alive1
unab kid_var : SMstill_alive1-SMnocard_vit_a_yn1
local stubs: subinstr local kid_var "1" "", all
local stubs: subinstr local stubs "SMpolio_" "SMpolio1_", all
local stubs: subinstr local stubs "SMpentavalent_" "SMpentavalent1_", all
local stubs: subinstr local stubs "SMpcv_" "SMpcv1_", all
local stubs: subinstr local stubs "SMrota_" "SMrota1_", all
local stubs: subinstr local stubs "SMmeasles_" "SMmeasles1_", all

gen mother_ID=SMmetainstanceID

reshape long `stubs', i(mother_ID) j(index)

*Restrict the analysis for live births ONLY
keep if SMstill_alive==1 

* Table 1: Vital Registration
recode SMbirth_registered (-88=0)
tabout SMbirth_registered[aw=SMFUweight] if SMstill_alive==1   using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 1: Vital Registration) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Vaccination) location(1 1)

*Table 2: Vaccinated Infants
* Proportion of alive infants who got some vaccines at age of 12 month, according to care takers claim.
tabout SMvaccines_yn[aw=SMFUweight] if SMstill_alive==1   using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 2: Vaccinated Infants) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Vaccination) location(8 1)


* Table 3. Ownership of official vaccination card: Proportion of alive infants who have official vaccination cards at age of  6 month
 recode SMmoh_vaccine_card (2=1), gen(Vaccine_card)
label var Vaccine_card " Ownership of official vaccination card"
label define Vaccine_card_list 1 " Yes " 0 " No"
label val Vaccine_card Vaccine_card_list
tabout Vaccine_card [aw=SMFUweight] if SMstill_alive==1  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 3: Ownership of official vaccination card) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Vaccination) location(15 1)

* table 4. Verified vaccination card by RE
 recode SMmoh_vaccine_card (2=0), gen(Vaccine_cardRE)
 label var Vaccine_cardRE " Verified ownership of official vaccination card"
label define Vaccine_cardRE_list 1 " Yes " 0 " No"
label val Vaccine_cardRE Vaccine_cardRE_list

tabout Vaccine_cardRE [aw=SMFUweight] if SMstill_alive==1  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 4: Verified ownership of official vaccination card) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Vaccination) location(22 1)

*Table 5: Verified ownership of official vaccination card (out of alleged card owners)

tabout Vaccine_cardRE [aw=SMFUweight] if SMmoh_vaccine_card ==1|SMmoh_vaccine_card==2  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 5: Verified ownership of official vaccination card (out of alleged card owners)) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Vaccination) location(30 1)


*table 6 Ownership of non-official vaccination card at 6 months
recode SMunofficial_vaccine_card (2=1) (. -99=0), gen(non_official)
label var non_official "Non-official vaccination card"
label define non_official_list 1 " Yes " 0 " No"
label val non_official non_official_list
tabout non_official [aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 6: Ownership of non-official vaccination card at 6 months) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Vaccination) location(38 1)


*Table 7.Verified other vaccination card owning infants 
recode SMunofficial_vaccine_card (2 . -99 =0), gen(unofficial_vaccine_cardRE)
label var unofficial_vaccine_cardRE "Verified ownership of non-official vaccination card"
label define unofficial_vaccine_cardRE_list 1 " Yes " 0 " No"
label val unofficial_vaccine_cardRE unofficial_vaccine_cardRE_list
tabout unofficial_vaccine_cardRE [aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 7: Verified ownership of other non-official vaccination card at 6 months) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Vaccination) location(45 1)


*table 8 Verified ownership of other non official vaccination card (out of non official card owners)
tabout unofficial_vaccine_cardRE [aw=SMFUweight] if SMunofficial_vaccine_card==1|SMunofficial_vaccine_card==2  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 8: Verified ownership of other non official vaccination card (out of non official card owners)) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Vaccination) location(53 1)


*table 9. Any vaccination card owning infants 
gen Any_card=0
replace Any_card=1 if SMunofficial_vaccine_card==1|SMunofficial_vaccine_card==2|SMmoh_vaccine_card==1|SMmoh_vaccine_card==2
label var Any_card "Any vaccination card owning infants"
label define Any_card_list 1 " Have card " 0 " No card"
label val Any_card Any_card_list
tabout Any_card [aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 9: Ownership of any vaccination card (official or non-official) at 6 months) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Vaccination) location(61 1)

*table 10. Any verfied vaccination card owning infants 
gen any_card_RE=0
replace any_card_RE=1 if SMunofficial_vaccine_card==1|SMmoh_vaccine_card==1
label var any_card_RE "Any  verfied vaccination card owning infants"
label define any_card_RE_list 1 " Have verfied card " 0 " No verfied card"
label val any_card_RE any_card_RE_list
tabout any_card_RE[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 10: Verified ownership of any vaccination card at 6 months) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Vaccination) location(68 1)


*table 11. BCG Vaccination coverage (by card)
recode SMbcg_card (. -99 =0) 
recode SMbcg_card (-88 =1) 
tabout  SMbcg_card [aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 11: BCG Vaccination coverage (by card)) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Vaccination) location(75 1)

*12. BCG Vaccination coverage (by history)
recode SMnocard_bcg_yn (. -88 -99 =0) 
tabout SMnocard_bcg_yn[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 12: BCG Vaccination coverage (by history)) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Vaccination) location(82 1)

*13. BCG Vaccination coverage (by card or by history)
gen BCG_both=0
replace BCG_both=1 if SMbcg_card==1|SMbcg_card==-88|SMnocard_bcg_yn==1
label var BCG_both " Vaccinated BCG either from card or by history"
label define BCG_both_list 1 " Yes " 0 " No"
label val BCG_both BCG_both_list
tabout BCG_both[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 13: BCG Vaccination coverage (by card or by history)) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Vaccination) location(89 1)

*14. Penta 1 Vaccination coverage (by card)
recode SMpentavalent1_card (. -99 =0)
recode SMpentavalent1_card (-88 =1) 
tabout SMpentavalent1_card[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 14: Penta 1 Vaccination coverage (by card)) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Vaccination) location(96 1)

*15. Penta 1 Vaccination coverage (by history)
recode SMnocard_pentavalent_yn (. -99 -88 =0)
gen penta1_hist=0
replace penta1_hist=1 if SMnocard_pentavalent_yn==1 & SMnocard_pentavalent_count==1
label var penta1_hist " Penta 1 Vaccination by history"
label define penta1_hist_list 1 " Yes " 0 " No"
label val penta1_hist penta1_hist_list
tabout penta1_hist[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 15: Penta 1 Vaccination coverage (by history)) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Vaccination) location(104 1)

*16. Penta 1 Vaccination coverage (by card or by history)
gen Penta1_both=0
replace Penta1_both=1 if (SMpentavalent1_card==1|SMpentavalent1_card==-88)|(SMnocard_pentavalent_yn==1&SMnocard_pentavalent_count==1)
label var Penta1_both" Vaccinated pentavalent either by card or by history"
label define Penta1_both_list 1 " Yes " 0 " No"
label val Penta1_both Penta1_both_list
tabout Penta1_both[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 16: Penta 1 Vaccination coverage (by card or by history)) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Vaccination) location(112 1)

*17. Penta 3 Vaccination coverage (by card)
recode SMpentavalent3_card (. -99 =0)
recode SMpentavalent3_card (. -88 =0)
tabout SMpentavalent3_card [aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 17: Penta 3 Vaccination coverage (by card)) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Vaccination) location(120 1)

*18. Penta 3 Vaccination coverage (by history)
recode SMnocard_pentavalent_yn (. -99 -88 =0)
gen penta3_hist=0
replace penta3_hist=1 if SMnocard_pentavalent_yn==1 & SMnocard_pentavalent_count>=3
label var penta3_hist " Penta 3 Vaccination by history"
label define penta3_hist_list 1 " Yes " 0 " No"
label val penta3_hist penta3_hist_list
tabout penta3_hist[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 18: Penta 3 vaccination coverage (by history)) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Vaccination) location(128 1)

*19. Penta 3 Vaccination coverage (by card or by history)
gen Penta3_both=0
replace Penta3_both=1 if (SMpentavalent3_card==1|SMpentavalent3_card==-88)|(SMnocard_pentavalent_yn==1&SMnocard_pentavalent_count>=3)
label var Penta3_both" Vaccinated pentavalent either by card or by history"
label define Penta3_both_list 1 " Yes " 0 " No"
label val Penta3_both Penta3_both_list
tabout Penta3_both[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 19: Penta 3 vaccination coverage (by card or by history)) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Vaccination) location(136 1)

*20. Vitamin a supplement coverage (by history)
recode SMnocard_vit_a_yn (-88 =0)

tabout SMnocard_vit_a_yn[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 20: Vatamin A supplement coverage (by history)) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Vaccination) location(144 1)

*21. Vitamin a supplement coverage (by card or by history)
gen Vit_a_both=0
replace Vit_a_both=1 if SMnocard_vit_a_yn==1|SMvit_a_card==1
label var Vit_a_both" vitamin-A supplement either by card or by history"
label define Vit_a_both_list 1 " Yes " 0 " No"
label val Vit_a_both Vit_a_both_list
tabout Vit_a_both[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 21: Vitamin-A supplementcoverage (by card or by history)) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Vaccination) location(152 1)


*22. Unvaccinated children at 6 month: Percentage of children approximately 6 months old who received no vaccinations
/*
gen Unvaccinated=0
replace Unvaccinated=1 if (SMbcg_card==0|SMbcg_card==-99) & (SMpolio1_card==0|SMpolio1_card==-99)& (SMpentavalent1_card==0|SMpentavalent1_card==-99)& (SMpcv1_card==0|SMpcv1_card==-99) & (SMrota1_card==0|SMrota1_card==-99) & (SMpolio2_card==0|SMpolio2_card==-99) & (SMpentavalent2_card==0|SMpentavalent2_card==-99) & (SMpcv2_card==0|SMpcv2_card==-99) & (SMrota2_card==0|SMrota2_card==-99) & (SMpolio3_card==0|SMpolio3_card==-99)& (SMpentavalent3_card==0|SMpentavalent3_card==-99)& (SMpcv3_card==0|SMpcv3_card==-99)
label var Unvaccinated "Infants who got none of the 12 vaccinations"
label define Unvaccinated_list 1 "Unvaccinated " 0 " No"
label val Unvaccinated Unvaccinated_list
tabout Unvaccinated[aw=SMFUweight]  using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title(Table 22: Percentage of children approximately 12 months old who received no vaccinations)) f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Vaccination) location(160 1) */

restore
******************************************************************************
* Infant indicators
******************************************************************************* 

 *reshaping the data to account for twins
 
 preserve
keep if SMresult==1|SMresult==2 

unab kid_var : SMgender1-SMfever_trt_other1
local stubs: subinstr local kid_var "1" "", all
local stubs: subinstr local stubs "SMpolio_" "SMpolio1_", all
local stubs: subinstr local stubs "SMpentavalent_" "SMpentavalent1_", all
local stubs: subinstr local stubs "SMpcv_" "SMpcv1_", all
local stubs: subinstr local stubs "SMrota_" "SMrota1_", all
local stubs: subinstr local stubs "SMmeasles_" "SMmeasles1_", all
gen mother_ID=SMmetainstanceID

reshape long `stubs', i(mother_ID) j(index)


* Table 1.  The Proportion of infants who suffer from fever in the last two weeks 

tabout SMill_fever [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 1. The Proportion of infants who suffer from fever in the last two weeks ") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Infant) location(1 1)

* Table 2. The Proportion of women who sought treatment or visited by Health worker at home for child's fever
tabout SMfever_trt_yn [aw=SMFUweight] if SMill_fever==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 2. The Proportion of women who sought treatment or visited by Health worker at home for the fever ") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Infant) location(10 1)

* Table 3. The Proportion of infants who suffer from cough or cold in the last two weeks 
tabout SMill_cough [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 3. he Proportion of infants who had cought or cold in the last two weeks as reported by caretaker ") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Infant) location(20 1)

* Table 4. The Proportion of women who sought treatment or visited by Health worker at home for her child's the cought or cold
tabout SMcough_trt_yn [aw=SMFUweight] if SMill_cough==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 2. The Proportion of women who sought treatment or visited by Health worker at home for cough or cold ") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Infant) location(30 1) 


* Table 5. The Proportion of infants who suffer from fast breathing or Difficulty breathing 
 gen SMfast_or_diffbreath = 0 if SMstill_alive==1
 replace SMfast_or_diffbreath=1 if SMill_fastbrth==1 | SMill_difbreath==1
 label define SMfast_or_diffbreath_list 1"yes" 0"no"
 label val SMfast_or_diffbreath SMfast_or_diffbreath_list
 
 label var SMfast_or_diffbreath "infant who suffer from fast breathing or difficulty in breathing"

tabout SMfast_or_diffbreath [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 3. The Proportion of infants who suffer from Fast breathing or Difficulty breathing") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Infant) location(40 1)


* Table 6. The Proportion of women who sought treatment or visited by Health worker at home for her child's fast breathing or difficulty breathing

tabout SMbreathe_trt_yn [aw=SMFUweight] if SMfast_or_diffbreath==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 2. The Proportion of women who sought treatment or visited by Health worker at home for fast breathing or difficulty breathing ") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Infant) location(50 1) 

*Table 7. Proportion of alive infants with fast breathing or difficulty in breathing who got oral or injectable medication for the breathing problem
 gen SMfast_or_diffbreath_trt = 0 if SMfast_or_diffbreath==1 
replace SMfast_or_diffbreath_trt=1 if SMbreathe_trt_oralabx==1 | SMbreathe_trt_painrelief==1| SMbreathe_trt_coughsyrup==1| SMbreathe_trt_injection==1| SMbreathe_trt_inhaledmed==1 | SMbreathe_trt_referral==1
 
label define SMfast_or_diffbreath_trt_list 1"yes" 0"no"
label val SMfast_or_diffbreath_trt Mfast_or_diffbreath_trt_list
label var SMfast_or_diffbreath_trt "nfants who got oral or injectable medication for the breathing problem"

tabout SMfast_or_diffbreath_trt [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 7. The proportion of infants who got oral or injectable medication for the breathing problem") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Infant) location(60 1)

* Table 8. The Proportion of infants who suffer from diarrhea in the last two weeks 

tabout SMill_diarrhea [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 8. The Proportion of infants who suffer from diarrhea in the last two weeks") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Infant) location(70 1)

*Table 9. The Proportion of infants who suffer from Bloody diarrhoea (Dysentry) in the last two weeks 

tabout SMdiarrhea_blood [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 9. The Proportion of infants who suffer from Bloody diarrhoea (Dysentry) in the last two weeks") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Infant) location(80 1)

* Table 10. The Proportion of women who sought treatment or visited by Health worker at home for diarrhea

tabout SMdiarrhea_trt_yn [aw=SMFUweight] if SMdiarrhea_blood==1 using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 10. The Proportion of women who sought treatment or visited by Health worker at home for her child's diarrhea") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Infant) location(90 1)

* Table 11. The Proportion of infants with diarrhoea who got ORS for the diarrhoea
  gen SMors_trt_diarrhea =0 if SMill_diarrhea==1
  replace SMors_trt_diarrhea=1 if SMdiarrhea_trt_orsathome==1 | SMdiarrhea_trt_orsinfacility==1
  label define SMors_trt_diarrhea_list 1"Infants who received ORS treatment:yes"   0"Infants who received ORS treatment:no"
  label val SMors_trt_diarrhea SMors_trt_diarrhea_list 
  label var SMors_trt_diarrhea "infants who received ORS treatment at home or at the facility"
 
 tabout SMors_trt_diarrhea [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 11. The Proportion of infants with diarrhoea who got ORS for the diarrhea") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Infant) location(100 1)

* Tabel 12. Proportion of infants who suffer from diarrhoea and received Zinc treatment 
tabout SMdiarrhea_trt_zinctabs [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("* Tabel 12. Proportion of infants who suffer from diarrhoea and received Zinc treatment") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Infant) location(110 1)

 * Table 13. The Proportion of infants who suffer from diarrhoea and received ORS and Zinc treatment
 
 gen SMzinc_ors_trt =0 if SMill_diarrhea==1
 replace SMzinc_ors_trt=1 if SMors_trt_diarrhea==1 & SMdiarrhea_trt_zinctabs==1 
 label define SMzinc_ors_trt_list   1"received zinc and ORS: yes" 0"received zinc and ORS: no"
 label val SMzinc_ors_trt SMzinc_ors_trt_list
 label var SMzinc_ors_trt "infants who suffer from diarrhea who received zinc and ORS treatment"
 
tabout SMzinc_ors_trt [aw=SMFUweight] using "`COHORT'6M_Priority_indicator_Analysis$date.xlsx", append style(xlsx) font(bold) fsize(12) c(freq col) title("Table 13. The Proportion of infants who suffer from diarrhoea and received ORS and Zinc treatment") f(0 1) clab(n col_%) nwt(SMFUweight) sheet(Infant) location(120 1)

 
 restore 