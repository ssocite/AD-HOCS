/*  Ad Hoc Request for Casey Reid 2/10/2021


Please do not include any trustees/GAB members in this pull

Hierarchy for inclusion:
Kellogg Alumni Council � remove any PHS partners and add them to PHS list (Subquery Created)
Pete Henderson Society (Subquery Created)
Kellogg Real Estate Advisory Council (Subquery Created)
Healthcare at Kellogg Council (Subquery Created)
Asset Management Practicum Advisory Council (Subquery Created)
Kellogg Women�s Leadership Council  (Subquery Created)
Kellogg Admissions Leadership Council (Subquery Created)
2020 Reunion Committee members (Subquery Created)
Alumni Club Leaders (Subquery Created)
Alumni mentors --- This is going to the be the Kellogg Alumni Mentoring Committee (Subquery Completed)

Requested fields for email list:
�  CATracks IDs,
�  Names
�  KSM Degree Program and Year
�  Preferred Email Addresses
�  Associated committee
�  Special Handling �No Email�: Remove if they are coded as such.*/




--- Kellogg Alumni Council

With KSM_KACNA AS (select kac.id_number,
       kac.committee_code,
       kac.short_desc,
       kac.status
From table (rpt_pbh634.ksm_pkg.tbl_committee_kac) kac),

--- Kellogg Admissions Leadership Council - Kellogg Development

KSM_KALC AS (Select comm.id_number,
       TMS_COMMITTEE_TABLE.short_desc,
       comm.committee_code,
       comm.committee_status_code
From committee comm
Left Join TMS_COMMITTEE_TABLE ON TMS_COMMITTEE_TABLE.committee_code = comm.committee_code
Where comm.committee_code IN ('KALC')
And comm.committee_status_code = 'C'),

KSM_CL AS (select distinct cl.id_Number
from v_ksm_club_leaders cl),

--- KSM Mentoring Program

KSM_mentor AS (Select comm.id_number,
       TMS_COMMITTEE_TABLE.short_desc,
       comm.committee_code,
       comm.committee_status_code
From committee comm
Left Join TMS_COMMITTEE_TABLE ON TMS_COMMITTEE_TABLE.committee_code = comm.committee_code
Where comm.committee_code IN ('KACMP')
And comm.committee_status_code = 'C'),

--- 2020 Reunion Committee

KSM_Reunion AS (SELECT
    COMMITTEE.ID_NUMBER,
    deg.REPORT_NAME,
    COMMITTEE.COMMITTEE_CODE,
    COMMITTEE.START_DT,
    COMMITTEE.STOP_DT,
    Tms_Committee_Table.short_desc
 FROM COMMITTEE
 Left Join Tms_Committee_Table ON Tms_Committee_Table.committee_code = COMMITTEE.COMMITTEE_CODE
 Left Join rpt_pbh634.v_entity_ksm_degrees deg on deg.id_number = COMMITTEE.ID_NUMBER
 WHERE COMMITTEE.COMMITTEE_CODE = '227' AND COMMITTEE.COMMITTEE_STATUS_CODE = 'F'
 And Committee.Start_Dt IN ('20190901')),

--- Asset Management Practicum

AMP AS (select a.id_number,
       a.committee_code,
       a.short_desc,
       a.status
From table (rpt_pbh634.ksm_pkg.tbl_committee_AMP) a),

--- Real Estate Advisory Council

KSM_RE AS (select Re.id_number,
       re.committee_code,
       re.short_desc,
       re.status
From table (rpt_pbh634.ksm_pkg.tbl_committee_RealEstCouncil) re),

--- Kellogg Healthcare Council

KSM_Health AS (select h.id_number,
       h.committee_code,
       h.short_desc,
       h.status
From table (rpt_pbh634.ksm_pkg.tbl_committee_healthcare) h),

--- Kellogg Women Leadership Council

KSM_women AS (select women.id_number,
       women.committee_code,
       women.short_desc,
       women.status
From table (rpt_pbh634.ksm_pkg.tbl_committee_WomensLeadership) women),

--- Kellogg Pete Hnederson Society

KSM_KPH AS (Select comm.id_number,
       TMS_COMMITTEE_TABLE.short_desc,
       comm.committee_code,
       comm.committee_status_code
From committee comm
Left Join TMS_COMMITTEE_TABLE ON TMS_COMMITTEE_TABLE.committee_code = comm.committee_code
Where comm.committee_code IN ('KPH')
And comm.committee_status_code = 'C'),

--- Trustee

Trustee As (select trustee.id_number,
trustee.short_desc,
trustee.role
From Table(rpt_pbh634.ksm_pkg.tbl_committee_trustee) Trustee),

--- GAB

GAB AS (Select gab.id_number,
       gab.short_desc,
       gab.status
From table(rpt_pbh634.ksm_pkg.tbl_committee_gab) gab),

--- Email

KSM_Email AS (select email.id_number,
       email.email_address,
       email.preferred_ind,
       email.forwards_to_email_address
From email
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = email.id_number
Where email.preferred_ind = 'Y'),

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_EMAIL_IND,
       spec.NO_CONTACT
From rpt_pbh634.v_entity_special_handling spec)

select deg.ID_NUMBER,
       deg.REPORT_NAME,
       deg.FIRST_KSM_YEAR,
       deg.PROGRAM,
       KSM_Email.email_address,
       case when KSM_KACNA.short_desc = 'KSM Alumni Council' then 'KAC'
         when KSM_KPH.short_desc = 'KSM Pete Henderson Society' then 'PHS'
           when KSM_RE.short_desc = 'Real Estate Advisory Council' then 'Real Estate Advisory Council'
             when KSM_Health.short_desc = 'Healthcare at Kellogg Advisory Council' then 'Healthcare at Kellogg Advisory Council'
               when AMP.short_desc = 'AMP Advisory Council' then 'AMP Advisory Council'
                 when KSM_women.committee_code = 'KWLC' then 'KSM Womens Leadership Advisory Council'
                   when KSM_KALC.short_desc = 'Kellogg Admissions Leadership Council' then 'Kellogg Admissions Leadership Council'
                     when KSM_Reunion.short_desc = 'KSM Reunion Committee' then 'KSM Reunion Committee'
                       when KSM_CL.id_number is not null then 'Club_Leader'
                         when KSM_mentor.short_desc = 'Kellogg Alumni Mentorship Program' then 'Kellogg Alumni Mentorship Program'
                          else '' END as List_Rank_For_Email,
        KSM_KACNA.short_desc as KAC_Indicator,
        KSM_KPH.short_desc as PHS_Indicator,
        KSM_RE.short_desc as real_estate_indicator,
        KSM_Health.short_desc as KSM_Healthcare_indicator,
        AMP.short_desc as AMP_Indicator,
        KSM_Women.short_desc as Women_Leadership,
        KSM_KALC.short_desc as KSM_Admission_Leader_Indicator,
        KSM_Reunion.short_desc as KSM_Reunion_Comm_Indicator,
        case when KSM_CL.id_number is not null then 'Club_Leader' Else '' End as KSM_CL_Indicator,
          KSM_mentor.short_desc as KSM_Mentor_Indicator,
       KSM_Spec.NO_CONTACT,
       KSM_Spec.NO_EMAIL_IND,
       Trustee.short_desc as trustee_indicator,
       GAB.short_desc as GAB_indicator
from rpt_pbh634.v_entity_ksm_degrees deg
left join entity on entity.id_number = deg.ID_NUMBER
left join Trustee ON Trustee.id_number = deg.ID_NUMBER
left join GAB ON GAB.id_number = deg.ID_NUMBER
left join KSM_Email ON KSM_Email.id_number = deg.ID_NUMBER
left join KSM_Spec ON KSM_Spec.id_number = deg.ID_NUMBER
left join KSM_KACNA ON KSM_KACNA.id_number = deg.ID_NUMBER
left join KSM_KALC ON KSM_KALC.id_number = deg.ID_NUMBER
left join KSM_KPH ON KSM_KPH.id_number = deg.ID_NUMBER
left join KSM_RE on KSM_RE.id_number = deg.ID_NUMBER
left join AMP on AMP.id_number = deg.ID_NUMBER
left join KSM_Health on KSM_Health.id_number = deg.ID_NUMBER
left join KSM_women on KSM_women.id_number = deg.ID_NUMBER
left join KSM_Reunion on KSM_Reunion.id_number = deg.ID_NUMBER
left join KSM_CL on KSM_CL.id_number = deg.ID_NUMBER
left join KSM_Mentor on KSM_Mentor.id_number = deg.ID_NUMBER
Where Trustee.short_desc is null
And GAB.short_desc is null
And entity.institutional_suffix Not Like '%Trustee%'
And KSM_spec.NO_CONTACT is null
And KSM_spec.NO_EMAIL_IND is null
AND (KSM_KACNA.short_desc is not null
OR KSM_KPH.short_desc is not null
OR KSM_RE.short_desc is not null
OR KSM_HEALTH.short_desc is not null
OR AMP.short_desc is not null
OR KSM_women.short_desc is not null
OR KSM_KALC.short_desc is not null
OR KSM_Reunion.short_desc is not null
OR KSM_CL.id_number is not null
OR KSM_mentor.short_desc is not null)
Order By deg.REPORT_NAME ASC
