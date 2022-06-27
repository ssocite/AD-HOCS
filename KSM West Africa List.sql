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

Spec AS (Select s.ID_NUMBER,
       s.GAB,
       s.TRUSTEE,
       s.NO_CONTACT,
       s.NO_SOLICIT,
       s.NO_PHONE_IND,
       s.NO_EMAIL_IND,
       s.NO_MAIL_IND,
       s.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling s),

--- West Africa Club

WA AS (Select comm.id_number,
       TMS_COMMITTEE_TABLE.short_desc,
       comm.committee_code,
       comm.committee_status_code
From committee comm
Left Join TMS_COMMITTEE_TABLE ON TMS_COMMITTEE_TABLE.committee_code = comm.committee_code
Where comm.committee_code IN ('KACWA')
And comm.committee_status_code = 'C'),

House as (Select h.id_number,
h.HOUSEHOLD_CITY,
h.HOUSEHOLD_STATE,
h.HOUSEHOLD_ZIP,
h.HOUSEHOLD_CONTINENT,
h.HOUSEHOLD_COUNTRY
from rpt_pbh634.v_entity_ksm_households h
where h.HOUSEHOLD_COUNTRY IN (
--- None in Benin
'Benin',
--- None in Burkina Faso
'Burkina Faso',
--- None in Cape Verde
'Cape Verde',
'%Cote%',
'Ivory Coast',
'The Gambia',
'Ghana',
'Guinea',
'Guinea Bissau',
'Liberia, Mali',
'Mauritania',
'Niger',
'Nigeria',
'Sierra Leone',
'Senegal',
--- No Alumni in Togo
'Togo'))

Select Distinct
rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER,
rpt_pbh634.v_entity_ksm_degrees.REPORT_NAME,
rpt_pbh634.v_entity_ksm_degrees.RECORD_STATUS_CODE,
rpt_pbh634.v_entity_ksm_degrees.FIRST_KSM_YEAR,
rpt_pbh634.v_entity_ksm_degrees.PROGRAM,
rpt_pbh634.v_entity_ksm_degrees.PROGRAM_GROUP,
rpt_pbh634.v_entity_ksm_degrees.CLASS_SECTION,
Entity.Gender_Code,
Employ.fld_of_work_code,
Employ.fld_of_work,
Employ.employer_name,
Employ.job_title,
house.HOUSEHOLD_CITY,
house.HOUSEHOLD_COUNTRY,
house.HOUSEHOLD_CONTINENT,
ksm_assignment.prospect_manager,
ksm_assignment.lgos,
ksm_assignment.managers,
KSM_Email.email_address,
spec.GAB,
spec.TRUSTEE,
spec.NO_CONTACT,
spec.NO_SOLICIT,
spec.NO_PHONE_IND,
spec.NO_EMAIL_IND,
spec.NO_MAIL_IND,
WA.short_desc

From rpt_pbh634.v_entity_ksm_degrees
Inner Join Entity on rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER = Entity.Id_Number
Left Join house On house.ID_NUMBER = rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER
Left Join Employ On rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER = Employ.Id_Number
Left Join ksm_assignment on ksm_assignment.id_number = rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER
Left Join KSM_Email on KSM_Email.id_number = rpt_pbh634.v_entity_ksm_degrees.id_number
Left Join SPEC ON Spec.id_number = rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER
Left Join WA ON WA.id_number = rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER
Where (WA.id_number is not null
or House.id_number is not null)
and (spec.GAB is null
and spec.TRUSTEE is null
and spec.NO_CONTACT is null
and spec.NO_EMAIL_IND is null)
Order By house.HOUSEHOLD_COUNTRY ASC
