With KSM_Email AS (select email.id_number,
       email.email_address,
       email.preferred_ind,
       email.forwards_to_email_address
From email
Where email.preferred_ind = 'Y'),

class_sec as (SELECT *
  FROM  degrees deg
 WHERE (UPPER(deg.class_section) = '116'
    OR  UPPER(deg.class_section) = '117'
    OR  UPPER(deg.class_section) = '118'
    OR  UPPER(deg.class_section) = '119')),

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_CONTACT,
       spec.NO_EMAIL_IND,
       spec.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling spec),

campus as (select distinct degrees.id_number, degrees.campus_code, TMS_CAMPUS.short_desc
from degrees
left join TMS_CAMPUS on TMS_CAMPUS.campus_code = degrees.campus_code
where degrees.division_code = 'EMP'
and degrees.school_code = 'KSM'
and degrees.non_grad_code = ' '
and degrees.campus_code IN ('MIA','EV'))


select deg.ID_NUMBER,
       deg.REPORT_NAME,
       deg.RECORD_STATUS_CODE,
       deg.PROGRAM,
       deg.PROGRAM_GROUP,
       campus.short_desc as campus,
       deg.DEGREES_VERBOSE,
       deg.FIRST_KSM_YEAR,
       deg.CLASS_SECTION,
       KSM_Email.email_address,
       KSM_Spec.NO_CONTACT,
       KSM_Spec.NO_EMAIL_IND
from rpt_pbh634.v_entity_ksm_degrees deg
left join KSM_Email on KSM_Email.id_number = deg.ID_NUMBER
left join KSM_Spec on KSM_Spec.id_number = deg.ID_NUMBER
inner join campus on campus.id_number = deg.id_number
inner join class_sec on class_sec.id_number = deg.id_number
where deg.PROGRAM_GROUP = 'EMP'
and deg.RECORD_STATUS_CODE IN ('A','L')
and deg.FIRST_KSM_YEAR = '2020'
Order by deg.CLASS_SECTION ASC
