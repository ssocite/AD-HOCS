With h as (select *
from rpt_pbh634.v_entity_ksm_households),

g as (select *
from rpt_pbh634.v_ksm_giving_summary),

assign as (select assign.id_number,
       assign.prospect_manager,
       assign.lgos,
       assign.managers,
       assign.curr_ksm_manager
from rpt_pbh634.v_assignment_summary assign),

--- a. GAB Members in Asia

a AS (Select gab.id_number,
       gab.short_desc,
       gab.status
From table(rpt_pbh634.ksm_pkg.tbl_committee_gab) gab
inner join h on h.id_number = gab.id_number
where h.HOUSEHOLD_CONTINENT = 'Asia'),


--- b. Trustees in Asia

b As (select trustee.id_number,
trustee.short_desc,
trustee.role
From Table(rpt_pbh634.ksm_pkg.tbl_committee_trustee) Trustee
inner join h on h.id_number = trustee.id_number
where h.HOUSEHOLD_CONTINENT = 'Asia'),

--- c. Kellogg Executive Board for Asia

c As (Select asia.id_number,
       asia.short_desc
       FROM TABLE(rpt_pbh634.ksm_pkg.tbl_committee_asia) asia),
/*From committee comm
left join tms_committee_status on tms_committee_status.committee_status_code = comm.committee_status_code
left join tms_committee_table on tms_committee_table.committee_code = comm.committee_code
Where comm.committee_code IN ('KEBA')
And comm.committee_status_code = 'C'*/

--- d.  Alumni in Asia rated $5M+ that we have a relationship with or are managed

d as (select distinct TP.ID_NUMBER, TP.EVALUATION_RATING, TP.OFFICER_RATING
from nu_prs_trp_prospect TP
left join h on h.id_number = tp.id_number
left join assign on assign.id_number = tp.id_number
where (TP.EVALUATION_RATING IN (
'A1 $100M+','A2 $50M - 99.9M','A3 $25M - $49.9M','A4 $10M - $24.9M',
'A5 $5M - $9.9M')
Or TP.OFFICER_RATING IN ('A1 $100M+','A2 $50M - 99.9M','A3 $25M - $49.9M','A4 $10M - $24.9M',
'A5 $5M - $9.9M'))
and h.HOUSEHOLD_CONTINENT = 'Asia'
and assign.curr_ksm_manager = 'Y'),

--- e.  Alumni in Asia who have given $100K+ lifetime

e as (select h.id_number
from h
left join g on g.id_number = h.id_number
where h.HOUSEHOLD_CONTINENT = 'Asia'
and g.NGC_LIFETIME >= 100000),

--- No contact/No Email

s AS (Select spec.ID_NUMBER,
spec.NO_CONTACT,
spec.NO_EMAIL_IND
From rpt_pbh634.v_entity_special_handling spec),

--- Employment Data

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
)

select h.id_number,
       entity.record_type_code,
       h.REPORT_NAME,
       entity.institutional_suffix,
       h.FIRST_KSM_YEAR,
       h.PROGRAM,
       h.PROGRAM_GROUP,
       a.short_desc as gab_in_asia,
       b.short_desc as trustee_in_asia,
       c.short_desc as KEBA_Member,
       employ.job_title,
       employ.employer_name,
       employ.fld_of_work,
       h.HOUSEHOLD_CITY,
       h.HOUSEHOLD_COUNTRY,
       d.EVALUATION_RATING,
       d.OFFICER_RATING,
       assign.prospect_manager,
       assign.lgos
from h
left join a on a.id_number = h.id_number
left join b on b.id_number = h.id_number
left join c on c.id_number = h.id_number
left join d on d.id_number = h.id_number
left join e on e.id_number = h.id_number
left join g on g.id_number = h.id_number
left join s on s.id_number = h.id_number
left join entity on entity.id_number = h.id_number
left join assign on assign.id_number = h.id_number
left join employ on employ.id_number = h.id_number
where (a.id_number is not null
or b.id_number is not null
or c.id_number is not null
or d.id_number is not null
or e.id_number is not null)
--- No contact and no email
and (s.NO_CONTACT is null
and s.NO_EMAIL_IND is null)
and h.PERSON_OR_ORG = 'P'
and entity.record_type_code = 'AL'
