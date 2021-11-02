select committee.id_number,
       deg.REPORT_NAME,
       deg.DEGREES_CONCAT,
       deg.PROGRAM,
       deg.PROGRAM_GROUP,
       deg.FIRST_KSM_YEAR,
       TMS_COMMITTEE_TABLE.short_desc,
       committee.committee_code,
       committee.start_dt,
       committee.stop_dt,
       committee.committee_status_code,
       committee.date_added,
       committee.date_modified,
       committee.operator_name
from committee
Left Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = committee.id_number
Left Join TMS_COMMITTEE_TABLE on committee.committee_code = TMS_COMMITTEE_TABLE.committee_code
where committee.committee_code = '227'
and committee.committee_status_code = 'C'
Order By deg.FIRST_KSM_YEAR ASC
