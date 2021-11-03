select awar.id_number,
       rpt_pbh634.v_entity_ksm_households.REPORT_NAME,
       awar.awd_honor_dt,
       TMS_AWD_HONOR.short_desc,
       awar.awd_honor_code,
       awar.comment1
from awards_and_honors awar
left join TMS_AWD_HONOR on TMS_AWD_HONOR.awd_honor_code = awar.awd_honor_code
left join rpt_pbh634.v_entity_ksm_households on rpt_pbh634.v_entity_ksm_households.ID_NUMBER = awar.id_number
where awar.awd_honor_code = 'KSE'
