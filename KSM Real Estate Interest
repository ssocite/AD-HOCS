With KSM_restate AS (select interest.id_number, interest.interest_code, tms_interest.short_desc
from interest
left join tms_interest on tms_interest.interest_code = interest.interest_code
where interest.interest_code in ('LRE','L20'))

Select Distinct market.id_number,
                              market.REPORT_NAME,
                              market.RECORD_STATUS_CODE,
                              market.FIRST_KSM_YEAR,
                              market.PROGRAM,
                              market.PROGRAM_GROUP,
                              market.Gender_Code,
                              KSM_restate.short_desc AS Interest,
                              market.fld_of_work_code,
                              market.fld_of_work,
                              market.employer_name,
                              market.job_title,
                              market.HOUSEHOLD_CITY,
                              market.HOUSEHOLD_STATE,
                              market.HOUSEHOLD_ZIP,
                              market.HOUSEHOLD_GEO_CODES

From vt_alumni_market_sheet market
Inner Join KSM_restate On KSM_restate.id_number = market.id_number
Order by market.REPORT_NAME ASC
