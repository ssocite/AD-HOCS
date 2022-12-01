
---- 1.  Program (2 Year, 1 Year, MMM, JDMBA)
---- 2. Household Address
with h AS (select *
from rpt_pbh634.v_entity_ksm_households 
where rpt_pbh634.v_entity_ksm_households.program IN ('FT-1Y','FT-2Y','FT-MMM','FT-JDMBA')),

--- 3.  Business address (current)
BG as (Select
gc.*
From table(rpt_pbh634.ksm_pkg_tmp.tbl_geo_code_primary) gc
Inner Join address
On address.id_number = gc.id_number
And address.xsequence = gc.xsequence
Where address.addr_type_code = 'B'),

BusinessAddress AS( 
      Select
         a.Id_number
      ,  tms_addr_status.short_desc AS Address_Status
      ,  tms_address_type.short_desc AS Address_Type
      ,  a.addr_pref_ind
      ,  a.street1
      ,  a.street2
      ,  a.street3
      ,  a.foreign_cityzip
      ,  a.city
      ,  a.state_code
      ,  a.zipcode
      ,  tms_country.short_desc AS Country
      ,  BG.GEO_CODE_PRIMARY_DESC AS BUSINESS_GEO_CODE
      FROM address a
      INNER JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      INNER JOIN BG 
      ON BG.ID_NUMBER = A.ID_NUMBER
      AND BG.xsequence = a.xsequence
      WHERE a.addr_type_code = 'B'
      AND a.addr_status_code IN('A','K')
),

--- Kellogg Alumni Admission Callers
kaac as(select distinct committee.id_number
from committee
where committee.committee_code = 'KAAC'
and committee.committee_status_code = 'C'),

---- Kellogg Alumni Leadership Council
kalc as(select distinct committee.id_number
from committee
where committee.committee_code = 'KALC'
and committee.committee_status_code = 'C'),


--- Data for the Job Fields 


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

--- narrow by industry: consulting, finance, tech, healthcare
--- We will use this for the USA and International Pulls 

industry as (select *
from v_industry_groups
where (v_industry_groups.HLTH is not null 
or v_industry_groups.FIN is not null 
or v_industry_groups.TECH is not null 
or v_industry_groups.HLTH is not null 
or v_industry_groups.short_desc = 'Management Consulting')),

--- specific requirements for the USA and International List to meet the ad-hoc industries

e As (
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
  Inner Join industry v on v.fld_of_work_code = employment.fld_of_work_code     
  Where employment.primary_emp_ind = 'Y'
),

---- Household in USA 
--- 5 years --- Inner Join 

usa as (select h.id_number
from h
inner join e on e.id_number = h.id_number
where (h.HOUSEHOLD_COUNTRY = 'United States'
and h.FIRST_KSM_YEAR >= 2017)),

--- Household in International 
--- 10 years

international as (select h.id_number
from h
inner join e on e.id_number = h.id_number
where (h.HOUSEHOLD_COUNTRY != 'United States'
and h.FIRST_KSM_YEAR >= 2012)),

--- KSM Alumni Interviewers 
--- View from the 7/2022 list from Admissions

i as (select *
from ksm_current_al_interviewers),

Spec AS (Select rpt_pbh634.v_entity_special_handling.ID_NUMBER,
       rpt_pbh634.v_entity_special_handling.GAB,
       rpt_pbh634.v_entity_special_handling.TRUSTEE,
       rpt_pbh634.v_entity_special_handling.NO_CONTACT,
       rpt_pbh634.v_entity_special_handling.NO_SOLICIT,
       rpt_pbh634.v_entity_special_handling.NO_PHONE_IND,
       rpt_pbh634.v_entity_special_handling.NO_EMAIL_IND,
       rpt_pbh634.v_entity_special_handling.NO_MAIL_IND,
       rpt_pbh634.v_entity_special_handling.SPECIAL_HANDLING_CONCAT,
       rpt_pbh634.v_entity_special_handling.EBFA
From rpt_pbh634.v_entity_special_handling)

select h.ID_NUMBER,
       h.REPORT_NAME,
       h.RECORD_STATUS_CODE,
       case when kaac.id_number is not null then 'KAAC Member' End as KAAC_Flag,
         case when kalc.id_number is not null then 'KALC Member' End as KALC_Flag,
           case when i.id_number is not null then 'Current KSM Alumni Interview Volunteer' End as Alumni_Interviewer_vol_Flag,
       h.INSTITUTIONAL_SUFFIX,
       h.FIRST_KSM_YEAR,
       h.PROGRAM,
       h.PROGRAM_GROUP,
       h.HOUSEHOLD_CITY,
       h.HOUSEHOLD_STATE,
       h.HOUSEHOLD_COUNTRY,
       BusinessAddress.city as Business_city,
       BusinessAddress.state_code as Business_State_code,
       BusinessAddress.country as Business_Country,
       employ.job_title,
       employ.employer_name,
       employ.fld_of_work employment_industry,
       spec.NO_EMAIL_IND,
       spec.NO_CONTACT
from  h
left join kaac on kaac.id_number = h.id_number
left join kalc on kalc.id_number = h.id_number
left join usa on usa.id_number = h.id_number
left join international on international.id_number = h.id_number
left join employ on employ.id_number = h.id_number
left join spec on spec.id_number = h.id_number
left join i on i.id_number = h.id_number
left join BusinessAddress on BusinessAddress.id_number = h.id_number
--- Include KAAC and KALC
--- Include USA 5 Years out in certain industries
--- Include International 10 years out in certain industries
where (usa.id_number is not null 
or international.id_number is not null
or kaac.id_number is not null
or kalc.id_number is not null)
and (Spec.NO_CONTACT is null
and Spec.NO_EMAIL_IND is null)
order by h.REPORT_NAME asc
