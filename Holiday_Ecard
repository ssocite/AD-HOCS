With KSM_Email AS (select email.id_number,
       email.email_address,
       email.preferred_ind,
       email.forwards_to_email_address
From email
Inner Join rpt_pbh634.v_entity_ksm_degrees de on de.ID_NUMBER = email.id_number
Where email.preferred_ind = 'Y'),

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_EMAIL_IND,
       spec.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling spec),

KSM_Faculty_Staff as (select aff.id_number,
       TMS_AFFIL_CODE.short_desc as affilation_code,
       tms_affiliation_level.short_desc as affilation_level
FROM  affiliation aff
LEFT JOIN TMS_AFFIL_CODE ON TMS_AFFIL_CODE.affil_code = aff.affil_code
Left JOIN tms_affiliation_level ON tms_affiliation_level.affil_level_code = aff.affil_level_code
inner join rpt_pbh634.v_entity_ksm_degrees d on d.ID_NUMBER = aff.id_number
 WHERE  aff.affil_code = 'KM'
   AND (aff.affil_level_code = 'ES'
    OR  aff.affil_level_code = 'EF'))


select deg.ID_NUMBER,
       deg.RECORD_STATUS_CODE,
       case when KSM_Email.email_address is not null then 'yes' else '' end as preferred_email_on_file
from rpt_pbh634.v_entity_ksm_degrees deg
left join KSM_Spec on deg.ID_NUMBER = KSM_Spec.id_number
left join KSM_Email on deg.ID_NUMBER = KSM_Email.id_number
left join KSM_Faculty_Staff on KSM_Faculty_Staff.id_number = deg.ID_NUMBER
where KSM_Email.email_address is not null
and KSM_Spec.NO_EMAIL_IND is null
and deg.RECORD_STATUS_CODE IN ('A','L')
and KSM_Faculty_Staff.id_number is null
