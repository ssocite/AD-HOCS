With MBA as (Select Entity.Id_Number,
       Entity.Record_Type_Code,
       Entity.Record_Status_Code,
       Entity.Institutional_Suffix,
       Degrees.School_Code,
       Degrees.Degree_Code,
       Degrees.Degree_Year,
       Degrees.Dept_Code
From Entity
Full Outer Join Degrees ON Entity.Id_Number = Degrees.Id_Number
Where Degrees.School_Code = 'KSM'
AND (Degrees.Degree_Code = 'MBA' OR Degrees.Degree_Code = 'MMM' OR Degrees.Degree_Code = 'MMGT')
AND Entity.Record_Type_Code = 'AL'
AND (Entity.Record_Status_Code = 'A' OR Entity.Record_Status_Code = 'L' OR Entity.Record_Status_Code = 'C')),

KSM_Email AS (select email.id_number,
       email.email_address,
       email.preferred_ind,
       email.forwards_to_email_address
From email
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = email.id_number
Where email.preferred_ind = 'Y'),

KSM_Spec AS (Select spec.ID_NUMBER,
spec.NO_CONTACT,
spec.NO_EMAIL_IND,
spec.GAB,
spec.TRUSTEE,
spec.EBFA,
       spec.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling spec),

employ As (
  Select id_number
  , job_title
  , employment.fld_of_work_code
  , fow.short_desc As fld_of_work
  , employment.fld_of_spec_code1
  , tms_fld_of_spec.short_desc as function
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
       Left Join tms_fld_of_spec
       on tms_fld_of_spec.fld_of_spec_code = employment.fld_of_spec_code1
  Where employment.primary_emp_ind = 'Y'
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
from rpt_pbh634.v_assignment_summary assign)

select h.id_number,
       h.REPORT_NAME,
       h.RECORD_STATUS_CODE,
       h.FIRST_KSM_YEAR,
       h.PROGRAM,
       h.PROGRAM_GROUP,
       employ.fld_of_work,
       employ.employer_name,
       employ.job_title,
       employ.function,
       h.HOUSEHOLD_CITY,
       h.HOUSEHOLD_STATE,
       h.HOUSEHOLD_ZIP,
       h.HOUSEHOLD_GEO_CODES,
       h.HOUSEHOLD_COUNTRY,
       h.HOUSEHOLD_CONTINENT,
       assign.prospect_manager,
       assign.lgos,
       assign.managers,
       prospect.EVALUATION_RATING,
       prospect.OFFICER_RATING,
       KSM_Spec.GAB,
       KSM_Spec.TRUSTEE,
       KSM_Spec.NO_CONTACT,
       KSM_Spec.NO_EMAIL_IND,
       KSM_Spec.EBFA
from rpt_pbh634.v_entity_ksm_households h
inner join MBA on MBA.id_number = h.id_number
left join KSM_Email on KSM_Email.id_number = h.id_number
left join KSM_Spec on KSM_Spec.id_number = h.id_number
left join prospect on prospect.id_number = h.id_number
left join employ on employ.id_number = h.id_number
left join ksm_assignment assign on assign.id_number = h.id_number
Where h.HOUSEHOLD_GEO_CODES like '%San Francisco%'
and (KSM_Spec.GAB is null
and KSM_Spec.TRUSTEE is null
and KSM_Spec.NO_CONTACT is null
and KSM_Spec.NO_EMAIL_IND is null
and KSM_Spec.EBFA is null)
and h.PROGRAM_GROUP = 'FT'
and employ.fld_of_work IN ('Nanotechnology',
'Defense & Space',
'Telecommunications',
'Pharmaceuticals',
'Airlines/Aviation',
'Computer & Network Security',
'Computer Hardware',
'Computer Networking',
'Computer Software',
'Information Technology and Services',
'Internet',
'Semiconductors',
'Wireless')
order by employ.fld_of_work asc
