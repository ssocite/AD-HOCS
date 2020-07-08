WITH KDS AS (
Select Award.Id_Number,
       AWA.short_desc,
       Award.Awd_Honor_Code
From Awards_And_Honors Award
Left Join TMS_AWD_HONOR AWA on AWA.awd_honor_code = Award.Awd_Honor_Code
Where Award.Awd_Honor_Code = 'KDS'),

Club_Event As (
Select EP_Participant.Id_Number,
       Event.event_id,
       Event.event_name,
       Event.start_dt,
       Event.start_fy_calc,
       Event.ksm_event,
       Event.event_codes_concat
       From rpt_pbh634.v_nu_events Event
       Left Join EP_Participant ON Event.Event_Id = Ep_Participant.Event_Id
       Where Event.ksm_event = 'Y'
       And Event.event_id IN (19343, 16890, 16889, 13537, 21484,11669, 12196, 13966, 14577, 6893, 9765))

Select deg.ID_NUMBER,
deg.REPORT_NAME,
deg.RECORD_STATUS_CODE,
deg.DEGREES_CONCAT,
deg.FIRST_KSM_YEAR,
deg.PROGRAM,
deg.PROGRAM_GROUP,
vt_alumni_market_sheet.job_title,
vt_alumni_market_sheet.employer_name,
vt_alumni_market_sheet.fld_of_work As Industry,
KDS.short_desc,
Club_event.event_name
From rpt_pbh634.v_entity_ksm_degrees deg
Left Join KDS On KDS.id_number = deg.id_number
Left Join Club_Event On Club_Event.id_number = deg.id_number
Left Join vt_alumni_market_sheet on vt_alumni_market_sheet.id_number = deg.ID_NUMBER
Where deg.FIRST_KSM_YEAR Between 2012 AND 2016
And (KDS.Awd_Honor_Code = 'KDS'
or Club_Event.event_id IN (19343, 16890, 16889,  13537, 21484, 11669, 12196, 13966, 14577, 6893, 9765))
