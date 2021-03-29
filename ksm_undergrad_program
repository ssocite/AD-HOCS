WITH KSM_CERT AS (SELECT deg.id_number,
       Listagg (TMS_SCHOOL.short_desc, ';  ') Within Group (Order By TMS_SCHOOL.short_desc) As school,
       TMS_DEGREE_LEVEL.short_desc as degree_level,
       TMS_DEGREES.short_desc as degree_level_descr,
       deg.degree_year
FROM  degrees deg
LEFT JOIN TMS_DEGREES ON TMS_DEGREES.degree_code = DEG.DEGREE_CODE
LEFT JOIN ENTITY ON entity.ID_NUMBER = DEG.id_number
LEFT JOIN TMS_DEGREE_LEVEL ON  TMS_DEGREE_LEVEL.degree_level_code = DEG.DEGREE_LEVEL_CODE
LEFT JOIN TMS_SCHOOL ON TMS_SCHOOL.school_code = DEG.SCHOOL_CODE
--- Financial Economics Certificate (KSM Fin Econ Cert) or the Managerial Analytics Certificate (KSM Managerial Analytics)
--- Program: https://www.kellogg.northwestern.edu/certificate.aspx
 WHERE (deg.degree_code = 'KGFE'
    OR  deg.degree_code = 'KGMAC')
GROUP BY deg.id_number,
       TMS_DEGREE_LEVEL.short_desc,
       TMS_DEGREES.short_desc,
       deg.degree_year),

       employ as (
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
  Where employment.primary_emp_ind = 'Y'),

PrefAddress AS(
      Select
         a.Id_number
      ,  a.city
      ,  a.state_code
      ,  a.zipcode
      ,  tms_country.short_desc AS Country
      FROM address a
      INNER JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      WHERE a.addr_pref_IND = 'Y'),

linked as (select distinct ec.id_number,
max(ec.start_dt) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) As Max_Date,
max (ec.econtact) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) as linkedin_address
from econtact ec
where  ec.econtact_status_code = 'A'
and  ec.econtact_type_code = 'L'
Group By ec.id_number),


Intr as (Select
  interest.id_number As catracks_id,
  Listagg(tms_interest.short_desc, '; ') Within Group (Order By tms_interest.short_desc) as interest_desc
From interest
Inner Join tms_interest
  On tms_interest.interest_code = interest.interest_code --- Produce TMS Codes
Where tms_interest.interest_code Like 'L%' --- Any Linkedin Industry Code
  Or tms_Interest.interest_code = '16'  --- KIS also wants the ""16"" Research Code
Group By interest.id_number
),

assignment as (select assign.id_number,
       assign.prospect_manager,
       assign.lgos,
       assign.managers,
       assign.curr_ksm_manager
from rpt_pbh634.v_assignment_summary assign)

select entity.id_number,
       entity.report_name,
       entity.institutional_suffix,
       entity.record_type_code,
       entity.record_status_code,
       KSM_CERT.school,
       KSM_CERT.degree_level,
       KSM_CERT.degree_level_descr,
       KSM_CERT.degree_year,
       employ.fld_of_work,
       employ.job_title,
       employ.employer_name,
       linked.linkedin_address,
       Intr.interest_desc as interest_concat,
       assignment.prospect_manager,
       assignment.managers,
       PrefAddress.city,
       PrefAddress.state_code,
       PrefAddress.Country
from entity
left join PrefAddress on PrefAddress.id_number = entity.id_number
left join employ on employ.id_number = entity.id_number
left join linked on linked.id_number = entity.id_number
left join Intr on Intr.catracks_id = entity.id_number
left join assignment on assignment.id_number = entity.id_number
inner join KSM_CERT on KSM_CERT.id_number = entity.id_number
order by entity.report_name ASC
