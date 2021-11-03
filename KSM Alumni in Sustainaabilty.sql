With
-- Employment table subquery
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

KSM_Interest as (select interest.id_number,
Listagg (TMS_INTEREST.short_desc, ';  ') Within Group (Order By TMS_INTEREST.short_desc) As Interest_indicator
From Interest
Left Join TMS_INTEREST on TMS_INTEREST.interest_code = interest.interest_code
group by interest.id_number),

---- Most Recent Engagement

Engage As (Select DISTINCT event.id_number,
       max (start_dt_calc) keep (dense_rank First Order By start_dt_calc DESC) As Date_Recent_Event,
       max (event.event_id) keep (dense_rank First Order By start_dt_calc DESC) As Recent_Event_ID,
       max (event.event_name) keep(dense_rank First Order By start_dt_calc DESC) As Recent_Event_Name
from rpt_pbh634.v_nu_event_participants event
where event.ksm_event = 'Y'
and event.degrees_concat is not null
Group BY event.id_number
Order By Date_Recent_Event ASC),

--- Special Handling Code

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_EMAIL_IND,
       spec.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling spec),

--- KSM Giving NGC Lifetime

KSM_Give As (select give.ID_NUMBER,
give.NGC_LIFETIME
from rpt_pbh634.v_ksm_giving_summary give
where give.NGC_LIFETIME > 2500)

Select Distinct
rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER,
rpt_pbh634.v_entity_ksm_degrees.REPORT_NAME,
rpt_pbh634.v_entity_ksm_households.HOUSEHOLD_COUNTRY,
rpt_pbh634.v_entity_ksm_degrees.RECORD_STATUS_CODE,
rpt_pbh634.v_entity_ksm_degrees.FIRST_KSM_YEAR,
rpt_pbh634.v_entity_ksm_degrees.PROGRAM,
rpt_pbh634.v_entity_ksm_degrees.PROGRAM_GROUP,
Entity.Gender_Code,
Employ.fld_of_work_code,
Employ.fld_of_work,
Employ.employer_name,
Employ.job_title,
KSM_Interest.Interest_indicator,
Engage.Date_Recent_Event,
Engage.Recent_Event_ID,
Engage.Recent_Event_Name,
rpt_pbh634.v_entity_ksm_households.HOUSEHOLD_CITY,
rpt_pbh634.v_entity_ksm_households.HOUSEHOLD_STATE,
rpt_pbh634.v_entity_ksm_households.HOUSEHOLD_ZIP,
rpt_pbh634.v_assignment_summary.prospect_manager,
rpt_pbh634.v_assignment_summary.lgos,
rpt_pbh634.v_assignment_summary.managers,
KSM_Spec.no_email_ind,
KSM_Give.NGC_LIFETIME
From rpt_pbh634.v_entity_ksm_degrees
Inner Join Entity on rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER = Entity.Id_Number
Left Join rpt_pbh634.v_entity_ksm_households On rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER = rpt_pbh634.v_entity_ksm_households.ID_NUMBER
Left Join Employ On rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER = Employ.Id_Number
Left Join rpt_pbh634.v_assignment_summary on rpt_pbh634.v_assignment_summary.id_number = rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER
Left Join KSM_Spec on KSM_Spec.id_number = rpt_pbh634.v_entity_ksm_degrees.id_number
Left Join KSM_Interest on KSM_Interest.id_number = rpt_pbh634.v_entity_ksm_degrees.id_number
Left Join Engage on Engage.id_number = rpt_pbh634.v_entity_ksm_degrees.id_number
Inner Join KSM_Give on KSM_Give.id_number = rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER

Where  (Employ.fld_of_work_code IN ('L18', 'L53', 'L59', 'L61', 'L66','L71','L73', 'L72',
'L74', 'L75', 'L38', 'L123', 'L93','L97','L106','L109','L114','L115','L116')
or Employ.job_title like '%Social%'
or Employ.job_title like '%Responsibility%'
or employ.job_title like '%Impact%'
or employ.job_title like '%Fund%'
or employ.job_title like '%Ethic%')


or KSM_Interest.Interest_indicator IN ('L18', 'L53', 'L59', 'L61', 'L66','L71', 'L73', 'L72',
'L74', 'L75', 'L38', 'L123', 'L93','L97','L106','L109','L114','L115','L116')

and rpt_pbh634.v_entity_ksm_degrees.RECORD_STATUS_CODE = 'A'

Order by rpt_pbh634.v_entity_ksm_households.HOUSEHOLD_COUNTRY ASC
