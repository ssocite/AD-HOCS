With employ As (
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
  And (UPPER(employment.job_title) LIKE '%CHIEF%'
    OR  UPPER(employment.job_title) LIKE '%CMO%'
    OR  UPPER(employment.job_title) LIKE '%CEO%'
    OR  UPPER(employment.job_title) LIKE '%CFO%'
    OR  UPPER(employment.job_title) LIKE '%COO%'
    OR  UPPER(employment.job_title) LIKE '%CIO%')
)

select house.ID_NUMBER,
       house.REPORT_NAME,
       house.RECORD_STATUS_CODE,
       house.FIRST_KSM_YEAR,
       house.PROGRAM,
       house.PROGRAM_GROUP,
       house.HOUSEHOLD_CITY,
       house.HOUSEHOLD_STATE,
       employ.job_title,
       employ.employer_name

from rpt_pbh634.v_entity_ksm_households house
inner join employ on employ.id_number = house.ID_NUMBER
where house.PROGRAM is not null
and house.RECORD_STATUS_CODE = 'A'
order by house.REPORT_NAME ASC
