With KSM_Email AS (select email.id_number,
       email.email_address,
       email.preferred_ind,
       email.forwards_to_email_address
From email
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = email.id_number
Where email.preferred_ind = 'Y'),

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling spec),

KSM_Alt AS (select distinct email.id_number
       , Listagg (email.email_address, ';  ') Within Group (Order By email.email_address) As Altenative_Email
From email
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = email.id_number
Where email.preferred_ind = 'N'
And email.email_status_code = 'A'
Group By email.id_number)


Select deg.ID_NUMBER,
       deg.REPORT_NAME,
       deg.RECORD_STATUS_CODE,
       deg.FIRST_KSM_YEAR,
       deg.PROGRAM,
       deg.PROGRAM_GROUP,
       KSM_Email.email_address AS Preferred_Email,
       KSM_Email.forwards_to_email_address AS Fwd_Email_Address,
       KSM_spec.SPECIAL_HANDLING_CONCAT,
       KSM_Alt.Altenative_Email AS Alt_Email

From rpt_pbh634.v_entity_ksm_degrees deg
LEft Join KSM_Email ON KSM_Email.id_number = deg.ID_NUMBER
Left Join KSM_SPEC ON KSM_Spec.id_number = deg.ID_NUMBER
Left Join KSM_Alt ON KSM_Alt.id_number = deg.ID_NUMBER
Where deg.RECORD_STATUS_CODE = 'L'
And deg.FIRST_KSM_YEAR IN ('2016', '2015', '2011', '2010')
And deg.program_group = 'FT'
and deg.PROGRAM in ('FT-2Y','FT-MMM','FT-1Y','FT-JDMBA','FT-MDMBA')
Order by First_KSM_Year ASC
