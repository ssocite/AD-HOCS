/* Pulling KSM Alumni in R&D, Research and Development

--- Want to pull, CIOS, CTOs, R&D, Reseach and Development

1. Make subquery pulling on specific titles
2. Check and exclude job titles that come with the search.
Example when pulling CTO, watch out for DireCTOr
3. Create subquery that pulls primary employer from master subquery
4. Create subquery that pulls past employer if they do not have primary employer
5. Do a case when on the base the takes primary employer first,
if not primary employer, then past employer */

With e as (Select id_number
  , job_title
  , fow.short_desc As fld_of_work
  , employer_name1
  ,employment.stop_dt
  ,employment.start_dt
  ,employment.job_status_code
  ,employment.primary_emp_ind
  ,tms_job_status.short_desc
    -- If there's an employer ID filled in, use the entity name
    , Case
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
  Left Join tms_job_status on tms_job_status.job_status_code =
  employment.job_status_code

       Where

--- Pull Exact Job Titles

       ((employment.job_title = 'CTO'
  or employment.job_title = 'CIO'
or employment.job_title = 'Chief Technology Officer'
or employment.job_title = 'Chief Information Officer'
or employment.job_title = 'Director of Research'
or employment.job_title = 'Head of Research')

--- Pulling Same employment, but differently (Abbreivations/Contains)

or (employment.job_title like '%CTO%'

--- Remove Irrelevent Jobs when you pull on the CTO. Lots of Directors

and employment.job_title != 'BRAND DIRECTOR'
and employment.job_title != 'AREA SALES DIRECTOR'
and employment.job_title != 'BU SURF BRASIL DIRECTOR'
and employment.job_title != 'DIRECTOR, LEADERSHIP DEVELOPMENT'
and employment.job_title != 'INDEPENDENT CONSULTANT/INTERIM DIRECTOR'
and employment.job_title != 'MANAGING VP / DIRECTOR GENERAL - HEALTH NUTRACEUTICALS'
and employment.job_title != 'DIRECTOR'
and employment.job_title != 'DIRECTOR CORPORATE DEVELOPMENT'
and employment.job_title != 'DIRECTOR, STRATEGY & OPERATIONS'
and employment.job_title != 'Director'
and employment.job_title != 'MANAGING DIRECTOR'
and employment.job_title != 'MANAGING DIRECTOR OF CLINICAL DEVELOPMENT AND GOV AFFAIRS'
and employment.job_title != 'MARKETING DIRECTOR / SENIOR TECHNICAL ADVISOR'
and employment.job_title != 'Latin America DIRECTOR')

--- Same exact, but for Chief Information Officer

or (employment.job_title like '%CIO%'
and employment.job_title != 'SOCIO'
and employment.job_title != 'MTS, Office of CTO')

--- Pull Other Job titles

or (employment.job_title like '%Chief Technology Officer%'
or employment.job_title like '%Chief Information Officer%'
or employment.job_title like '%Head of Research%')

or (employment.job_title like '%Research%'
and employment.job_title like '%Development%')


--- Exclude MORE irrelevent job titles from my search

and (employment.job_title Not like '%Associate%')
and (employment.job_title != 'Chief of Staff to MWRD Commissioner David J Walsh'
and employment.job_title != 'Engineering Manager'
and employment.job_title != 'District Sales Manager (IRDP)'
and employment.job_title != 'Exec Dir, Marketing & Comm ARD'
and employment.job_title != 'Government Bonds TRD'
and employment.job_title != 'SENIOR ADVISORY BOARD MEMBER'
and employment.job_title != 'Chief of Staff, Office of CIO & Enterprise Innovation'
and employment.job_title != 'VP, Global Strategy & Business Development, TOM FORD BEAUTY'
and employment.job_title != 'Associate Director Leadership Giving, ARD'
and employment.job_title != 'Chief of Staff to MWRD Commissioner David J Walsh'
and employment.job_title != 'Chief of Staff, Office of CIO & Enterprise Innovation'
and employment.job_title != 'District Sales Manager (IRDP)'
and employment.job_title != 'Senior Project Manager'
and employment.job_title != 'Sr Manager, Business Dev'
and employment.job_title != 'Technical Manager'
and employment.job_title != 'Tudor'))),

--- Find those above that are the Primary Employer

pe as (select distinct e.id_number
  , e.job_title
  , e.fld_of_work
  , e.short_desc
  , e.stop_dt
  , e.start_dt
  , e.job_status_code
  , e.primary_emp_ind
  , e.employer_name
from e
where e.primary_emp_ind = 'Y'),

--- Now find the past job titles. We will want to take the most RECENT
--- job relevent to the pull

past as (select distinct e.id_number,
max (e.short_desc) keep (dense_rank First Order By e.short_desc DESC) as short_desc,
max (e.job_status_code) keep (dense_rank First Order By e.job_status_code DESC) as job_status_code,
max (e.job_title) keep (dense_rank First Order By e.job_title DESC) as job_title,
max (e.employer_name) keep (dense_rank First Order By e.employer_name DESC) as employer_name,
max (e.fld_of_work) keep (dense_rank First Order By e.fld_of_work DESC) as fld_of_work,
max (e.start_dt) keep (dense_rank First Order By e.start_dt DESC) as start_dt,
max (e.stop_dt) keep (dense_rank First Order By e.stop_dt DESC) as stop_dt
from e
left join pe on pe.id_number = e.id_number
where e.primary_emp_ind = 'N'
and e.job_status_code != 'M'
And pe.id_number is null
group by e.id_number),


KSM_Spec AS (Select spec.ID_NUMBER,
       spec.SPECIAL_HANDLING_CONCAT,
       spec.NO_EMAIL_IND,
       spec.GAB,
       spec.TRUSTEE,
       spec.EBFA,
       spec.NO_CONTACT
From rpt_pbh634.v_entity_special_handling spec)

select house.ID_NUMBER,
       house.REPORT_NAME,
       house.FIRST_KSM_YEAR,
       house.PROGRAM,
       house.PROGRAM_GROUP,
       --- Case Whens that take the primary employer precedent
       case when pe.short_desc is not null then pe.short_desc
         else past.short_desc end as Job_Status,
       case when pe.job_title is not null then pe.job_title
         else past.job_title end as job_title,
       case when pe.employer_name is not null then pe.employer_name
         else past.employer_name end as employer_name,
       case when pe.fld_of_work is not null then pe.fld_of_work
         else past.fld_of_work end as fld_of_work,
       house.HOUSEHOLD_CITY,
       house.HOUSEHOLD_STATE,
       house.HOUSEHOLD_COUNTRY

from rpt_pbh634.v_entity_ksm_households house
--- primary employer
left join pe on pe.id_number = house.id_number
--- past employer
left join past on past.id_number = house.ID_NUMBER

inner join entity on entity.id_number = house.id_number
left join ksm_spec k on k.id_number = house.id_number
where house.PROGRAM is not null
and house.RECORD_STATUS_CODE IN ('A','L')
and (k.NO_EMAIL_IND is null
and       k.GAB is null
and      k.TRUSTEE is null
and     k.EBFA is null
and   k.NO_CONTACT is null
and (past.id_number is not null
or pe.id_number is not null))
order by job_title asc
