select deg.ID_NUMBER,
       deg.RECORD_STATUS_CODE,
       deg.FIRST_KSM_YEAR,
       deg.PROGRAM,
       deg.PROGRAM_GROUP,
       deg.CLASS_SECTION
from rpt_pbh634.v_entity_ksm_degrees deg
Where deg.PROGRAM_GROUP = 'EMP'
and deg.RECORD_STATUS_CODE in ('A','C','L')
