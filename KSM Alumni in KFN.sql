With KSM_KFN AS (Select comm.id_number,
       comm.committee_code,
       comm.committee_status_code,
       comm.start_dt
From committee comm
Where comm.committee_code IN ('KFN')
And comm.committee_status_code = 'C')

Select house.ID_NUMBER,
       house.REPORT_NAME,
       KSM_KFN.committee_code,
       KSM_KFN.committee_status_code,
       KSM_KFN.start_dt,
       market.RECORD_STATUS_CODE,
       market.FIRST_KSM_YEAR,
       market.PROGRAM,
       market.PROGRAM_GROUP,
       market.Gender_Code,
       market.fld_of_work_code,
       market.fld_of_work,
       market.employer_name,
       market.job_title,
       market.HOUSEHOLD_CITY,
       market.HOUSEHOLD_STATE,
       market.HOUSEHOLD_ZIP,
       market.HOUSEHOLD_GEO_CODES,
       market.HOUSEHOLD_COUNTRY,
       market.HOUSEHOLD_CONTINENT,
       market.prospect_manager_id,
       market.prospect_manager,
       market.mgo_pr_score,
       market.mgo_pr_model,
       market.assignment_id_number,
       market.Leadership_Giving_Officer
From rpt_pbh634.v_entity_ksm_households house
left join vt_alumni_market_sheet market on market.id_number = house.ID_NUMBER
inner Join KSM_KFN ON KSM_KFN.id_number = house.id_number
Order by house.REPORT_NAME ASC
