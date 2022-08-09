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


--- Preferred Address

pref as (Select DISTINCT
         a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc AS Address_Status
      ,  tms_address_type.short_desc AS Address_Type
      ,  a.city As city
      ,  a.state_code
      ,  a.country_code
      FROM address a
      INNER JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      WHERE a.addr_status_code = 'A'
      and a.addr_pref_IND = 'Y'
      AND A.COUNTRY_CODE = 'THAI'),


Business As(Select DISTINCT
         a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc AS Address_Status
      ,  tms_address_type.short_desc AS Address_Type
      ,  a.city As city
      ,  a.state_code
      ,  a.country_code
      FROM address a
      INNER JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      WHERE a.addr_status_code = 'A'
      and a.addr_pref_IND = 'N'
      AND a.addr_type_code = 'B'
      AND A.COUNTRY_CODE = 'THAI'),

Home  As(Select DISTINCT
         a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc AS Address_Status
      ,  tms_address_type.short_desc AS Address_Type
      ,  a.city As city
      ,  a.state_code
      ,  a.country_code
      FROM address a
      INNER JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      WHERE a.addr_status_code = 'A'
      and a.addr_pref_IND = 'N'
      AND a.addr_type_code = 'H'
      AND A.COUNTRY_CODE = 'THAI'),

Alt_Home As  (Select DISTINCT
         a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc AS Address_Status
      ,  tms_address_type.short_desc AS Address_Type
      ,  a.city As city
      ,  a.state_code
      ,  a.country_code
      FROM address a
      INNER JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      WHERE a.addr_pref_IND = 'N'
      and a.addr_status_code = 'A'
      AND a.addr_type_code = 'AH'
      AND A.COUNTRY_CODE = 'THAI'),

Alt_Bus As  (Select DISTINCT
         a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc AS Address_Status
      ,  tms_address_type.short_desc AS Address_Type
      ,  a.city As city
      ,  a.state_code
      ,  a.country_code
      FROM address a
      INNER JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      WHERE a.addr_pref_IND = 'N'
      and a.addr_status_code = 'A'
      and a.addr_type_code = 'AB'
      AND A.COUNTRY_CODE = 'THAI'),

Seasonal as (
Select DISTINCT
         a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc AS Address_Status
      ,  tms_address_type.short_desc AS Address_Type
      ,  a.city As city
      ,  a.state_code
      ,  a.country_code
      FROM address a
      INNER JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
       LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      WHERE a.addr_pref_IND = 'N'
      and a.addr_status_code = 'A'
      and a.addr_type_code = 'S'
   AND A.COUNTRY_CODE = 'THAI'),

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
  , pref.city as pref_city
  , pref.state_code as pref_state_code
  , pref.country_code as pref_country_code
  , business.city AS BUSINESS_CITY
  , business.state_code AS BUSINESS_STATE
  , business.country_code AS BUSINESS_COUNTRY_CODE
  , Home.city AS HOME_CITY
  , Home.state_code AS HOME_STATE
  , Home.country_code AS HOME_COUNTRY
  , Alt_Home.city as alt_home_city
  , Alt_Home.state_code as alt_home_state
  , Alt_home.country_code as alt_home_country_code
  , Alt_Bus.city as alt_bus_city
  , Alt_Bus.state_code as alt_bus_state
  , Alt_Bus.country_code as alt_bus_country_code
  , Seasonal.city as seasonal_city
  , Seasonal.state_code as seasonal_state
  , Seasonal.country_code as seasonal_country
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
  , assignment.prospect_manager
  , assignment.lgos
  , assignment.managers
  , assignment.curr_ksm_manager
  , TP.evaluation_rating
  , TP.Officer_rating
FROM ENTITY E
INNER JOIN KSM_DEGREES KD ON KD.ID_NUMBER = E.ID_NUMBER
LEFT JOIN KSM_Spec ON KSM_Spec.id_number = e.id_number
LEFT JOIN employ ON employ.id_number = e.id_number
LEFT JOIN KSM_Email ON KSM_Email.id_number = e.id_number
LEFT JOIN assignment ON assignment.id_number = e.id_number
LEFT JOIN Business ON Business.id_number = e.id_number
LEFT JOIN Alt_Home ON Alt_Home.id_number = e.id_number
LEFT JOIN Alt_Bus ON Alt_Bus.id_number = e.id_number
LEFT JOIN Seasonal ON Seasonal.id_number = e.id_number
LEFT JOIN TP ON TP.id_number = e.id_number
LEFT JOIN pref on pref.id_number = e.id_number
LEFT JOIN home on home.id_number = e.id_number
WHERE E.RECORD_STATUS_CODE IN ('A')
AND (Business.id_number is not null
or Alt_Home.id_number is not null
or Alt_Bus.id_number is not null
or Seasonal.id_number is not null
or pref.id_number is not null)
and KD.first_ksm_year IN ('2020','2021')
Order by E.LAST_NAME ASC
