/* Main Employment Subquery
This will filter out CEO, CMO and take out amazon and google (alphabet)
Also accounts for employer name IDs + employer name 1
Takes out job titles not related to the request
*/

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

  --- C-Suite Only: CMOs and CEOs
  Where (UPPER(employment.job_title) LIKE '%CEO%'
    or  UPPER(employment.job_title) LIKE '%CMO%'
    or employment.job_title like '%Chief Marketing Officer%'
    or employment.job_title like '%Chief Executive Officer%')
    --- Remove Lesser Job Titles
    And (employment.job_title NOT Like '%Vice%'
    And employment.job_title NOT Like '%Coordinator%'
    and employment.job_title NOT Like '%Advisor%'
    and employment.job_title NOT Like '%Assistant%'
    and employment.job_title NOT Like '%Assist%'
    and employment.job_title NOT Like '%Deputy%'
    and employment.job_title NOT Like '%VP%'
    and employment.job_title NOT Like '%Coord%'
    ---- Saw a bunch of Chief of Staff to CEO 9/20/2021
    and employment.job_title NOT Like '%Staff%')
    --- Take out Google, Amazon and Alphabet (9/20/2021)
  And (employer_name1 NOT Like '%Google'
  And employer_name1 NOT Like '%Amazon%'
  And employer_name1 NOT Like '%Alphabet%')
  --- Take out the employer IDs too!
  --- 0000540846 = Google Inc - Alphabet is an Alias in Google Entity ID
  ---- 0000733095 = Amazon Web Servcies
  ---- 0000417037 Amazon
  And (employment.employer_id_number != '0000540846'
and employment.employer_id_number != '0000733095'
and employment.employer_id_number != '0000417037')),

--- Past Employer Subquery
--- Pulled on Date Modified - Too my 0000s with some of the employers

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

--- Marketing Flds of Work Both interest and employment
--- L83: Market Research
--- L84: Marketing and Advertising

m_employ as (select
employ.id_number,
Listagg (TMS_FLD_OF_WORK.short_desc, ';  ') Within Group (Order By TMS_FLD_OF_WORK.short_desc) As fld_indicator
from employ
left join TMS_FLD_OF_WORK on TMS_FLD_OF_WORK.fld_of_work_code = employ.fld_of_work_code
where employ.fld_of_work_code IN ('L84','L83')
Group By employ.id_number),

m_interest as (select
interest.id_number,
Listagg (TMS_INTEREST.short_desc, ';  ') Within Group (Order By TMS_INTEREST.short_desc) As Interest_indicator
from interest
Left Join TMS_INTEREST on TMS_INTEREST.interest_code = interest.interest_code
Where Interest.Interest_Code IN ('L84','L83')
Group By interest.id_number)

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
       case when m_employ.id_number is not null then 'Yes' else 'No' End as Career_Experience_in_Marketing,
       case when m_interest.id_number is not null then 'Yes' else 'No' End as Interest_in_Marketing
from rpt_pbh634.v_entity_ksm_households house
left join entity on entity.id_number = house.id_number
left join c_employ on c_employ.id_number = house.ID_NUMBER
left join p_employ on p_employ.id_number = house.ID_NUMBER
left join m_employ on m_employ.id_number = house.ID_NUMBER
left join m_interest on m_interest.id_number = house.ID_NUMBER
where house.PROGRAM is not null
and house.FIRST_KSM_YEAR is not null
and house.RECORD_STATUS_CODE IN ('L','A')
and entity.gender_code = 'F'
and (c_employ.job_title is not null
or p_employ.job_title is not null)
Order by house.REPORT_NAME