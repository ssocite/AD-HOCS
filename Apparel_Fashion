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
),

Intr as (Select interest.id_number,
interest.interest_code,
TMS_INTEREST.short_desc
from interest
left join TMS_INTEREST ON TMS_INTEREST.interest_code = interest.interest_code
where interest.interest_code = 'L06')

Select distinct
deg.ID_NUMBER,
deg.REPORT_NAME,
deg.RECORD_STATUS_CODE,
deg.FIRST_KSM_YEAR,
deg.PROGRAM,
deg.PROGRAM_GROUP,
employ.job_title,
employ.employer_name,
employ.fld_of_work as industry_of_work,
Intr.short_desc
From rpt_pbh634.v_entity_ksm_degrees deg
Left Join employ on employ.id_number = deg.id_number
Left Join Intr on Intr.id_number = deg.ID_NUMBER
where deg.RECORD_STATUS_CODE = 'A'
and deg.PROGRAM not like '%NONGRD%'
and intr.interest_code like 'L06'
and employ.job_title is not null
order by deg.REPORT_NAME ASC
