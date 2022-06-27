 --- Kellogg Admission Leadership Council
with kalc as(
select distinct k.id_number, k.short_desc
       FROM TABLE(rpt_pbh634.ksm_pkg.tbl_committee_KALC) k),

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

ksm_assignment as (select distinct assign.id_number,
assign.prospect_manager,
assign.lgos,
assign.managers
from rpt_pbh634.v_assignment_summary assign),

KSM_Email AS (select email.id_number,
       email.email_address
From email
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = email.id_number
Where email.preferred_ind = 'Y'),

Spec AS (Select rpt_pbh634.v_entity_special_handling.ID_NUMBER,
       rpt_pbh634.v_entity_special_handling.GAB,
       rpt_pbh634.v_entity_special_handling.TRUSTEE,
       rpt_pbh634.v_entity_special_handling.NO_CONTACT,
       rpt_pbh634.v_entity_special_handling.NO_SOLICIT,
       rpt_pbh634.v_entity_special_handling.NO_PHONE_IND,
       rpt_pbh634.v_entity_special_handling.NO_EMAIL_IND,
       rpt_pbh634.v_entity_special_handling.NO_MAIL_IND,
       rpt_pbh634.v_entity_special_handling.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling)

select h.ID_NUMBER,
       kalc.short_desc,
       h.REPORT_NAME,
       h.FIRST_KSM_YEAR,
       h.PROGRAM,
       h.PROGRAM_GROUP,
       h.INSTITUTIONAL_SUFFIX,
       h.HOUSEHOLD_CITY,
       h.HOUSEHOLD_STATE,
       h.HOUSEHOLD_COUNTRY,
       employ.job_title,
       employ.employer_name,
       ksm_assignment.lgos,
       ksm_assignment.prospect_manager,
       ksm_assignment.managers,
       KSM_Email.email_address,
       spec.NO_EMAIL_IND
from rpt_pbh634.v_entity_ksm_households h
inner join kalc on kalc.id_number = h.id_number
left join employ on employ.id_number = h.id_number
left join ksm_assignment on ksm_assignment.id_number = h.id_number
left join KSM_Email on KSM_Email.id_number = h.id_number
left join Spec on Spec.id_number = h.id_number
where (spec.NO_EMAIL_IND is null
and spec.NO_CONTACT is null)
and h.FIRST_KSM_YEAR IN ('2016','2017','2018','2019','2020','2021')
order by h.FIRST_KSM_YEAR asc
