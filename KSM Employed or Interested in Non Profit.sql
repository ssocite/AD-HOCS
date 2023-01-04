with h as (select *
from RPT_PBH634.V_ENTITY_KSM_HOUSEHOLDS),

e as (
  Select id_number
  , job_title
  , employment.fld_of_work_code
  , fow.short_desc As fld_of_work
  , employer_name1,
    Case
      When employer_id_number Is Not Null And employer_id_number != ' ' Then (
        Select pref_mail_name
        From entity
        Where id_number = employer_id_number)
      Else trim(employer_name1 || ' ' || employer_name2)
    End As employer_name
  From employment
  Left Join tms_fld_of_work fow
       On fow.fld_of_work_code = employment.fld_of_work_code
  Where employment.primary_emp_ind = 'Y'
),

industry as (select *
from v_industry_groups
where (v_industry_groups.short_desc = 'Non-Profit Organization Management'
or v_industry_groups.short_desc = 'Philanthropy'
or v_industry_groups.short_desc = 'Individual & Family Services'
or v_industry_groups.short_desc = 'Civic & Social Organization'
or v_industry_groups.short_desc = 'Religious Institutions')),

intr as (select interest.id_number,
Listagg (TMS_INTEREST.short_desc, ';  ') Within Group (Order By TMS_INTEREST.short_desc)
As short_desc
from interest
left join tms_interest on tms_interest.interest_code = interest.interest_code
where tms_interest.short_desc IN ('Non-Profit Organization Management', 'Philanthropy',
'Individual & Family Services', 'Civic & Social Organization', 'Religious Institutions')
group by interest.id_number),

KSM_Address as (Select
         a.Id_number,
         a.addr_pref_ind as address_pref_indicator,
         a.company_name_1,
         a.company_name_2,
         a.business_title,
        tms_address_type.short_desc as address_type
      ,  a.addr_pref_ind
      ,  a.street1
      ,  a.street2
      ,  a.street3
      ,  a.zipcode
      ,  a.city
      ,  a.state_code
      ,  a.country_code
      ,  tms_country.short_desc
      FROM address a
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN tms_address_type on tms_address_type.addr_type_code = a.addr_type_code
      WHERE a.addr_pref_IND = 'Y'),


np as (select e.id_number
  , e.job_title
  , industry.short_desc as industry
  , intr.short_desc as interest
  ,  e.employer_name
from e
left join industry on industry.fld_of_work_code = e.fld_of_work_code
left join intr on intr.id_number = e.id_number
Where (industry.fld_of_work_code is not null
or intr.id_number is not null)),

--- Special Handling Codes: No Contact/No Mail

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_MAIL_IND,
       spec.NO_CONTACT
From rpt_pbh634.v_entity_special_handling spec)

select distinct
       H.id_number,
       h.PREF_MAIL_NAME,
       h.FIRST_KSM_YEAR,
       h.PROGRAM,
       np.employer_name as primary_employer,
       np.job_title as primary_job_title,
       np.industry as Employment_in_non_profit,
       np.interest as Interest_in_non_profit_concat
      ,  KSM_Address.address_pref_indicator
      ,  KSM_Address.address_type
      ,  KSM_Address.company_name_1 as address_company_name1
      ,  KSM_Address.company_name_2 as address_company_name2
      ,  KSM_Address.business_title as address_business_title
      ,  KSM_Address.street1
      ,  KSM_Address.street2
      ,  KSM_Address.street3
      ,  KSM_Address.zipcode
      ,  KSM_Address.city
      ,  KSM_Address.state_code
from h
inner join KSM_Address on KSM_Address.id_number = h.id_number
inner join np on np.id_number = h.id_number
left join KSM_Spec on KSM_Spec.id_number = h.id_number
where h.program is not null
and KSM_Address.short_desc is null
and (KSM_Spec.NO_MAIL_IND is null
and KSM_Spec.NO_CONTACT is null)
order by KSM_Address.state_code ASC
