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
    ,employment.date_modified
  From employment
  Left Join tms_fld_of_work fow
       On fow.fld_of_work_code = employment.fld_of_work_code
  Where employment.primary_emp_ind = 'Y'
),

Business_Address as (      Select
         a.Id_number
      ,  tms_addr_status.short_desc AS Address_Status
      ,  tms_address_type.short_desc AS Address_Type
      ,  a.addr_pref_ind
      ,  a.company_name_1
      ,  a.company_name_2
      ,  a.street1
      ,  a.street2
      ,  a.street3
      ,  a.foreign_cityzip
      ,  a.city
      ,  a.state_code
      ,  a.zipcode
      ,  tms_country.short_desc AS Country
      ,  a.date_modified
      FROM address a
      INNER JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      WHERE a.addr_pref_IND = 'Y'
      AND a.addr_status_code = 'A'
      AND a.addr_type_code = 'B')

select deg.ID_NUMBER,
deg.REPORT_NAME,
deg.RECORD_STATUS_CODE,
deg.FIRST_KSM_YEAR,
employ.job_title,
employ.employer_name,
employ.fld_of_work,
employ.date_modified as employment_modified,
Business_Address.Address_Status,
Business_Address.Address_Type,
Business_Address.addr_pref_ind,
Business_Address.company_name_1 as company_name_address,
Business_Address.company_name_2 as company_name_address2,
Business_Address.street1,
Business_Address.street2,
Business_Address.street3,
Business_Address.foreign_cityzip,
Business_Address.city,
Business_Address.state_code,
Business_Address.Country,
Business_Address.date_modified as business_address_modified
from rpt_pbh634.v_entity_ksm_degrees deg
left join employ on employ.id_number = deg.ID_NUMBER
left join Business_Address on Business_Address.id_number = deg.ID_NUMBER
where (employ.employer_name like '%J.P. Morgan Chase Bank%'
or employ.employer_name like '%JPMorgan Chase & Co.%'
or employ.employer_name like '%McKinsey & Company Inc.%'
or employ.employer_name like '%Google%'
or employ.employer_name like '%Amazon%'
or employ.employer_name like '%Boston Consulting Group%'
or employ.employer_name like '%BCG%'
or employ.employer_name like '%IBM%'
or employ.employer_name like '%Bain%'
or employ.employer_name like '%Accenture%'
or employ.employer_name like '%Microsoft%'
or employ.employer_name like '%Deloitte%'
or employ.employer_name like '%Bank of America%')
order by employ.employer_name asc
