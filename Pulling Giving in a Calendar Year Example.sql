
--- Update 12/14: We are taking out class of 1998 and including donors!!!

--- Subquery used to establish MBA degree holders
--- Used this code from the file MBA Count in Jan 2021 (Modified for Class year)

with MBA as (Select distinct degrees.ID_NUMBER,
       Degrees.Degree_Year
From Degrees
Where Degrees.School_Code = 'KSM'
AND (Degrees.Degree_Code = 'MBA' OR Degrees.Degree_Code = 'MMM' OR Degrees.Degree_Code = 'MMGT')
And Degrees.Degree_Year IN ('1987', '1990', '2006', '2007', '2010', '2011')
Order by Degrees.Degree_Year),

--- Special Handling Codes

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_EMAIL_IND,
       spec.NO_CONTACT,
       spec.NO_EMAIL_SOL_IND
From rpt_pbh634.v_entity_special_handling spec),

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

--- Givers in 2021 Calendar Year! 

give as (select rpt_pbh634.v_ksm_giving_trans_hh.ID_NUMBER
from rpt_pbh634.v_ksm_giving_trans_hh
WHERE TRUNC(rpt_pbh634.v_ksm_giving_trans_hh.DATE_OF_RECORD) <= TO_DATE('12/31/2021','mm/dd/yyyy')
and TRUNC(rpt_pbh634.v_ksm_giving_trans_hh.DATE_OF_RECORD) >= TO_DATE('01/01/2021','mm/dd/yyyy'))

Select Distinct deg.ID_NUMBER,
       entity.first_name,
       entity.last_name,
       entity.institutional_suffix,
       deg.RECORD_STATUS_CODE,
       MBA.Degree_Year,
       deg.PROGRAM_GROUP,
       deg.DEGREES_VERBOSE,
       trustee.short_desc as trustee,
       gab.short_desc as gab,
       case when give.id_number is not null then 'Donor_2021_Calendar_Year' Else '' END as Donor_2021
From rpt_pbh634.v_entity_ksm_degrees deg
inner join MBA on MBA.id_number = deg.ID_NUMBER
left join give on give.id_number = deg.id_number
left join entity on entity.id_number = deg.ID_NUMBER
left join gab on gab.id_number = deg.ID_NUMBER
left join trustee on trustee.id_number = deg.ID_NUMBER
left join KSM_Spec on KSM_Spec.id_number = deg.ID_NUMBER
Where deg.PROGRAM_GROUP IN ('TMP','EMP','FT')
--- Exclude Trustee + GAB
And (Trustee.short_desc is null
And GAB.short_desc is null
And entity.institutional_suffix Not Like '%Trustee%')
--- Exclude No Email, No Contact and No Email Solictation 
and (KSM_Spec.NO_EMAIL_IND is null
and  KSM_Spec.NO_CONTACT is null
and  KSM_Spec.NO_EMAIL_SOL_IND is null)
And deg.RECORD_STATUS_CODE IN ('A','L')
Order by MBA.degree_year
