select deg.ID_NUMBER,
       deg.RECORD_STATUS_CODE,
       deg.DEGREES_VERBOSE,
       deg.DEGREES_CONCAT,
       deg.FIRST_KSM_YEAR,
       deg.PROGRAM,
       deg.PROGRAM_GROUP,
       deg.PROGRAM_GROUP_RANK,
       deg.CLASS_SECTION,
       deg.MAJORS_CONCAT
from rpt_pbh634.v_entity_ksm_degrees deg
Where deg.RECORD_STATUS_CODE IN ('A','L','C')
And deg.PROGRAM_GROUP != 'NONGRD'
