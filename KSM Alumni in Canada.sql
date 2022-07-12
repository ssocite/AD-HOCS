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

assign as (select assign.id_number,
       assign.prospect_manager,
       assign.lgos,
       assign.managers,
       assign.curr_ksm_manager
from rpt_pbh634.v_assignment_summary assign),

KSM_Give AS (Select give.ID_NUMBER,
give.NGC_LIFETIME,
give.LAST_GIFT_DATE
from rpt_pbh634.v_ksm_giving_summary give),

TP AS (select tp.id_number, tp.pref_mail_name, TP.evaluation_rating, TP.Officer_rating
from nu_prs_trp_prospect TP)

select distinct house.ID_NUMBER,
       house.REPORT_NAME,
       house.RECORD_STATUS_CODE,
       house.FIRST_KSM_YEAR,
       house.PROGRAM,
       house.PROGRAM_GROUP,
       house.HOUSEHOLD_CITY,
       house.HOUSEHOLD_STATE,
       house.HOUSEHOLD_COUNTRY,
       TP.evaluation_rating,
       TP.Officer_rating,
       KSM_Give.NGC_LIFETIME,
       KSM_Give.LAST_GIFT_DATE,
       assign.prospect_manager,
       assign.lgos,
       employ.job_status_code,
       employ.job_title as current_job_title,
       employ.employer_name as current_employer_name
from rpt_pbh634.v_entity_ksm_households house
Left join employ on employ.id_number = house.ID_NUMBER
left join assign on assign.id_number = house.id_number
left join KSM_Give on KSM_Give.id_number = house.id_number
left join TP on TP.id_number = house.id_number
where house.RECORD_STATUS_CODE IN ('L','A')
and house.PROGRAM is not null
and house.HOUSEHOLD_COUNTRY = 'Canada'
Order by house.REPORT_NAME
