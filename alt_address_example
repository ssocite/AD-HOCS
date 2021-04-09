WITH KSM_DEGREES AS (
 SELECT
   KD.ID_NUMBER
   ,KD.PROGRAM
   ,KD.PROGRAM_GROUP
   ,KD.CLASS_SECTION
   ,KD.FIRST_KSM_YEAR
 FROM RPT_PBH634.V_ENTITY_KSM_DEGREES KD),

TP AS (select tp.id_number, tp.pref_mail_name, TP.evaluation_rating, TP.Officer_rating
from nu_prs_trp_prospect TP),

KSM_Email AS (select email.id_number,
       email.email_address
From email
Where email.preferred_ind = 'Y'),

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_EMAIL_IND,
       spec.NO_CONTACT
From rpt_pbh634.v_entity_special_handling spec),

ksm_give as (select give.ID_NUMBER,
                      give.HOUSEHOLD_ID,
                      give.NGC_CFY,
                      give.NGC_PFY1,
                      give.NGC_PFY2,
                      give.NGC_PFY3,
                      give.NGC_PFY4,
                      give.NGC_PFY5,
                      give.LAST_GIFT_TX_NUMBER,
                      give.LAST_GIFT_DATE,
                      give.LAST_GIFT_TYPE,
                      give.LAST_GIFT_ALLOC_CODE,
                      give.LAST_GIFT_ALLOC,
                      GIVE.NGC_LIFETIME
from rpt_pbh634.v_ksm_giving_summary give),

employ as (
  Select id_number
  , job_title
  , employment.fld_of_work_code
  , fow.short_desc As fld_of_work
  , employer_name1,
    -- If there's an employer ID filled in, use the entity name
    Case
      When employer_id_number Is Not Null And employer_id_number != ' ' Then (
        Select pref_mail_name
        From entity
        Where id_number = employer_id_number)
      -- Otherwise use the write-in field
      Else trim(employer_name1 || ' ' || employer_name2)
    End As employer_name
  From employment
  Left Join tms_fld_of_work fow
       On fow.fld_of_work_code = employment.fld_of_work_code
  Where employment.primary_emp_ind = 'Y'),


ksm_house as (select house.ID_NUMBER, house.HOUSEHOLD_GEO_PRIMARY_DESC, HOUSE.HOUSEHOLD_CITY, HOUSE.HOUSEHOLD_STATE
from rpt_pbh634.v_entity_ksm_households house
where house.HOUSEHOLD_GEO_PRIMARY_DESC != 'Florida'),


Business As(Select DISTINCT
         a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc AS Address_Status
      ,  tms_address_type.short_desc AS Address_Type
      , Listagg (a.city, ';  ') Within Group (Order By a.city) As city
      ,  a.state_code
      FROM address a
      INNER JOIN rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = a.id_number
      INNER JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      WHERE addr_g.geo_code = 'C040'
      and a.addr_status_code = 'A'
      and a.addr_pref_IND = 'N'
      AND a.addr_type_code = 'B'
      AND A.STATE_CODE = 'FL'
     GROUP BY          a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc
      ,  tms_address_type.short_desc
      ,  a.state_code ),

Alt_Home As  (Select DISTINCT
         a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc AS Address_Status
      ,  tms_address_type.short_desc AS Address_Type
      , Listagg (a.city, ';  ') Within Group (Order By a.city) As city
      ,  a.state_code
      FROM address a
      INNER JOIN rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = a.id_number
      INNER JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      WHERE a.addr_pref_IND = 'N'
      and a.addr_status_code = 'A'
      AND a.addr_type_code = 'AH'
      AND addr_g.geo_code = 'C040'
   AND A.STATE_CODE = 'FL'
        GROUP BY          a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc
      ,  tms_address_type.short_desc
      ,  a.state_code),

Alt_Bus As  (Select DISTINCT
         a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc AS Address_Status
      ,  tms_address_type.short_desc AS Address_Type
      ,  Listagg (a.city, ';  ') Within Group (Order By a.city) As city
      ,  a.state_code
      FROM address a
      INNER JOIN rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = a.id_number
      INNER JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      WHERE a.addr_pref_IND = 'N'
      and a.addr_status_code = 'A'
      AND a.addr_type_code = 'AB'
      AND addr_g.geo_code = 'C040'
   AND A.STATE_CODE = 'FL'
     GROUP BY          a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc
      ,  tms_address_type.short_desc
      ,  a.state_code),

Seasonal as (
        Select DISTINCT
         a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc AS Address_Status
      ,  tms_address_type.short_desc AS Address_Type
      , Listagg (a.city, ';  ') Within Group (Order By a.city) As city
      ,  a.state_code
      FROM address a
      INNER JOIN rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = a.id_number
      INNER JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
       LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      WHERE a.addr_pref_IND = 'N'
      and a.addr_status_code = 'A'
      AND a.addr_type_code = 'S'
      AND addr_g.geo_code = 'C040'
   AND A.STATE_CODE = 'FL'
        GROUP BY          a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc
      ,  tms_address_type.short_desc
      ,  a.state_code),

nu_lifetime as (select NU_PRS_TRP_PROSPECT.ID_NUMBER, NU_PRS_TRP_PROSPECT.GIVING_TOTAL
from NU_PRS_TRP_PROSPECT),

ksm_model as (select models.id_number,
       models.segment_year,
       models.segment_month,
       models.id_code,
       models.id_segment,
       models.id_score,
       models.pr_code,
       models.pr_segment,
       models.pr_score,
       models.est_probability
from rpt_pbh634.v_ksm_model_mg models),

assignment as (select assign.id_number,
       assign.prospect_manager,
       assign.lgos,
       assign.managers,
       assign.curr_ksm_manager
from rpt_pbh634.v_assignment_summary assign)

SELECT DISTINCT
   E.ID_NUMBER
  ,E.RECORD_STATUS_CODE
  ,E.GENDER_CODE
  ,E.FIRST_NAME AS FIRST_NAME_1
  ,E.MIDDLE_NAME AS MIDDLE_NAME_1
  ,E.LAST_NAME AS LAST_NAME_1
  ,ksm_house.HOUSEHOLD_GEO_PRIMARY_DESC
  ,ksm_house.HOUSEHOLD_CITY
  ,ksm_house.HOUSEHOLD_STATE
  , Business.city as business_city
  , Business.state_code as business_state_code
  , Alt_Home.city as alt_home_city
  , Alt_Home.state_code as alt_home_state
  , Alt_Bus.city as alt_bus_city
  , Alt_Bus.state_code as alt_bus_state
   , Seasonal.city as seasonal_city
  , Seasonal.state_code as seasonal_state
  ,KD.CLASS_SECTION
  ,KD.PROGRAM AS DEGREE_PROGRAM
  ,KD.PROGRAM_GROUP
  ,KD.FIRST_KSM_YEAR
  ,employ.job_title
  ,employ.employer_name
  ,employ.fld_of_work
  ,KSM_Email.Email_Address
  ,KSM_Spec.NO_CONTACT
  ,KSM_Spec.NO_EMAIL_IND
  , ksm_give.NGC_LIFETIME as ksm_NGC_lifetime
  , ksm_give.NGC_CFY as ksm_cfy_giving
  , ksm_give.NGC_PFY1 as ksm_pfy1_giving
  , ksm_give.NGC_PFY2 as ksm_pfy2_giving
  , ksm_give.NGC_PFY3 as ksm_pfy3_giving
  , ksm_give.NGC_PFY4 as ksm_pfy4_giving
  , ksm_give.NGC_PFY5 as ksm_pfy5_giving
  , ksm_give.LAST_GIFT_TX_NUMBER as ksm_last_gift_tx
  , ksm_give.LAST_GIFT_DATE as ksm_last_gift_date
  , ksm_give.LAST_GIFT_TYPE as ksm_last_gift_type
  , ksm_give.LAST_GIFT_ALLOC_CODE as ksm_last_gift_allocation_code
  , ksm_give.LAST_GIFT_ALLOC as ksm_last_gift_allocation
  , nu_lifetime.GIVING_TOTAL as nu_lifetime
  , ksm_model.id_segment
  , ksm_model.id_score
  , ksm_model.pr_segment
  , ksm_model.pr_score
  , assignment.prospect_manager
  , assignment.lgos
  , assignment.managers
  , assignment.curr_ksm_manager
  , TP.evaluation_rating
  , TP.Officer_rating
FROM ENTITY E
INNER JOIN KSM_DEGREES KD ON KD.ID_NUMBER = E.ID_NUMBER
LEFT JOIN KSM_Spec ON KSM_Spec.id_number = e.id_number
LEFT JOIN ksm_give ON ksm_give.id_number = e.id_number
LEFT JOIN employ ON employ.id_number = e.id_number
LEFT JOIN KSM_Email ON KSM_Email.id_number = e.id_number
LEFT JOIN assignment ON assignment.id_number = e.id_number
LEFT JOIN ksm_model ON ksm_model.id_number = e.id_number
LEFT JOIN nu_lifetime ON nu_lifetime.id_number = e.id_number
LEFT JOIN Business ON Business.id_number = e.id_number
LEFT JOIN Alt_Home ON Alt_Home.id_number = e.id_number
LEFT JOIN Alt_Bus ON Alt_Bus.id_number = e.id_number
LEFT JOIN Seasonal ON Seasonal.id_number = e.id_number
LEFT JOIN TP ON TP.id_number = e.id_number
INNER JOIN ksm_house on ksm_house.id_number = e.id_number
WHERE E.RECORD_STATUS_CODE IN ('A','L')
AND (Business.id_number is not null
or Alt_Home.id_number is not null
or Alt_Bus.id_number is not null
or Seasonal.id_number is not null)
AND TP.ID_number is not null
Order by E.LAST_NAME ASC
