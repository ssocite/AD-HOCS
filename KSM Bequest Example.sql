--- Bequests (MAX)
select gt.ID_NUMBER,
       max (gt.REPORT_NAME),
       max (gt.TX_NUMBER),
       max (gt.TRANSACTION_TYPE_CODE),
       max (gt.TRANSACTION_TYPE),
       max (gt.KSM_FLAG),
       max (gt.ALLOC_SHORT_NAME),
       max (gt.DATE_OF_RECORD),
       max (gt.FISCAL_YEAR),
       max (gt.LEGAL_AMOUNT),
       max (gt.CREDIT_AMOUNT),
       max (gt.RECOGNITION_CREDIT)
from rpt_pbh634.v_ksm_giving_trans gt
inner join table (rpt_pbh634.ksm_pkg_tmp.tbl_committee_phs) phs
on phs.id_number = gt.ID_NUMBER
--- Considers LE - Life insurance
where gt.TRANSACTION_TYPE_CODE IN ('BE','LE')
Group by gt.ID_NUMBER
