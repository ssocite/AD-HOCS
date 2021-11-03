select 
household_id,
gth.id_number,
gth.report_name,
min (date_of_record) As minimum_dor 
From rpt_pbh634.v_ksm_giving_trans_hh gth
 Where
  -- Not counting matching gifts
  gth.tx_gypm_ind <> 'M'
  -- Gifts Over $0 
  and gth.HH_RECOGNITION_CREDIT > 0
  Group By
  household_id
  , gth.id_number
  , gth.report_name
