with employ As (
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

h as (select *
from rpt_pbh634.v_entity_ksm_households h),

e as (select *
from entity),

KSM_Email AS (select email.id_number,
       email.email_address
From email
Where email.preferred_ind = 'Y'),

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.GAB,
       spec.TRUSTEE,
       spec.NO_CONTACT,
       spec.NO_EMAIL_IND,
       spec.EBFA
From rpt_pbh634.v_entity_special_handling spec),

assign as (select assign.id_number,
       assign.prospect_manager,
       assign.lgos,
       assign.managers,
       assign.curr_ksm_manager
from rpt_pbh634.v_assignment_summary assign),

eval as (select distinct TP.ID_NUMBER, TP.EVALUATION_RATING, TP.OFFICER_RATING
from nu_prs_trp_prospect TP),

g as (select rpt_pbh634.v_ksm_giving_summary.ID_NUMBER,
rpt_pbh634.v_ksm_giving_summary.NGC_LIFETIME,
             rpt_pbh634.v_ksm_giving_summary.NU_MAX_HH_LIFETIME_GIVING,
             rpt_pbh634.v_ksm_giving_summary.LAST_GIFT_DATE
from rpt_pbh634.v_ksm_giving_summary),

i as (Select distinct
   degrees.id_number,
   institution.institution_name,
   degrees.degree_year,
   degrees.degree_code,
   degrees.degree_level_code
From degrees
Left Join institution
  On institution.institution_code = degrees.institution_code
Left Join tms_school tms_sch
  On tms_sch.school_code = degrees.school_code
Left Join tms_campus tms_cmp
  On tms_cmp.campus_code = degrees.campus_code
Left Join tms_degrees tms_deg
  On tms_deg.degree_code = degrees.degree_code
Left Join tms_class_section tms_cs
  On tms_cs.section_code = degrees.class_section
Left Join tms_dept_code tms_dc
  On tms_dc.dept_code = degrees.dept_code
Left Join tms_majors m1
  On m1.major_code = degrees.major_code1
Left Join tms_majors m2
  On m2.major_code = degrees.major_code2
Left Join tms_majors m3
  On m3.major_code = degrees.major_code3
Left join TMS_DEGREE_LEVEL
ON TMS_DEGREE_LEVEL.degree_level_code = degrees.degree_level_code
where(institution.institution_code = '34624')
and degrees.degree_type = 'U' )

select distinct h.ID_NUMBER,
h.report_name,
--- Name
-- Record Status
       h.RECORD_STATUS_CODE,
       --- Program Information
       h.INSTITUTIONAL_SUFFIX,
       h.FIRST_KSM_YEAR,
       h.PROGRAM,
       h.PROGRAM_GROUP,
       i.institution_name as Undergrad_insitution,
       i.degree_year as Undergrad_Year,
       --- Household Address
       h.HOUSEHOLD_CITY,
       h.HOUSEHOLD_STATE,
       h.HOUSEHOLD_ZIP,
       h.HOUSEHOLD_GEO_CODES,
       --- Job title - in Finance using subquery based on vice president + position discussions
       employ.job_title,
       employ.employer_name,
       employ.fld_of_work as work_industry,

       g.NU_MAX_HH_LIFETIME_GIVING,
       g.NGC_LIFETIME,
       eval.EVALUATION_RATING,
       eval.OFFICER_RATING,
       g.LAST_GIFT_DATE,
       assign.prospect_manager,
       assign.lgos,
       assign.curr_ksm_manager,
       KSM_Spec.GAB,
       KSM_Spec.Trustee,
       KSM_Spec.EBFA,
       KSM_Spec.No_Contact,
       KSM_Spec.No_email_ind
from h
Inner Join rpt_pbh634.v_entity_ksm_degrees d on d.id_number = h.id_number
LEFT JOIN KSM_Spec on KSM_Spec.id_number = h.id_number
LEFT JOIN assign ON assign.ID_NUMBER = h.id_number
Left Join eval on eval.id_number = h.id_number
Left Join g on g.id_number = h.id_number
Left Join employ on employ.id_number = h.id_number
left join e on e.id_number = h.id_number
left join a on a.id_number = h.id_number
inner join i on i.id_number = h.id_number
where h.RECORD_STATUS_CODE IN ('A','L')
Order by i.institution_name asc
