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

  --- Just Board Members: Board/Chair
  Where employment.job_title LIKE '%Board%'
  or employment.job_title LIKE '%Chair%'),

--- Past Employer Subquery
--- Pulled on Date Modified

p_employ as (select distinct
    employ.id_number
, min(employ.date_modified) keep(dense_rank First Order By employ.date_modified Desc, employ.date_modified asc) as stop_dt
,min(employ.job_status_code) keep(dense_rank First Order By employ.date_modified Desc, employ.job_status_code asc) as job_status
,min(employ.job_title) keep(dense_rank First Order By employ.date_modified Desc, employ.job_title asc) as job_title
,min(employ.employer_name) keep(dense_rank First Order By employ.date_modified Desc, employ.employer_name asc) as employer
from employ
where employ.job_status_code = 'P'
Group By employ.id_number),

--- Current Employer
c_employ as (select *
from employ
where employ.primary_emp_ind = 'Y'),

KSM_Email AS (select email.id_number,
       email.email_address,
       email.preferred_ind,
       email.forwards_to_email_address
From email
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = email.id_number
Where email.preferred_ind = 'Y'),

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_EMAIL_IND,
       spec.NO_CONTACT
From rpt_pbh634.v_entity_special_handling spec),

assignment as (select assign.id_number,
       assign.prospect_manager,
       assign.lgos,
       assign.managers,
       assign.curr_ksm_manager
from rpt_pbh634.v_assignment_summary assign)


select house.ID_NUMBER,
       house.REPORT_NAME,
       entity.gender_code,
       house.RECORD_STATUS_CODE,
       house.FIRST_KSM_YEAR,
       house.PROGRAM,
       house.PROGRAM_GROUP,
       house.HOUSEHOLD_CITY,
       house.HOUSEHOLD_STATE,
       c_employ.job_title as current_job_title,
       c_employ.employer_name as current_employer_name,
       p_employ.job_title as past_job_title,
       p_employ.employer as past_employer_name,
       KSM_Email.email_address,
       KSM_Spec.NO_EMAIL_IND,
       KSM_Spec.NO_CONTACT,
       assignment.lgos,
       assignment.prospect_manager
from rpt_pbh634.v_entity_ksm_households house
left join entity on entity.id_number = house.id_number
left join c_employ on c_employ.id_number = house.ID_NUMBER
left join p_employ on p_employ.id_number = house.ID_NUMBER
left join KSM_Email on KSM_Email.id_number = house.ID_NUMBER
left join KSM_Spec on KSM_Spec.id_number = house.ID_NUMBER
left join assignment on assignment.id_number = house.ID_NUMBER
where house.PROGRAM is not null
and house.FIRST_KSM_YEAR is not null
and house.RECORD_STATUS_CODE IN ('L','A')
and entity.gender_code = 'F'
and (c_employ.job_title is not null
or p_employ.job_title is not null)
and house.ID_NUMBER NOT IN (
--- Advisors to the Board - Not Actual Board Members
'0000334714',
'0000516267',
'0000492217',
--- Assistant to the Chairman
'0000580638',
'0000844162',
'0000395657',
--- Job title - Board Certified, but not a board member
'0000332266',
--- General Manager - In-Flight Services, On-Board Services
'0000564793')
Order by house.REPORT_NAME
--- Take out Job Titles that fit into the code, but not actaully board members
