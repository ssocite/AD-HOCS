--- Manufacturing subquery 
with m as (select
a.fld_of_work_code,
       a.short_desc,
       a.industry_group,
       a.AGR,
       a.ART,
       a.CONS,
       a.CORP,
       a.EDU,
       a.FIN,
       a.GOODS,
       a.GOVT,
       a.HLTH,
       a.LEG,
       a.MAN,
       a.MED,
       a.ORG,
       a.REC,
       a.SERV,
       a.TECH,
       a.TRAN
from v_industry_groups a
where a.MAN is not null),

-- General Employment and identifying the C-Suites

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
  And (UPPER(employment.job_title) LIKE '%CHIEF%'
    OR  UPPER(employment.job_title) LIKE '%CMO%'
    OR  UPPER(employment.job_title) LIKE '%CEO%'
    OR  UPPER(employment.job_title) LIKE '%CFO%'
    OR  UPPER(employment.job_title) LIKE '%COO%'
    OR  UPPER(employment.job_title) LIKE '%CIO%')
),


--- create an interest view

i as (select *
from nu_ksm_v_datamart_career_inter
--- Only want the manufacturing industries
inner join m on m.fld_of_work_code =  nu_ksm_v_datamart_career_inter.interest_code),

--- Concatanate that interest view

--- This is the final interest list, which will concatanated interests
final_i as  (Select
    intr.catracks_id
    , Listagg(intr.interest_desc, '; ') Within Group (Order By interest_start_date Asc, interest_desc Asc)
      As interests_concat
  From i intr
  Group By intr.catracks_id),

--- Final employer
--- This will pull/create flag in C Suites

final_e as (select *
from employ
inner join m on m.fld_of_work_code = employ.fld_of_work_code),

linked as (select distinct ec.id_number,
max(ec.start_dt) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) As Max_Date,
max (ec.econtact) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) as linkedin_address
from econtact ec
where  ec.econtact_status_code = 'A'
and  ec.econtact_type_code = 'L'
Group By ec.id_number)


select house.ID_NUMBER,
       house.REPORT_NAME,
       entity.gender_code,
       house.RECORD_STATUS_CODE,
       house.FIRST_KSM_YEAR,
       house.PROGRAM,
       house.PROGRAM_GROUP,
       house.HOUSEHOLD_CITY,
       house.HOUSEHOLD_STATE,
       case when final_e.id_number is not null then 'C_Suite_Employed' End as C_Suite_Emp_IND,
         case when final_i.catracks_id is not null then 'C_Suite_Interested' End as C_Suite_Intr_IND,
       employ.job_title,
       employ.employer_name,
       employ.fld_of_work,
       final_i.interests_concat,
       linked.linkedin_address

from rpt_pbh634.v_entity_ksm_households house
inner join employ on employ.id_number = house.ID_NUMBER
left join entity on entity.id_number = house.ID_NUMBER
left join final_i on final_i.catracks_id = house.id_number
left join final_e on final_e.id_number = house.id_number
left join linked on linked.id_number = house.id_number
where house.PROGRAM is not null
and house.RECORD_STATUS_CODE = 'A'
and entity.gender_code = 'F'
and (final_i.catracks_id is not null
or final_e.id_number is not null)
order by house.REPORT_NAME ASC
