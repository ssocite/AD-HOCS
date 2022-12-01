with a as (Select *
From v_all_address),

--- KSM Alumni with Primary Address in US,
---but at least one non pref in SouthEast Asia

US as (Select *
From a
Where primary_country is null
and (lookup_country Like '%Brunei%'
or lookup_country Like '%Cambodia%'
or lookup_country Like '%East Timor%'
or lookup_country Like '%Indonesia%'
or lookup_country Like '%Laos%'
or lookup_country Like '%Malaysia%'
or lookup_country Like '%Myanmar%'
or lookup_country Like '%Philippines%'
or lookup_country Like '%Singapore%'
or lookup_country Like '%Thailand%'
or lookup_country Like '%Vietnam%')),

--- Alumni with Primary address in SE Asia. List is below!

SE as
(Select *
From a
Where (primary_country Like '%Brunei%'
or primary_country Like '%Cambodia%'
or primary_country Like '%East Timor%'
or primary_country Like '%Indonesia%'
or primary_country Like '%Laos%'
or primary_country Like '%Malaysia%'
or primary_country Like '%Myanmar%'
or primary_country Like '%Philippines%'
or primary_country Like '%Singapore%'
or primary_country Like '%Thailand%'
or primary_country Like '%Vietnam%')),


KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_CONTACT,
       spec.NO_EMAIL_IND,
       spec.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling spec)

select entity.id_number,
       entity.record_type_code,
       entity.record_status_code,
       entity.first_name,
       entity.last_name,
       entity.institutional_suffix,
       d.FIRST_KSM_YEAR,
       d.PROGRAM,
       d.PROGRAM_GROUP,
       a.primary_address_type,
       a.primary_city,
       a.primary_geo,
       a.primary_state,
       a.primary_country,
       a.non_preferred_home_type,
       a.non_preferred_home_city,
       a.non_pref_home_geo,
       a.non_preferred_home_state,
       a.non_preferred_home_country,
       a.non_preferred_business_type,
       a.non_preferred_business_geo,
       a.non_preferred_business_city,
       a.non_preferred_business_state,
       a.non_preferred_business_country,
       a.alt_home_type,
       a.alt_home_geo,
       a.alt_home_city,
       a.alt_home_state,
       a.alt_home_country,
       a.alt_bus_type,
       a.alt_business_geo,
       a.alt_bus_city,
       a.alt_bus_state,
       a.alt_bus_country,
       a.seasonal_Type,
       a.SEASONAL_GEO_CODE,
       a.seasonal_city,
       a.seasonal_state,
       a.seasonal_country,
       a.lookup_geo,
       a.lookup_state,
       a.lookup_country
from entity
left join a on a.id_number = entity.id_number
left join SE ON SE.id_number = entity.id_number
left join US ON US.id_number = entity.id_number
left join KSM_Spec on KSM_Spec.id_number = entity.id_number
inner join rpt_pbh634.v_entity_ksm_degrees d on d.id_number = entity.id_number
--- KSM Alumni Primary in SE Asia AND
--- KSM Alumni Primary is USA, with at least 1 active address in SE Asia (non pref)
where (SE.id_number is not null
or US.id_number is not null)
and (KSM_Spec.NO_CONTACT is null
and KSM_Spec.NO_EMAIL_IND is null)
order by primary_country ASC
