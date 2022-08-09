With
-- Employment table subquery
employ As (
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
  Where employment.primary_emp_ind = 'Y'
),

--- Use BG - Business Geo Code

BG as (Select
gc.*
From table(rpt_pbh634.ksm_pkg_tmp.tbl_geo_code_primary) gc
Inner Join address
On address.id_number = gc.id_number
And address.xsequence = gc.xsequence
Where address.addr_type_code = 'B'),

BusinessAddress AS(
      Select
         a.Id_number
      ,  tms_addr_status.short_desc AS Address_Status
      ,  tms_address_type.short_desc AS Address_Type
      ,  a.addr_pref_ind
      ,  a.street1
      ,  a.street2
      ,  a.street3
      ,  a.foreign_cityzip
      ,  a.city
      ,  a.state_code
      ,  a.zipcode
      ,  tms_country.short_desc AS Country
      ,  BG.GEO_CODE_PRIMARY_DESC AS BUSINESS_GEO_CODE
      FROM address a
      INNER JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      INNER JOIN BG
      ON BG.ID_NUMBER = A.ID_NUMBER
      AND BG.xsequence = a.xsequence
      WHERE a.addr_type_code = 'B'
      AND a.addr_status_code IN('A','K')
),


Prospect AS (
Select distinct TP.ID_NUMBER,
       TP.EVALUATION_RATING,
       TP.OFFICER_RATING

From nu_prs_trp_prospect TP),

--- KSM Assignments: LGO, PM, Manager

ksm_assignment as (select distinct assign.id_number,
assign.prospect_manager,
assign.lgos,
assign.managers
from rpt_pbh634.v_assignment_summary assign),

--- KSM Emails (To build email flag in marketsheet)

KSM_Email AS (select email.id_number,
       email.email_address
From email
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = email.id_number
Where email.preferred_ind = 'Y'),

--- KSM Spec (To indicate Special Handling)

Spec AS (Select rpt_pbh634.v_entity_special_handling.ID_NUMBER,
       rpt_pbh634.v_entity_special_handling.GAB,
       rpt_pbh634.v_entity_special_handling.TRUSTEE,
       rpt_pbh634.v_entity_special_handling.NO_CONTACT,
       rpt_pbh634.v_entity_special_handling.NO_SOLICIT,
       rpt_pbh634.v_entity_special_handling.NO_PHONE_IND,
       rpt_pbh634.v_entity_special_handling.NO_EMAIL_IND,
       rpt_pbh634.v_entity_special_handling.NO_MAIL_IND,
       rpt_pbh634.v_entity_special_handling.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling),


APR AS (

--- This will pull all events type coded Reunion, but takes away the Reunion Events that are a sub event of
--- the actual Reunion, so we will have only the Reunion Event Pulled by Year
Select distinct
EP_Participant.Id_Number,
rpt_pbh634.v_nu_events.event_name,
rpt_pbh634.v_nu_events.event_id,
rpt_pbh634.v_nu_events.start_dt,
rpt_pbh634.v_nu_events.start_dt_calc,
rpt_pbh634.v_nu_events.start_fy_calc
From ep_event
Left Join EP_Participant
ON ep_participant.event_id = ep_event.event_id
Inner Join rpt_pbh634.v_nu_events on rpt_pbh634.v_nu_events.event_id = ep_event.event_id
Where ep_event.event_type = '02'
and rpt_pbh634.v_nu_events.kellogg_organizers = 'Y'
and ep_event.event_id not IN ('21637','21121','22657','18819','20926','25896','17739','18982','21264',
'6897','8358')
Order by rpt_pbh634.v_nu_events.event_name DESC
),

recent_reunion AS (--- Subquery to add into the 2021 Reunion Report. This will help user identify an alum's most recent attendance.

Select DISTINCT apr.id_number,
       max (apr.start_dt_calc) keep (dense_rank First Order By apr.start_dt_calc DESC) As Date_Recent_Event,
       max (apr.event_id) keep (dense_rank First Order By apr.start_dt_calc DESC) As Recent_Event_ID,
       max (apr.event_name) keep(dense_rank First Order By apr.start_dt_calc DESC) As Recent_Event_Name
from apr
Group BY apr.id_number
Order By Date_Recent_Event ASC),

birth as (select  entity.id_number,
(substr (birth_dt, 1, 4)) as birth_year,
entity.birth_dt
from entity)

Select Distinct
rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER,

rpt_pbh634.v_entity_ksm_degrees.REPORT_NAME,

p.P_Dean_Salut,

entity.institutional_suffix,

Entity.Gender_Code,

rpt_pbh634.v_entity_ksm_households.SPOUSE_ID_NUMBER,

rpt_pbh634.v_entity_ksm_households.SPOUSE_REPORT_NAME,

rpt_pbh634.v_entity_ksm_degrees.RECORD_STATUS_CODE,

rpt_pbh634.v_entity_ksm_degrees.FIRST_KSM_YEAR,

rpt_pbh634.v_entity_ksm_degrees.PROGRAM,

rpt_pbh634.v_entity_ksm_degrees.PROGRAM_GROUP,

Employ.fld_of_work,

Employ.job_title,

Employ.employer_name,

rpt_pbh634.v_entity_ksm_households.HOUSEHOLD_CITY,

rpt_pbh634.v_entity_ksm_households.HOUSEHOLD_STATE,

rpt_pbh634.v_entity_ksm_households.HOUSEHOLD_ZIP,

rpt_pbh634.v_entity_ksm_households.HOUSEHOLD_GEO_CODES,

ksm_assignment.prospect_manager,

ksm_assignment.lgos,

ksm_assignment.managers,

Prospect.EVALUATION_RATING,

Prospect.OFFICER_RATING,

case when KSM_Email.email_address is not null then 'Y' Else 'N' END As pref_email_ind,

spec.GAB,

spec.TRUSTEE,

spec.NO_CONTACT,

spec.NO_SOLICIT,

spec.NO_PHONE_IND,

spec.NO_EMAIL_IND,

spec.NO_MAIL_IND,

spec.SPECIAL_HANDLING_CONCAT

From rpt_pbh634.v_entity_ksm_degrees

Inner Join Entity on rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER = Entity.Id_Number

Left Join rpt_pbh634.v_entity_ksm_households On rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER = rpt_pbh634.v_entity_ksm_households.ID_NUMBER

Left Join Employ On rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER = Employ.Id_Number

Left Join ksm_assignment on ksm_assignment.id_number = rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER

Left Join Prospect on Prospect.id_number = rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER

Left Join KSM_Email on KSM_Email.id_number = rpt_pbh634.v_entity_ksm_degrees.id_number

Left Join SPEC ON Spec.id_number = rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER

Left Join rpt_zrc8929.v_dean_salutation p
    On p.id_number = rpt_pbh634.v_entity_ksm_degrees.id_number

Where rpt_pbh634.v_entity_ksm_degrees.Record_Status_Code IN ('A')
and rpt_pbh634.v_entity_ksm_households.HOUSEHOLD_GEO_CODES like '%Chicago%'
--- Remove no contact/no email
and (spec.NO_CONTACT is null
and spec.NO_EMAIL_IND is null)
