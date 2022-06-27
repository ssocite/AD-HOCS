--- EMBA 100-123
--- Exclude No Contact/No Email/GAB/ Trustee

With KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_CONTACT,
       spec.NO_EMAIL_IND,
       spec.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling spec),

Spec AS (Select s.ID_NUMBER,
       s.GAB,
       s.TRUSTEE,
       s.NO_CONTACT,
       s.NO_SOLICIT,
       s.NO_PHONE_IND,
       s.NO_EMAIL_IND,
       s.NO_MAIL_IND,
       s.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling s),

kasia as (Select asia.id_number,
       asia.short_desc
       FROM TABLE(rpt_pbh634.ksm_pkg.tbl_committee_asia) asia)

select distinct entity.id_number,
       deg.RECORD_STATUS_CODE,
       deg.REPORT_NAME,
       deg.PROGRAM,
       deg.DEGREES_VERBOSE,
       deg.FIRST_KSM_YEAR,
       deg.class_section,
       Spec.NO_CONTACT,
       Spec.NO_EMAIL_IND,
       Spec.GAB,
       Spec.Trustee,
       kasia.short_desc as asia_exec_ind
from rpt_pbh634.v_entity_ksm_degrees deg
left join Spec on Spec.id_number = deg.ID_NUMBER
left join entity on entity.id_number = deg.id_number
left join kasia on kasia.id_number = deg.ID_NUMBER
where deg.PROGRAM_GROUP = 'EMP'
and deg.RECORD_STATUS_CODE IN ('A','L')
and (Spec.NO_CONTACT is null
and Spec.NO_EMAIL_IND is null
and spec.GAB is null
and spec.TRUSTEE is null
and spec.NO_CONTACT is null
and spec.NO_EMAIL_IND is null)
and kasia.id_number is null
and (deg.class_section Like '%100%'
or deg.class_section Like '%101%'
or deg.class_section Like '%102%'
or deg.class_section Like '%103%'
or deg.class_section Like '%104%'
or deg.class_section Like '%105%'
or deg.class_section  Like '%106%'
or deg.class_section  Like '%107%'
or deg.class_section  Like '%108%'
or deg.class_section  Like '%109%'
or deg.class_section  Like '%110%'
or deg.class_section  Like '%111%'
or deg.class_section  Like '%112%'
or deg.class_section  Like '%113%'
or deg.class_section  Like '%114%'
or deg.class_section  Like '%115%'
or deg.class_section  Like '%116%'
or deg.class_section  Like '%117%'
or deg.class_section  Like '%118%'
or deg.class_section  Like '%119%'
or deg.class_section  Like '%120%'
or deg.class_section  Like '%121%'
or deg.class_section  Like '%122%'
or deg.class_section  Like '%123%')
and deg.PROGRAM_GROUP = 'EMP'

Order by Deg.Class_section ASC
