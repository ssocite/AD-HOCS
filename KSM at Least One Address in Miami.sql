with TP AS (select tp.id_number, tp.pref_mail_name, TP.evaluation_rating, TP.Officer_rating
from nu_prs_trp_prospect TP),

KSM_Email AS (select email.id_number,
       email.email_address
From email
Where email.preferred_ind = 'Y'),

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_EMAIL_IND,
       spec.NO_CONTACT,
       spec.GAB,
       spec.TRUSTEE,
       spec.EBFA
From rpt_pbh634.v_entity_special_handling spec),

ent as (select entity.id_number, entity.record_type_code 
from entity),

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
                      GIVE.NGC_LIFETIME,
                      give.NU_MAX_HH_LIFETIME_GIVING
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


c as (Select rpt_pbh634.v_addr_continents.country_code,
             rpt_pbh634.v_addr_continents.country,
             rpt_pbh634.v_addr_continents.continent,
             rpt_pbh634.v_addr_continents.KSM_Continent
from rpt_pbh634.v_addr_continents
where continent = 'South America'
or KSM_Continent = 'Latin_America'),



ksm_house as (Select DISTINCT
         a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc AS Address_Status
      ,  tms_address_type.short_desc AS Address_Type
      ,  a.city
      ,  a.state_code
      ,  a.country_code
      ,  a.start_dt
      FROM address a
      Inner Join c on c.country_code = a.country_code
      LEFT JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      AND addr_g.xsequence = a.xsequence
      WHERE a.addr_status_code = 'A'
      --- Primary Country
      and a.addr_pref_IND = 'Y'),


--- Non Primary Business
Business As(Select DISTINCT
        a.Id_number
      ,  max (a.addr_pref_ind)
      ,  max (tms_addr_status.short_desc) AS Address_Status
      ,  max(tms_address_type.short_desc) AS Address_Type
      ,  max(a.city) as city
      ,  max (a.state_code) as state_code
      ,  max (a.country_code) as country_code
      ,  max (a.start_dt)
      FROM address a
      Inner Join c on c.country_code = a.country_code
      LEFT JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      AND addr_g.xsequence = a.xsequence
      WHERE (a.addr_status_code = 'A'
      and a.addr_pref_IND = 'N'
      AND a.addr_type_code = 'B')
      Group By a.id_number),


Home as (Select DISTINCT
      a.Id_number
      ,  max (a.addr_pref_ind)
      ,  max (tms_addr_status.short_desc) AS Address_Status
      ,  max(tms_address_type.short_desc) AS Address_Type
      ,  max(a.city) as city
      ,  max (a.state_code) as state_code
      ,  max (a.country_code) as country_code
      ,  max (a.start_dt)
      FROM address a
      Inner Join c on c.country_code = a.country_code
      LEFT JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      AND addr_g.xsequence = a.xsequence
      WHERE (a.addr_status_code = 'A'
      and a.addr_pref_IND = 'N'
      AND a.addr_type_code = 'H')
      Group By a.id_number),

Alt_Home As  (Select DISTINCT
      a.Id_number
      ,  max (a.addr_pref_ind)
      ,  max (tms_addr_status.short_desc) AS Address_Status
      ,  max(tms_address_type.short_desc) AS Address_Type
      ,  max(a.city) as city
      ,  max (a.state_code) as state_code
      ,  max (a.country_code) as country_code
      ,  max (a.start_dt)
      FROM address a
      Inner Join c on c.country_code = a.country_code
      LEFT JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER

      AND addr_g.xsequence = a.xsequence
      WHERE (a.addr_pref_IND = 'N'
      and a.addr_status_code = 'A')
      AND (a.addr_type_code = 'AH')
      Group By a.id_number),

Alt_Bus As  (Select DISTINCT
      a.Id_number
      ,  max (a.addr_pref_ind)
      ,  max (tms_addr_status.short_desc) AS Address_Status
      ,  max(tms_address_type.short_desc) AS Address_Type
      ,  max(a.city) as city
      ,  max (a.state_code) as state_code
      ,  max (a.country_code) as country_code
      ,  max (a.start_dt)
      FROM address a
      Inner Join c on c.country_code = a.country_code
      LEFT JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      AND addr_g.xsequence = a.xsequence
      WHERE (a.addr_pref_IND = 'N'
      and a.addr_status_code = 'A'
      AND a.addr_type_code = 'AB')
      Group By a.id_number),

Seasonal as (
        Select DISTINCT
         a.Id_number
      ,  max (a.addr_pref_ind)
      ,  max (tms_addr_status.short_desc) AS Address_Status
      ,  max(tms_address_type.short_desc) AS Address_Type
      ,  max(a.city) as city
      ,  max (a.state_code) as state_code
      ,  max (a.country_code) as country_code
      ,  max (a.start_dt)
      FROM address a
      Inner Join c on c.country_code = a.country_code
      LEFT JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      AND addr_g.xsequence = a.xsequence
      WHERE (a.addr_pref_IND = 'N'
      and a.addr_status_code = 'A'
      AND a.addr_type_code = 'S')
      Group By a.id_number),

fksm_house as (Select DISTINCT
         a.Id_number
      ,  a.addr_pref_ind
      ,  tms_addr_status.short_desc AS Address_Status
      ,  tms_address_type.short_desc AS Address_Type
      , a.city
      ,  a.state_code
      FROM address a
      LEFT JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      AND addr_g.xsequence = a.xsequence
      WHERE addr_g.geo_code = 'T1FL'
      and a.addr_status_code = 'A'
      --- Primary Country
      and a.addr_pref_IND = 'Y'),


--- Non Primary Business
fBusiness As(Select DISTINCT
         a.Id_number
      ,  a.city
      ,  a.state_code
      FROM address a
      LEFT JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      AND addr_g.xsequence = a.xsequence
      WHERE addr_g.geo_code = 'T1FL'
      and (a.addr_status_code = 'A'
      and a.addr_pref_IND = 'N'
      AND a.addr_type_code = 'B')),


fHome as (Select DISTINCT
         a.Id_number
      ,  a.city
      ,  a.state_code
      FROM address a
      LEFT JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      AND addr_g.xsequence = a.xsequence
      WHERE addr_g.geo_code = 'T1FL'
      and (a.addr_status_code = 'A'
      and a.addr_pref_IND = 'N'
      AND a.addr_type_code = 'H')),

fAlt_Home As  (Select DISTINCT
         a.Id_number
      ,  a.city
      ,  a.state_code
      FROM address a
      LEFT JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      AND addr_g.xsequence = a.xsequence
      WHERE (a.addr_pref_IND = 'N'
      and a.addr_status_code = 'A')
      AND (a.addr_type_code = 'AH'
      AND addr_g.geo_code = 'T1FL')),

fAlt_Bus As  (Select DISTINCT
      a.Id_number
      ,  a.city
      ,  a.state_code
      FROM address a
      LEFT JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      AND addr_g.xsequence = a.xsequence
      WHERE (a.addr_pref_IND = 'N'
      and a.addr_status_code = 'A'
      AND a.addr_type_code = 'AB'
      AND addr_g.geo_code = 'T1FL')),

fSeasonal as (
        Select DISTINCT
       a.Id_number
      ,  a.city
      ,  a.state_code
      FROM address a
      LEFT JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN address_geo addr_g ON addr_g.id_number = A.ID_NUMBER
      AND addr_g.xsequence = a.xsequence
      WHERE (a.addr_pref_IND = 'N'
      and a.addr_status_code = 'A'
      AND a.addr_type_code = 'S'
      AND addr_g.geo_code = 'T1FL')),

assignment as (select assign.id_number,
       assign.prospect_manager,
       assign.lgos,
       assign.managers,
       assign.curr_ksm_manager
from rpt_pbh634.v_assignment_summary assign),

prospect as (Select p.ID_NUMBER
From rpt_pbh634.v_ksm_prospect_pool p
Where p.degrees_concat Is Null)

SELECT DISTINCT
   E.ID_NUMBER
  ,E.report_name
  ,ent.record_type_code
  ,E.RECORD_STATUS_CODE
  ,E.INSTITUTIONAL_SUFFIX
  , E.FIRST_KSM_YEAR
  , E.PROGRAM
  , E.PROGRAM_GROUP
  ,employ.job_title
  ,employ.employer_name
  ,employ.fld_of_work
  ,KSM_Spec.NO_CONTACT
  ,KSM_Spec.NO_EMAIL_IND
  ,KSM_spec.GAB
  ,KSM_spec.TRUSTEE
  ,KSM_spec.EBFA
  ,ksm_house.Address_Type as primary_address_type
  ,ksm_house.CITY as primary_city
  ,ksm_house.STATE_Code as primary_state
  , ksm_house.country_Code as primary_country
  , home.city as non_preferred_home_city
  , home.state_code as non_preferred_home_state
  , home.country_code as primary_country
  , Business.city as non_preferred_business_city
  , Business.state_code as non_preferred_business_state
  , Business.country_code as non_preferred_business_country
  , Alt_Home.city as alt_home_city
  , Alt_Home.state_code as alt_home_state
  , Alt_Home.country_code as alt_home_country
  , Alt_Bus.city as alt_bus_city
  , Alt_Bus.state_code as alt_bus_state
  , Alt_Bus.country_code as alt_bus_country
  , Seasonal.city as seasonal_city
  , Seasonal.state_code as seasonal_state
  , Seasonal.country_code as seasonal_country_state
  , ksm_give.NGC_LIFETIME as ksm_NGC_lifetime
  , ksm_give.NU_MAX_HH_LIFETIME_GIVING
  , ksm_give.LAST_GIFT_TYPE as ksm_last_gift_type
  , ksm_give.LAST_GIFT_TX_NUMBER as ksm_last_gift_tx
  , ksm_give.LAST_GIFT_DATE as ksm_last_gift_date
  , ksm_give.LAST_GIFT_ALLOC_CODE as ksm_last_gift_allocation_code
  , ksm_give.LAST_GIFT_ALLOC as ksm_last_gift_allocation
  , assignment.prospect_manager
  , assignment.lgos
  , assignment.managers
  , assignment.curr_ksm_manager
  , TP.evaluation_rating
  , TP.Officer_rating

FROM rpt_pbh634.v_entity_ksm_households E
LEFT JOIN ksm_house on ksm_house.id_number = e.id_number
LEFT JOIN KSM_Spec ON KSM_Spec.id_number = e.id_number
LEFT JOIN ksm_give ON ksm_give.id_number = e.id_number
LEFT JOIN employ ON employ.id_number = e.id_number
LEFT JOIN KSM_Email ON KSM_Email.id_number = e.id_number
LEFT JOIN assignment ON assignment.id_number = e.id_number
LEFT JOIN Business ON Business.id_number = e.id_number
LEFT JOIN Alt_Home ON Alt_Home.id_number = e.id_number
LEFT JOIN Alt_Bus ON Alt_Bus.id_number = e.id_number
LEFT JOIN Seasonal ON Seasonal.id_number = e.id_number
LEFT JOIN TP ON TP.id_number = e.id_number
Left Join home on home.id_number = e.id_number
Left Join prospect on prospect.id_number = e.id_number
Left Join fhome on fhome.id_number = e.id_number
LEFT JOIN fksm_house on fksm_house.id_number = e.id_number
LEFT JOIN fBusiness ON fBusiness.id_number = e.id_number
LEFT JOIN fAlt_Home ON fAlt_Home.id_number = e.id_number
LEFT JOIN fAlt_Bus ON fAlt_Bus.id_number = e.id_number
LEFT JOIN fSeasonal ON fSeasonal.id_number = e.id_number
Left Join ent on ent.id_number = e.id_number

---- We want to pull anyone in Central America, but we want to exclude those from Sara's two previous list
--- So exclude KSM ppl with Florida Geocode OR
--- Exclude those with EMBA-FL program


WHERE
--- Anyone with Address in Central America
(ksm_house.id_number is not null
or Business.id_number is not null
or Alt_Home.id_number is not null
or Alt_Bus.id_number is not null
or Seasonal.id_number is not null
or home.id_number is not null)

--- Anyone that is KSM alumni or KSM Prospect, BUT Exlcude Florida EMBA

and (e.PROGRAM != 'EMP-FL'
and e.program_group != 'EXECED'
or prospect.id_number is not null)

--- Exlcude Those in Florida Geocode
--- Find those in the Florida Geocode and then have a Where clause of NULL
and

(fksm_house.id_number is null
and fBusiness.id_number is null
and fAlt_Home.id_number is null
and fAlt_Bus.id_number is null
and fSeasonal.id_number is null
and fhome.id_number is null)

--- Exclude Special Handling codes: No Email and No Contact

and (KSM_Spec.NO_CONTACT is null
and KSM_Spec.NO_EMAIL_IND is null)

--- Want Persons
and E.PERSON_OR_ORG = 'P'
Order by E.REPORT_NAME ASC
