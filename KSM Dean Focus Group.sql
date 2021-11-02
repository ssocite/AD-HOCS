WITH REUNION_20_COMMITTEE AS (
  SELECT DISTINCT
   ID_NUMBER
  FROM COMMITTEE
  WHERE COMMITTEE_CODE = '227' AND COMMITTEE_STATUS_CODE = 'F'
  AND START_DT = '20190901'
),

KALC AS (
  SELECT DISTINCT
   ID_NUMBER
  FROM COMMITTEE
  WHERE COMMITTEE_CODE = 'KALC' AND COMMITTEE_STATUS_CODE = 'C'
),

KARG AS (
  SELECT DISTINCT
   ID_NUMBER
  FROM COMMITTEE
  WHERE COMMITTEE_CODE = 'KARG' AND COMMITTEE_STATUS_CODE = 'C'
),

KIC AS (
  SELECT DISTINCT
   ID_NUMBER
  FROM COMMITTEE
  WHERE COMMITTEE_CODE = 'KIC' AND COMMITTEE_STATUS_CODE = 'C'
),

Listag AS (
SELECT DISTINCT
COMMITTEE.ID_NUMBER,
Listagg (TMS_COMMITTEE_TABLE.short_desc, ';  ') Within Group (Order By TMS_COMMITTEE_TABLE.short_desc) As Club_Contact
  FROM COMMITTEE
  Left Join TMS_COMMITTEE_TABLE On TMS_COMMITTEE_TABLE.committee_code = committee.committee_code
  where Committee.Committee_Code IN ('227','KALC','KARG','KIC')
  GROUP BY COMMITTEE.ID_NUMBER
),

Listag_role AS (
SELECT DISTINCT
COMMITTEE.ID_NUMBER,
Listagg (TMS_COMMITTEE_ROLE.short_desc, ';  ') Within Group (Order By TMS_COMMITTEE_ROLE.short_desc) As Club_Contact
  FROM COMMITTEE
  Left Join TMS_COMMITTEE_ROLE On TMS_COMMITTEE_ROLE.committee_role_code = committee.committee_role_code
  where Committee.Committee_Code IN ('227','KALC','KARG','KIC')
  GROUP BY COMMITTEE.ID_NUMBER
)

Select distinct Committee.Id_Number,
       rpt_pbh634.v_entity_ksm_degrees.REPORT_NAME,
       entity.gender_code,
       rpt_pbh634.v_entity_ksm_degrees.RECORD_STATUS_CODE,
       rpt_pbh634.v_entity_ksm_degrees.PROGRAM,
       rpt_pbh634.v_entity_ksm_degrees.PROGRAM_GROUP,
       rpt_pbh634.v_entity_ksm_degrees.FIRST_KSM_YEAR,
       Listag.Club_Contact,
       Listag_role.Club_Contact as role_concat,
       market.fld_of_work,
       market.employer_name,
       market.job_title,
       market.HOUSEHOLD_CITY,
       market.HOUSEHOLD_STATE,
       market.HOUSEHOLD_ZIP,
       market.HOUSEHOLD_COUNTRY,
       market.HOUSEHOLD_CONTINENT
From Committee
Left Join rpt_pbh634.v_entity_ksm_degrees On rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER = Committee.Id_Number
Left Join TMS_COMMITTEE_TABLE On TMS_COMMITTEE_TABLE.committee_code = committee.committee_code
Left Join REUNION_20_COMMITTEE ON REUNION_20_COMMITTEE.ID_NUMBER = Committee.Id_Number
Left Join KALC ON KALC.ID_NUMBER = Committee.Id_Number
Left Join KARG ON KARG.ID_NUMBER = Committee.Id_Number
Left Join KIC ON KIC.ID_NUMBER = Committee.Id_Number
Left Join vt_alumni_market_sheet market on market.id_number = committee.id_number
Left Join Listag on listag.id_number = committee.id_number
Left Join entity on entity.id_number = committee.id_number
Left Join TMS_COMMITTEE_ROLE on TMS_COMMITTEE_ROLE.committee_role_code = committee.committee_role_code
Left Join Listag_role on Listag_role.ID_NUMBER = committee.id_number
WHERE Committee.Committee_Code IN ('227','KALC','KARG','KIC')
and rpt_pbh634.v_entity_ksm_degrees.PROGRAM_GROUP = 'FT'
and rpt_pbh634.v_entity_ksm_degrees.FIRST_KSM_YEAR IN ('2020','2019','2018','2017','2016','2015','2014')
Order By rpt_pbh634.v_entity_ksm_degrees.REPORT_NAME ASC
