With KSM_Email AS (select email.id_number,
       email.email_address,
       email.preferred_ind
From email
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = email.id_number
Where email.preferred_ind = 'Y'),

KSM_telephone AS (Select t.id_number, t.telephone_number, t.area_code
From telephone t
Inner Join rpt_pbh634.v_entity_ksm_degrees deg ON deg.ID_NUMBER = t.id_number
Where t.preferred_ind = 'Y'),

employ As (
  Select id_number
  , job_title
  , employment.start_dt
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

j as (Select id_number
  , job_title
  , employment.stop_dt
  , employment.job_status_code
  , Case
      When employer_id_number Is Not Null And employer_id_number != ' ' Then (
        Select pref_mail_name
        From entity
        Where id_number = employer_id_number)
      -- Otherwise use the write-in field
      Else trim(employer_name1 || ' ' || employer_name2)
    End As employer_name
  From employment
  Where employment.job_status_code = 'P'),

past_employ as (select entity.id_number,
entity.report_name,
j.job_status_code,
max (j.job_title) keep (dense_rank first order by j.stop_dt desc, j.job_title) as job_title,
max (j.employer_name) keep (dense_rank first order by j.stop_dt desc, j.employer_name) as employer_name,
max (j.stop_dt) keep (dense_rank first order by j.stop_dt desc, j.stop_dt) as max_dt
from entity
inner join j on j.id_number = entity.id_number
Group By
entity.id_number,
entity.report_name,
j.job_status_code
--order by entity.id_number asc
),

--- Linkedin Subquery

linked as (select distinct ec.id_number,
max(ec.start_dt) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) As Max_Date,
max (ec.econtact) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) as linkedin_address
from econtact ec
where  ec.econtact_status_code = 'A'
and  ec.econtact_type_code = 'L'
Group By ec.id_number)

select distinct deg.id_number,
       entity.first_name,
       entity.last_name,
       entity.record_type_code,
       entity.record_status_code,
       deg.PROGRAM_GROUP,
       deg.FIRST_KSM_YEAR,
       KSM_telephone.area_code,
       KSM_telephone.telephone_number,
       KSM_Email.email_address,
       entity.birth_dt,
       employ.fld_of_work as primary_industry,
       employ.job_title as primary_job_title,
       employ.employer_name as primary_employer,
       employ.start_dt as primary_employment_start,
       ---- Most Recent Past Employer 
       past_employ.job_status_code as past_job_status_code,
       past_employ.job_title as past_job_title,
       past_employ.employer_name as past_employer_name,
       linked.linkedin_address

from rpt_pbh634.v_entity_ksm_degrees deg
INNER join entity on entity.id_number = deg.ID_NUMBER
left join KSM_Email on KSM_Email.id_number = deg.id_number
left join KSM_telephone on KSM_telephone.id_number = deg.id_number
left join linked on linked.id_number = deg.ID_NUMBER
left join employ on employ.id_number = deg.ID_NUMBER
left join j on j.id_number = deg.id_number 
left join past_employ on past_employ.id_number = deg.ID_NUMBER
where deg.record_status_code = 'A'
and (linked.linkedin_address is not null
OR deg.FIRST_KSM_YEAR >= '1960')
