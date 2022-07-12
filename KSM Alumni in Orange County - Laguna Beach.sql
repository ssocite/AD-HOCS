With KSM_Email AS (select email.id_number,
       email.email_address,
       email.preferred_ind,
       email.forwards_to_email_address
From email
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = email.id_number
Where email.preferred_ind = 'Y'),

KSM_Spec AS (Select spec.ID_NUMBER,
spec.NO_CONTACT,
spec.NO_EMAIL_IND,
       spec.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling spec)

select market.id_number,
       market.REPORT_NAME,
       market.RECORD_STATUS_CODE,
       market.FIRST_KSM_YEAR,
       market.PROGRAM,
       market.PROGRAM_GROUP,
       market.Gender_Code,
       market.fld_of_work_code,
       market.fld_of_work,
       market.employer_name,
       market.job_title,
       market.HOUSEHOLD_CITY,
       market.HOUSEHOLD_STATE,
       market.HOUSEHOLD_ZIP,
       market.HOUSEHOLD_GEO_CODES,
       market.HOUSEHOLD_COUNTRY,
       market.HOUSEHOLD_CONTINENT,
       market.prospect_manager,
       market.lgos,
       market.managers,
       market.EVALUATION_RATING,
       market.OFFICER_RATING,
       KSM_Spec.NO_CONTACT,
       KSM_Spec.NO_EMAIL_IND
from vt_alumni_market_sheet market
left join KSM_Email on KSM_Email.id_number = market.id_number
left join KSM_Spec on KSM_Spec.id_number = market.id_number
Where market.HOUSEHOLD_GEO_CODES = 'Los Angeles; Orange County California'
and market.HOUSEHOLD_CITY = 'Laguna Beach'
and (market.GAB is null
and market.TRUSTEE is null
and market.NO_CONTACT is null
and market.NO_EMAIL_IND is null)
order by market.REPORT_NAME asc
