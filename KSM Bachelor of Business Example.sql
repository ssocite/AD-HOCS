--- Trustee

With Trustee As (select trustee.id_number,
trustee.short_desc,
trustee.role
From Table(rpt_pbh634.ksm_pkg.tbl_committee_trustee) Trustee),

--- GAB Current

GAB AS (Select gab.id_number,
       gab.short_desc,
       gab.status
From table(rpt_pbh634.ksm_pkg.tbl_committee_gab) gab),

--- GAB Former

GABF AS (Select comm.id_number,
tms_committee_table.short_desc,
       comm.committee_code,
       comm.committee_status_code,
       tms_committee_status.short_desc as status,
       comm.start_dt
From committee comm
left join tms_committee_status on tms_committee_status.committee_status_code = comm.committee_status_code
left join tms_committee_table on tms_committee_table.committee_code = comm.committee_code
Where comm.committee_code IN ('U')
And comm.committee_status_code = 'F'),

--- Real Estate Advisory Council

KSM_RE AS (select Re.id_number,
       re.committee_code,
       re.short_desc,
       re.status
From table (rpt_pbh634.ksm_pkg.tbl_committee_RealEstCouncil) re),

--- Kellogg Alumni Council

KSM_KACNA AS (select kac.id_number,
       kac.committee_code,
       kac.short_desc,
       kac.status
From table (rpt_pbh634.ksm_pkg.tbl_committee_kac) kac),

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_EMAIL_IND,
       spec.NO_CONTACT
From rpt_pbh634.v_entity_special_handling spec),

--- Email

KSM_Email AS (select email.id_number,
       email.email_address,
       email.preferred_ind,
       email.forwards_to_email_address
From email
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = email.id_number
Where email.preferred_ind = 'Y')

SELECT  d.ID_NUMBER,
        d.REPORT_NAME,
        d.RECORD_STATUS_CODE,
        d.DEGREES_VERBOSE,
        d.DEGREES_CONCAT,
        d.FIRST_KSM_YEAR,
        d.PROGRAM,
        d.PROGRAM_GROUP,
        case when KSM_Email.email_address is not null then 'Y' else 'N' End as Pref_Email_on_File
FROM rpt_pbh634.v_entity_ksm_degrees d
left join degrees on degrees.id_number = d.id_number
left join entity on entity.id_number = d.ID_NUMBER
left join Trustee ON Trustee.id_number = d.ID_NUMBER
left join GAB ON GAB.id_number = d.ID_NUMBER
left join GABF ON GABF.id_number = d.ID_NUMBER
left join KSM_KACNA ON KSM_KACNA.id_number = d.ID_NUMBER
left join KSM_RE on KSM_RE.id_number = d.ID_NUMBER
left join KSM_Spec ON KSM_Spec.id_number = d.ID_NUMBER
left join KSM_Email ON KSM_Email.id_number = d.ID_NUMBER
where d.RECORD_STATUS_CODE IN ('L','A')
--- NO Trustees, NO Current GAB, No Former GAB, NO KAC, No Real Estate
And (Trustee.short_desc is null
And GAB.short_desc is null
and GABF.short_desc is null
And entity.institutional_suffix Not Like '%Trustee%'
And KSM_KACNA.short_desc is null
And KSM_RE.short_desc is null)
--- Exclude NO Contact and No Email
And (KSM_spec.NO_CONTACT is null
And KSM_spec.NO_EMAIL_IND is null)
And (d.DEGREES_VERBOSE Like '%Bachelor of Business%'
and degrees.degree_code = 'BBA')
Order By d.REPORT_NAME ASC