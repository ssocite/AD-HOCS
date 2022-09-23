With ksm_giving as
(Select Give.ID_NUMBER,
       give.NGC_LIFETIME,
       give.NU_MAX_HH_LIFETIME_GIVING
From RPT_PBH634.v_Ksm_Giving_Summary Give),

assign as (select assign.id_number,
       assign.prospect_manager,
       assign.lgos,
       assign.managers,
       assign.curr_ksm_manager
from rpt_pbh634.v_assignment_summary assign),

ksm_prospect AS (
Select TP.ID_NUMBER,
       TP.PREF_MAIL_NAME,
       TP.LAST_NAME,
       TP.FIRST_NAME,
       TP.PROSPECT_MANAGER,
       TP.EVALUATION_RATING,
       TP.OFFICER_RATING
From nu_prs_trp_prospect TP),


employ As (
  Select id_number
  , job_title
  , employment.fld_of_work_code
  , fow.short_desc As fld_of_work
  , employer_name1,
    -- If there's an employer ID filled in, use the entity name
    Case
      When employer_id_number Is Not Null And employer_id_number != ' ' Then (
        Select pref_mail_name
        From entity
        Where id_number = employer_id_number)
      -- Otherwise use the write-in field
      Else trim(employer_name1 || ' ' || employer_name2)
    End As employer_name
  From employment
  Left Join tms_fld_of_work fow
       On fow.fld_of_work_code = employment.fld_of_work_code
  Where employment.primary_emp_ind = 'Y'
),

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_EMAIL_IND,
       spec.NO_CONTACT,
       spec.GAB,
       spec.TRUSTEE,
       spec.EBFA
From rpt_pbh634.v_entity_special_handling spec)


Select
house.id_number,
house.REPORT_NAME,
house.RECORD_STATUS_CODE,
entity.institutional_suffix,
house.FIRST_KSM_YEAR,
house.PROGRAM,
house.HOUSEHOLD_CITY,
house.HOUSEHOLD_STATE,
house.HOUSEHOLD_COUNTRY,
employ.job_title,
employ.employer_name,
assign.prospect_manager,
assign.lgos,
ksm_prospect.EVALUATION_RATING,
ksm_prospect.OFFICER_RATING,
ksm_giving.NGC_LIFETIME as KSM_NGC_Lifetime,
ksm_giving.NU_MAX_HH_LIFETIME_GIVING,
KSM_Spec.NO_EMAIL_IND,
KSM_Spec.NO_CONTACT,
KSM_Spec.GAB,
KSM_Spec.TRUSTEE,
KSM_Spec.EBFA

From rpt_pbh634.v_entity_ksm_households house
Left Join ksm_prospect ON ksm_prospect.ID_NUMBER = house.id_number
Left Join ksm_giving ON ksm_giving.id_number = house.id_number
Left Join assign on assign.id_number = house.ID_number
Left Join employ on employ.id_number = house.id_number
Left Join KSM_Spec on KSM_Spec.id_number = house.id_number
Left Join entity on entity.id_number = house.id_number
Where house.PROGRAM_GROUP is not null
and house.HOUSEHOLD_COUNTRY = 'Singapore'
Order By house.REPORT_NAME ASC
