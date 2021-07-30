With employ As (
  Select id_number
  , job_title
  , employment.fld_of_work_code
  , fow.short_desc
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


F As (
  Select id_number
  , job_title
  , employment.fld_of_work_code
  , fow.short_desc
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
    and employment.fld_of_work_code IN ('L43','L140')
),

PE As (
  Select id_number
  , job_title
  , employment.fld_of_work_code
  , fow.short_desc
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
    and employment.fld_of_work_code = 'L140'
),

Finance AS (select Distinct interest.catracks_id,
interest.interest_desc
from rpt_pbh634.v_datamart_career_interests interest
where interest.interest_code IN ('L43')),

PEI AS (select Distinct interest.catracks_id,
interest.interest_desc
from rpt_pbh634.v_datamart_career_interests interest
where interest.interest_code IN ('LVC')),

KSM_Email AS (select email.id_number,
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
From rpt_pbh634.v_entity_special_handling spec),

assignment as (select assign.id_number,
       assign.prospect_manager,
       assign.lgos,
       assign.managers,
       assign.curr_ksm_manager
from rpt_pbh634.v_assignment_summary assign)

select distinct house.ID_NUMBER,
       house.REPORT_NAME,
       house.RECORD_STATUS_CODE,
       house.FIRST_KSM_YEAR,
       house.PROGRAM,
       house.PROGRAM_GROUP,
       house.HOUSEHOLD_CITY,
       house.HOUSEHOLD_STATE,
       employ.job_title,
       employ.employer_name,
       f.short_desc as finance_employ_industry_ind,
       PE.short_desc as VCPE_employ_industry_ind,
       finance.interest_desc as finance_interest_ind,
       PEI.interest_desc as vcpe_interest_ind,    
       assignment.prospect_manager,
       assignment.lgos,
       KSM_Email.email_address,
       KSM_Spec.NO_EMAIL_IND,
       KSM_Spec.NO_CONTACT
from rpt_pbh634.v_entity_ksm_households house
left join employ on employ.id_number = house.ID_NUMBER
left join Finance on Finance.catracks_id = house.ID_Number
left join PEI on PEI.catracks_id = house.ID_Number
left join f on f.id_number = house.ID_NUMBER
left join PE on PE.id_number = house.ID_NUMBER
left join KSM_Email on KSM_Email.id_number = house.ID_NUMBER
left join KSM_Spec on KSM_Spec.id_number = house.ID_NUMBER
left join assignment on assignment.id_number = house.ID_NUMBER
where house.HOUSEHOLD_GEO_PRIMARY_DESC like '%Austin%'
and house.RECORD_STATUS_CODE = 'A'
and house.PROGRAM_GROUP is not null
and (KSM_Spec.NO_CONTACT is null
and KSM_Spec.NO_EMAIL_IND is null)
and (f.short_desc is not null 
or finance.interest_desc is not null
or pe.short_desc is not null
or PEI.interest_desc is not null
)
order by house.REPORT_NAME ASC
