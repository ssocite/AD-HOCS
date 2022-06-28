with org_employer As (
  --- Using subquery to Get Employer Names from Employee ID #'s 
  Select id_number, report_name
  From entity 
  Where entity.person_or_org = 'O'
),

p_employ as (Select
  id_number
  , ultimate_parent_employer_id
  , ultimate_parent_employer_name
From dm_ard.dim_employment@catrackstobi),


employ As (
Select
  employ.id_Number As catracks_id
  , employ.start_dt
  , rpt_pbh634.ksm_pkg.to_date2(employ.start_dt) As employment_start_date
  , employ.stop_dt
  , rpt_pbh634.ksm_pkg.to_date2(employ.stop_dt) As employment_stop_date
  , employ.job_status_code As job_status_code
  , tms_job_status.short_desc As job_status_desc
  , employ.primary_emp_ind As primary_employer_indicator
  , employ.self_employ_ind As self_employed_indicator
  , employ.job_title
  , employ.employer_id_number
  , p_employ.ultimate_parent_employer_id
  , p_employ.ultimate_parent_employer_name
  , Case --- Used for those alumni with an employer code, but not employer name1
      When employ.employer_name1 = ' '
        Then org_employer.report_name
      Else employ.employer_name1
      End
    As employer
  , employ.fld_of_work_code As fld_of_work_code
  , fow.short_desc As fld_of_work_desc
  , employ.date_added
  , employ.date_modified
  , employ.operator_name
From employment employ
Left Join rpt_pbh634.v_entity_ksm_households h on h.id_number = employ.id_number
Left Join tms_fld_of_work fow
  On employ.fld_of_work_code = fow.fld_of_work_code --- To get FLD of Work Code
Left  Join tms_job_status
  On tms_job_status.job_status_code = employ.job_status_code --- To get job description
Left Join org_employer
  On org_employer.id_number = employ.employer_id_number --- To get the name of those with employee ID
Left Join P_Employ on P_Employ.id_number = h.id_number --- to get parent employer ID and parent employer name
Where employ.job_status_code In ('C', 'P', 'Q', 'R', ' ', 'L')
--- Employment Key: C = Current, P = Past, Q = Semi Retired R = Retired L = On Leave
and h.record_status_code != 'X' --- Remove Purgable
and employ.employer_id_number = '0000439808'
Order By employ.id_Number Asc),

N as (Select
  employ.catracks_id
  , max (employ.start_dt) as start_dt
  , max (rpt_pbh634.ksm_pkg.to_date2(employ.start_dt)) As employment_start_date
  , max (employ.stop_dt) as stop_dt
  , max (employ.job_status_desc) As job_status_code
  , max (job_status_desc) As job_status_desc
  , max (employ.primary_employer_indicator) As primary_employer_indicator
  , max (employ.self_employed_indicator) As self_employed_indicator
  , max (employ.job_title) as job_title
  , max (employ.employer_id_number) as employer_id_number
  , max (employ.ultimate_parent_employer_id) as ultimate_parent_employer_id
  , max (employ.ultimate_parent_employer_name) as ultimate_parent_employer_name
  , max (employ.employer) as employer
  , max (employ.fld_of_work_desc) As fld_of_work_code
  , max (employ.fld_of_work_desc) As fld_of_work_desc
  , max (employ.date_added) as date_added
  , max (employ.date_modified) as date_modified
  , max (employ.operator_name) as operator_name
  from employ 
  group by employ.catracks_id),
  
  
KSM_Faculty_Staff as (select aff.id_number,
       TMS_AFFIL_CODE.short_desc as affilation_code,
       tms_affiliation_level.short_desc as affilation_level
FROM  affiliation aff
LEFT JOIN TMS_AFFIL_CODE ON TMS_AFFIL_CODE.affil_code = aff.affil_code
Left JOIN tms_affiliation_level ON tms_affiliation_level.affil_level_code = aff.affil_level_code
 WHERE  aff.affil_code = 'KM'
   AND (aff.affil_level_code = 'ES'
    OR  aff.affil_level_code = 'EF')),
    
NU_Degreed as (SELECT DISTINCT
deg.id_number,
case when deg.id_number is not null then 'NU Degree' Else '' End As NU_Degree
  FROM  degrees deg
 WHERE  UPPER(deg.institution_code) = '31173' )

select 
entity.id_number,
entity.first_name,
entity.last_name,
NU_Degreed.NU_Degree as NU_Degree_IND,
entity.institutional_suffix,
s.affilation_code as school_of_employment,
s.affilation_level as employment_level,
n.job_title,
n.employer
from entity
inner join KSM_Faculty_Staff s on s.id_number = entity.id_number
inner join NU_Degreed on NU_Degreed.id_number = entity.id_number
left join  n on n.catracks_id = entity.id_number
order by entity.last_name asc
