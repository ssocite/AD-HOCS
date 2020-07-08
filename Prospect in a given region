--- *** Kellogg Prospect Ad-Hoc Project ***

--- Create a subquery to get pref emails on alumni 

With email_pref As 

(select 
        email.id_number,
        email.email_address,
        email.preferred_ind
from email
where email.preferred_ind = 'Y'),

--- Create subquery to get spouse preferred email

spouse_email As (select distinct 
       house.HOUSEHOLD_SPOUSE_ID,
       email.email_address,
       email.preferred_ind
from email
inner join rpt_pbh634.v_entity_ksm_households house on house.HOUSEHOLD_SPOUSE_ID = email.id_number
where email.preferred_ind = 'Y')



--- Select Market Sheet + Household + email subquery + business subquery 

Select market.id_number,
       market.REPORT_NAME,
       market.RECORD_STATUS_CODE,
       market.job_title,
       market.employer_name,
       market.mgo_pr_score,
       market.mgo_pr_model,
       rpt_pbh634.v_ksm_model_mg.id_score,
       rpt_pbh634.v_ksm_model_mg.id_segment,
       market.FIRST_KSM_YEAR,
       market.PROGRAM,
       market.PROGRAM_GROUP,
       market.prospect_manager,
       market.Leadership_Giving_Officer,
       email_pref.email_address As preferred_email,
       mart.home_city,
       mart.home_state,
       mart.home_country_desc,
       mart.home_geo_primary_desc,
       mart.business_city,
       mart.business_state,
       mart.business_geo_primary_desc,
       house.SPOUSE_ID_NUMBER,
       house.SPOUSE_REPORT_NAME,
       house.SPOUSE_DEGREES_CONCAT,
       house.SPOUSE_FIRST_KSM_YEAR,
       house.SPOUSE_PROGRAM_GROUP,
       spouse_email.email_address AS spouse_preferred_email_address
From vt_alumni_market_sheet market
Left Join rpt_pbh634.v_entity_ksm_households house on house.ID_NUMBER = market.id_number
Left Join rpt_pbh634.v_ksm_model_mg on rpt_pbh634.v_ksm_model_mg.id_number = market.id_number
Left Join rpt_pbh634.v_datamart_address mart on mart.catracks_id = market.id_number
Left Join email_pref on email_pref.id_number = market.id_number
Left Join spouse_email on spouse_email.household_spouse_id = house.SPOUSE_ID_NUMBER

--- San Francisco Household Geo Code -- from data mart 
Where market.HOUSEHOLD_GEO_CODES Like '%Los Angeles%'
