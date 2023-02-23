With employ As (
  Select id_number
  , job_title
  , employment.fld_of_work_code
  , fow.short_desc
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


--- Indicators in the following industries of employment

--- Employed in Banking, Financial Services, Venture Capital & Private Equity
--- L140 Venture Capital & Private Equity



V As (
  Select id_number,
  employ.short_desc
from employ
where employ.fld_of_work_code = 'L140'
),

--- Interest Indicators

--- Venture Captial and Private Equity is actually LVC for interest

venture AS (select Distinct interest.catracks_id,
interest.interest_desc
from rpt_pbh634.v_datamart_career_interests interest
where interest.interest_code IN ('LVC')),


KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_CONTACT,
       spec.NO_EMAIL_IND,
       spec.SPECIAL_HANDLING_CONCAT,
       spec.EBFA,
       spec.GAB,
       spec.TRUSTEE
From rpt_pbh634.v_entity_special_handling spec),

--- Trustee

Trustee As (select trustee.id_number,
trustee.short_desc,
trustee.role
From Table(rpt_pbh634.ksm_pkg_tmp.tbl_committee_trustee) Trustee),

--- GAB

GAB AS (Select gab.id_number,
       gab.short_desc,
       gab.status
From table(rpt_pbh634.ksm_pkg_tmp.tbl_committee_gab) gab)


select distinct d.ID_NUMBER,
       entity.first_name,
       entity.last_name,
       entity.institutional_suffix,
       d.PROGRAM,
       d.FIRST_KSM_YEAR,
       --- Private Equity and Venture Capital Employment Indicator
       v.short_desc as private_equity_employment_ind,
       --- Private Equity Interest Indicator
       venture.interest_desc as vcpe_interest_ind,
       employ.job_title,
       employ.employer_name,
       KSM_Spec.EBFA,
       KSM_Spec.GAB,
       KSM_Spec.TRUSTEE,
       KSM_spec.NO_CONTACT,
       ksm_spec.NO_EMAIL_IND
from rpt_pbh634.v_entity_ksm_degrees d
left join entity on entity.id_number = d.id_number
left join employ on employ.id_number = d.ID_NUMBER
--- employment Venture Capital/Private Equity, Bank
left join v on v.id_number = d.ID_NUMBER
--- interest: Venture Capital/Private Equity, Bank
left join venture on venture.catracks_id = d.id_number
--- Special Handling Codes
left join KSM_Spec on KSM_Spec.id_number = d.ID_NUMBER
--- Take out deceased and no contact
where  d.RECORD_STATUS_CODE IN ('A','L')
--- KSM Alumni Only
and d.PROGRAM_GROUP is not null
--- No Trustee + GAB + EBFA
and (KSM_Spec.GAB is null
And KSM_Spec.EBFA is null
And KSM_Spec.TRUSTEE is null
--- Remove No Contact and No Email
and KSM_Spec.NO_CONTACT is null
and KSM_Spec.NO_EMAIL_IND is null)
--- Include anyone that suffices employment or interest
and (--- Private Equity and Venture Capital Employment Indicator
       v.short_desc is not null or
       --- Private Equity Interest Indicator
       venture.interest_desc is not null)
Order by entity.last_name asc
