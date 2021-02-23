With KSM_Email AS (select email.id_number,
       email.email_address,
       email.preferred_ind
From email
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = email.id_number
Where email.preferred_ind = 'Y'),

ksm_home_email as (select distinct email.id_number,
Listagg (email.email_address, ';  ') Within Group (Order By email.email_address) As home_email
From email
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = email.id_number
Where email.email_type_code = 'X'
Group By email.id_number),

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.SPECIAL_HANDLING_CONCAT,
       spec.NO_EMAIL_IND
From rpt_pbh634.v_entity_special_handling spec),

pref_address as (SELECT addr.id_number,
       addr.addr_type_code,
       TMS_ADDRESS_TYPE.short_desc,
       addr.city,
       addr.state_code,
       TMS_COUNTRY.short_desc as country
FROM  address addr
INNER JOIN rpt_pbh634.v_entity_ksm_degrees deg ON deg.ID_NUMBER = addr.id_number
LEFT JOIN TMS_COUNTRY ON TMS_COUNTRY.country_code = ADDR.COUNTRY_CODE
LEFT JOIN TMS_ADDRESS_TYPE ON TMS_ADDRESS_TYPE.addr_type_code = ADDR.ADDR_TYPE_CODE
WHERE  addr.addr_pref_ind = 'Y'
and TMS_COUNTRY.short_desc is not null),


nationality as (select ent.id_number, ent.citizen_cntry_code1, ent.citizen_cntry_code2
from entity ent
inner join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = ent.id_number),

ksm_address as (select rpt_pbh634.v_datamart_address.catracks_id,
rpt_pbh634.v_datamart_address.home_city,
rpt_pbh634.v_datamart_address.home_state,
rpt_pbh634.v_datamart_address.home_country_desc,
rpt_pbh634.v_datamart_address.business_city,
rpt_pbh634.v_datamart_address.business_state,
rpt_pbh634.v_datamart_address.business_country_desc,
rpt_pbh634.v_datamart_address.business_job_title,
rpt_pbh634.v_datamart_address.business_company_name
from rpt_pbh634.v_datamart_address)


select distinct deg.ID_NUMBER,
       deg.REPORT_NAME,
       deg.RECORD_STATUS_CODE,
       deg.PROGRAM_GROUP,
       deg.PROGRAM,
       deg.FIRST_KSM_YEAR,
       nationality.citizen_cntry_code1 as citzenship_1,
       nationality.citizen_cntry_code2 as citzenship_2,
       KSM_email.email_address as preferred_email_address,
       ksm_home_email.home_email as home_emails,
       KSM_Spec.NO_EMAIL_IND,
       pref_address.short_desc as preferred_address_type_desc,
       pref_address.city as preferred_address_city,
       pref_address.state_code as preferred_state,
       pref_address.country as preferred_country,
       ksm_address.home_city,
       ksm_address.home_state,
       ksm_address.home_country_desc,
       ksm_address.business_job_title,
       ksm_address.business_company_name,
       ksm_address.business_city as business_address_city,
       ksm_address.business_state as business_address_state,
       ksm_address.business_country_desc as business_address_country
from rpt_pbh634.v_entity_ksm_degrees deg
left join pref_address on pref_address.id_number = deg.id_number
left join KSM_Email on KSM_Email.id_number = deg.id_number
left join ksm_home_email on ksm_home_email.id_number = deg.ID_NUMBER
left join KSM_Spec on KSM_Spec.id_number = deg.id_number
left join ksm_address on ksm_address.catracks_id = deg.id_number
left join nationality on nationality.id_number = deg.id_number
where deg.FIRST_KSM_YEAR IN ('2018','2019','2020')
and pref_address.country != 'United States'
and deg.RECORD_STATUS_CODE = 'A'
order by preferred_country asc
