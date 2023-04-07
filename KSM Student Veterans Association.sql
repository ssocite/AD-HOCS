with veterans as (select distinct stact.id_number,
stact.student_activity_code
  FROM  student_activity stact
 WHERE  stact.student_activity_code = 'KVA'),

KSM_Spec AS (Select spec.ID_NUMBER,
spec.NO_CONTACT,
spec.NO_EMAIL_IND,
spec.GAB,
spec.TRUSTEE,
       spec.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling spec
where spec.NO_CONTACT is null
AND spec.NO_EMAIL_IND is null)

select deg.ID_NUMBER,
       entity.first_name,
       entity.last_name,
       veterans.student_activity_code as ksm_vet_association,
       deg.RECORD_STATUS_CODE,
       deg.FIRST_KSM_YEAR,
       deg.PROGRAM,
       deg.PROGRAM_GROUP,
       KSM_Spec.NO_CONTACT,
       KSM_Spec.NO_EMAIL_IND

from rpt_pbh634.v_entity_ksm_degrees deg
inner join veterans on veterans.id_number = deg.ID_NUMBER
left join KSM_Spec on KSM_Spec.id_number = deg.ID_NUMBER
left join entity on entity.id_number = deg.id_number
where deg.FIRST_KSM_YEAR IN ('2010','2011','2012','2013','2014','2015','2016',
'2017','2018','2019','2020','2021')
and deg.PROGRAM_GROUP = 'FT'
order by entity.last_name ASC
