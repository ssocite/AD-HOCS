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

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_EMAIL_IND,
       spec.NO_CONTACT
From rpt_pbh634.v_entity_special_handling spec),

ksm_give as (select give.ID_NUMBER,
                      give.HOUSEHOLD_ID,
                      give.NU_MAX_HH_LIFETIME_GIVING,
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

--- Primary Address

p as (Select DISTINCT
         a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc AS Address_Status
      ,  tms_address_type.short_desc AS Address_Type
      , a.city as preferred_city
      , a.country_code
      , tms_country.short_desc as preferred_country
      , a.addr_type_code
      FROM address a
      INNER JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      WHERE a.addr_status_code = 'I'
      and a.addr_pref_IND = 'Y'
      ---- Armenia code
      AND A.COUNTRY_CODE = 'ARM'),

--- Home Non Preferred

Home As(Select DISTINCT
         a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc AS Address_Status
      ,  tms_address_type.short_desc AS Address_Type
      , Listagg (a.city, ';  ') Within Group (Order By a.city) As home_city
      ,  a.state_code
      , tms_country.short_desc as home_country
      FROM address a
      INNER JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      WHERE a.addr_status_code = 'I'
      and a.addr_pref_IND = 'N'
      ---- PAST HOME
      AND a.addr_type_code = 'P'
      ---- Armenia code
      AND A.COUNTRY_CODE = 'ARM'
     GROUP BY          a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc
      ,  tms_address_type.short_desc
      ,  a.state_code
      ,  tms_country.short_desc ),

--- Business Non Preferred

Business As(Select DISTINCT
         a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc AS Address_Status
      ,  tms_address_type.short_desc AS Address_Type
      , Listagg (a.city, ';  ') Within Group (Order By a.city) As city
      ,  a.state_code
      , tms_country.short_desc as business_country
      FROM address a
      INNER JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      WHERE a.addr_status_code = 'I'
      and a.addr_pref_IND = 'N'
      --- Past Business
      AND a.addr_type_code = 'Q'
      ---- Armenia code
      AND A.COUNTRY_CODE = 'ARM'
     GROUP BY          a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc
      ,  tms_address_type.short_desc
      ,  a.state_code
      ,  tms_country.short_desc ),

---- Just Alternative


--- Only Past Alternative in CATRACKS!

Alt As  (Select DISTINCT
         a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc AS Address_Status
      ,  tms_address_type.short_desc AS Address_Type
      ,  Listagg (a.city, ';  ') Within Group (Order By a.city) As city
      ,  a.state_code
      , tms_country.short_desc as alt_country
      FROM address a
      INNER JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      WHERE a.addr_pref_IND = 'N'
      and a.addr_status_code = 'I'
      AND a.addr_type_code = 'R'
        ---- Armenia code
      AND A.COUNTRY_CODE = 'ARM'
     GROUP BY          a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc
      ,  tms_address_type.short_desc
      ,  a.state_code
      , tms_country.short_desc),

Seasonal as (
        Select DISTINCT
         a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc AS Address_Status
      ,  tms_address_type.short_desc AS Address_Type
      , Listagg (a.city, ';  ') Within Group (Order By a.city) As city
      ,  a.state_code
      , tms_country.short_desc as seasonal_country
      FROM address a
      INNER JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
       LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      WHERE a.addr_pref_IND = 'N'
      and a.addr_status_code = 'I'
      AND a.addr_type_code = 'T'
        ---- Armenia code
      AND A.COUNTRY_CODE = 'ARM'
        GROUP BY          a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc
      ,  tms_address_type.short_desc
      ,  a.state_code
      ,  tms_country.short_desc),

nu_lifetime as (select NU_PRS_TRP_PROSPECT.ID_NUMBER, NU_PRS_TRP_PROSPECT.GIVING_TOTAL
from NU_PRS_TRP_PROSPECT),

assignment as (select assign.id_number,
       assign.prospect_manager,
       assign.lgos,
       assign.managers,
       assign.curr_ksm_manager
from rpt_pbh634.v_assignment_summary assign)

SELECT DISTINCT
   E.ID_NUMBER
   ,E.FIRST_NAME AS FIRST_NAME_1
  ,E.MIDDLE_NAME AS MIDDLE_NAME_1
  ,E.LAST_NAME AS LAST_NAME_1
  ,E.INSTITUTIONAL_SUFFIX --- To get NU Degree Info too
  , E.RECORD_TYPE_CODE
  ,E.RECORD_STATUS_CODE
  ,E.GENDER_CODE
  ,p.address_type as preferred_address_type
  ,p.preferred_city as past_preferred_city
  ,p.preferred_country as past_preferred_country
  , home.home_city as past_home_non_pref_city
  , home.home_country as past_home_non_pref_country
  , Business.city as past_business_non_pref_city
  , Business.business_country as past_business_non_pref_country
  , Alt.city as past_alt_city
  , Alt.alt_country as past_alt_country
   , Seasonal.city as past_seasonal_city
  , Seasonal.seasonal_country as past_seasonal_country
  ,KD.CLASS_SECTION
  ,KD.PROGRAM AS DEGREE_PROGRAM
  ,KD.PROGRAM_GROUP
  ,KD.FIRST_KSM_YEAR
  ,employ.job_title
  ,employ.employer_name
  ,employ.fld_of_work
  ,KSM_Spec.NO_CONTACT
  ,KSM_Spec.NO_EMAIL_IND
  , ksm_give.NGC_LIFETIME as ksm_NGC_lifetime
  , ksm_give.NU_MAX_HH_LIFETIME_GIVING
  , ksm_give.LAST_GIFT_TX_NUMBER as ksm_last_gift_tx
  , ksm_give.LAST_GIFT_DATE as ksm_last_gift_date
  , ksm_give.LAST_GIFT_TYPE as ksm_last_gift_type
  , ksm_give.LAST_GIFT_ALLOC_CODE as ksm_last_gift_allocation_code
  , ksm_give.LAST_GIFT_ALLOC as ksm_last_gift_allocation
  , nu_lifetime.GIVING_TOTAL as nu_lifetime
  , assignment.prospect_manager
  , assignment.lgos
  , assignment.managers
  , assignment.curr_ksm_manager
FROM ENTITY E
LEFT JOIN KSM_DEGREES KD ON KD.ID_NUMBER = E.ID_NUMBER
LEFT JOIN KSM_Spec ON KSM_Spec.id_number = e.id_number
LEFT JOIN ksm_give ON ksm_give.id_number = e.id_number
LEFT JOIN employ ON employ.id_number = e.id_number
LEFT JOIN assignment ON assignment.id_number = e.id_number
LEFT JOIN nu_lifetime ON nu_lifetime.id_number = e.id_number
Left Join p on p.id_number = e.id_number
LEFT JOIN Business ON Business.id_number = e.id_number
Left Join home on home.id_number = e.id_number
LEFT JOIN Alt ON Alt.id_number = e.id_number
LEFT JOIN Seasonal ON Seasonal.id_number = e.id_number
WHERE E.RECORD_STATUS_CODE IN ('A','L')
AND (p.id_number is not null
or home.id_number is not null
or Business.id_number is not null
or Alt.id_number is not null
or Seasonal.id_number is not null)
Order by E.LAST_NAME ASC
