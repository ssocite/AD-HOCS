With employ As (
    Select id_number
    , employment.employer_id_number
    , employment.job_status_code
    , employment.primary_emp_ind
    , employment.fld_of_work_code
    , job_title
    , Case
        When trim(employer_id_number) Is Not Null And employer_id_number != ' ' Then (
          Select pref_mail_name
          From entity
          Where id_number = employer_id_number)
        Else trim(employer_name1 || ' ' || employer_name2)
      End As employer_name
    , employment.stop_dt
    , employment.date_modified
    From employment
  Where employment.primary_emp_ind = 'Y'
  and employment.job_status_code = 'C'),

KSM_Spec AS (Select spec.ID_NUMBER,
         spec.NO_CONTACT,
         spec.NO_EMAIL_IND,
         spec.ACTIVE_WITH_RESTRICTIONS,
         spec.NEVER_ENGAGED_FOREVER,
         spec.NEVER_ENGAGED_REUNION
  From rpt_pbh634.v_entity_special_handling spec)



  select distinct house.ID_NUMBER,
         house.REPORT_NAME,
         house.RECORD_STATUS_CODE,
         house.FIRST_KSM_YEAR,
         house.PROGRAM,
         house.PROGRAM_GROUP,
         house.HOUSEHOLD_CITY,
         house.HOUSEHOLD_STATE,
         house.HOUSEHOLD_COUNTRY,
         employ.job_status_code,
         employ.job_title as current_job_title,
         employ.employer_name as current_employer_name,
         KSM_Spec.NO_CONTACT,
         KSM_Spec.NO_EMAIL_IND
  from rpt_pbh634.v_entity_ksm_households house
  Left join employ on employ.id_number = house.ID_NUMBER
  Left Join KSM_Spec on KSM_Spec.id_number = house.id_number
  where house.RECORD_STATUS_CODE IN ('A')
  and house.PROGRAM is not null
  and house.HOUSEHOLD_COUNTRY = 'Canada'
  and house.HOUSEHOLD_STATE = 'ON'
  Order by house.HOUSEHOLD_CITY asc
