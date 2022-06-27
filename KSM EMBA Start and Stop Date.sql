With d as (select distinct degrees.id_number, deg.FIRST_KSM_YEAR, degrees.campus_code, degrees.start_dt, degrees.stop_Dt,
degrees.grad_dt, deg.PROGRAM, deg.PROGRAM_GROUP
from degrees
left join rpt_pbh634.v_entity_ksm_degrees deg on deg.id_number = degrees.id_number
where degrees.division_code = 'EMP'
and degrees.school_code = 'KSM'
-- Any graduate after 07/01/2021 - And today is 6/27/22, so that covers jesseca's request
and degrees.stop_Dt > 20210701
order by stop_dt asc),

ksm_ids As (
  Select ids_base.id_number
    , ids_base.ids_type_code
    , ids_base.other_id
  From rpt_pbh634.v_entity_ksm_degrees deg --- Kellogg Alumni Only
  Left Join ids_base
    On ids_base.id_number = deg.id_number
  Where ids_base.ids_type_code In ('SES') --- SES = EMPLID + KSF = Salesforce ID + NET = NetID + KEX = KSM EXED ID
)

select d.id_number
,i.other_id
,entity.first_name
,entity.last_name
,d.FIRST_KSM_YEAR
,d.program
,d.program_group
,d.start_dt as start_date_program
,d.stop_Dt as stop_date_program
from d
left join ksm_ids i on i.id_number = d.id_number
left join entity on entity.id_number = d.id_number
order by d.stop_dt asc
