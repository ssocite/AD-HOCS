select Distinct

rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER,

       rpt_pbh634.v_entity_ksm_degrees.REPORT_NAME,

       rpt_pbh634.v_entity_ksm_degrees.RECORD_STATUS_CODE,

       rpt_pbh634.v_entity_ksm_degrees.DEGREES_VERBOSE,

       rpt_pbh634.v_entity_ksm_degrees.DEGREES_CONCAT,

       rpt_pbh634.v_entity_ksm_degrees.FIRST_KSM_YEAR,

       rpt_pbh634.v_entity_ksm_degrees.PROGRAM,

       rpt_pbh634.v_entity_ksm_degrees.PROGRAM_GROUP,

       rpt_pbh634.v_entity_ksm_degrees.CLASS_SECTION,

       institution.institution_code,

       institution.institution_name,

       institution.city,

       institution.state_code

From rpt_pbh634.v_entity_ksm_degrees

Left Join degrees ON degrees.id_number = rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER


Inner Join institution on institution.institution_code = degrees.institution_code

Where institution.institution_code IN ('41452','41456','41455','41454','41453', '38863', '39425')

Order By rpt_pbh634.v_entity_ksm_degrees.REPORT_NAME ASC
