With eth AS (select distinct entity.ID_NUMBER,
entity.ethnic_code,
Tms_Ethnic_Source.short_desc as eth_source,
TMS_RACE.ethnic_code As Eth_Code,
TMS_RACE.short_desc
from entity
Left Join TMS_RACE ON TMS_RACE.ethnic_code = entity.ethnic_code
Left Join Tms_Ethnic_Source ON Tms_Ethnic_Source.ethnic_src_code = entity.ethnic_src_code
where entity.ethnic_code = '2'),

--- Black Management Association as a student
a as (SELECT Distinct
stact.id_number,
stact.student_activity_code,
s.short_desc,
stact.student_particip_code,
stact.start_dt
  FROM  student_activity stact
LEFT JOIN TMS_STUDENT_ACT s on s.student_activity_code = stact.student_activity_code
 WHERE  stact.student_activity_code = 'KSA57'),


spec AS (Select spec.ID_NUMBER,
       spec.NO_CONTACT,
       spec.NO_EMAIL_IND
From rpt_pbh634.v_entity_special_handling spec)

select m.id_number,
       e.first_name,
       e.last_name,
       m.REPORT_NAME,
       m.RECORD_STATUS_CODE,
       m.FIRST_KSM_YEAR,
       m.PROGRAM,
       m.PROGRAM_GROUP,
       m.CLASS_SECTION,
       eth.short_desc as Ethnicity,
       a.short_desc as BMA_Student_IND
from VT_ALUMNI_MARKET_SHEET m
left join entity e on e.id_number = m.id_number
left join eth on eth.id_number = m.id_number
left join a on a.id_number = m.id_number
left join spec on spec.id_number = m.id_number
/*
From Request
Can I please have a list of all FT & EW alumni who identify as Black or who have
participated with BMA as a student*/

where (eth.id_number is not null
or a.id_number is not null)
and (spec.NO_CONTACT is null
and spec.NO_EMAIL_IND is null)
order by e.last_name asc
