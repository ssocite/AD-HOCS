SELECT DISTINCT intr.id_number,
                house.REPORT_NAME,
                intr.interest_code,
                intr.start_dt,
                intr.comment1
  FROM  interest intr
  left join rpt_pbh634.v_entity_ksm_households house on house.ID_NUMBER = intr.id_number
 WHERE  intr.interest_code = 'E8'
 and intr.comment1 = 'KSM Alumni Exit'
 order by house.REPORT_NAME asc
