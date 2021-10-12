With KSM_Email AS (select email.id_number,
       email.email_address,
       email.preferred_ind,
       email.forwards_to_email_address
From email
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = email.id_number
Where email.preferred_ind = 'Y'),

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_EMAIL_IND,
       spec.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling spec)

--- virgin island country code = 'VIR'
select market.id_number,
       market.REPORT_NAME,
       market.RECORD_STATUS_CODE,
       market.FIRST_KSM_YEAR,
       market.PROGRAM,
       market.PROGRAM_GROUP,
       market.Gender_Code,
       market.fld_of_work,
       market.employer_name,
       market.job_title,
       market.HOUSEHOLD_CITY,
       market.HOUSEHOLD_STATE,
       market.HOUSEHOLD_COUNTRY,
       KSM_Email.email_address,
       KSM_Spec.NO_EMAIL_IND
from VT_Alumni_Market_Sheet market
left join KSM_Email ON KSM_Email.id_number = market.id_number
left join KSM_Spec ON KSM_Spec.id_number = market.id_number
where market.HOUSEHOLD_STATE = 'VI'
or market.HOUSEHOLD_STATE = 'PR'
