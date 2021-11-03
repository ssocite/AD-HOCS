With C AS (Select comm.id_number,
       comm.committee_code,
       comm.committee_status_code,
       TMS_COMMITTEE_ROLE.short_desc as role_type,
       TMS_COMMITTEE_TABLE.short_desc as committee
From committee comm
Left Join TMS_COMMITTEE_TABLE ON TMS_COMMITTEE_TABLE.committee_code = comm.committee_code
Left Join TMS_COMMITTEE_ROLE ON TMS_COMMITTEE_ROLE.committee_role_code = comm.committee_role_code
Where comm.committee_code IN ('KACBL','KACHB')
And comm.committee_status_code = 'C')


Select house.ID_NUMBER,
house.RECORD_STATUS_CODE,
house.REPORT_NAME,
house.PROGRAM,
house.FIRST_KSM_YEAR,
c.committee,
c.role_type
From rpt_pbh634.v_entity_ksm_households house
inner Join C ON C.id_number = house.id_number
order by c.committee ASC
