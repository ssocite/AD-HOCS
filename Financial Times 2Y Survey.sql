With KSM_Email AS (select email.id_number,
       email.email_address,
       email.preferred_ind,
       email.forwards_to_email_address
From email
Where email.preferred_ind = 'Y'),

KSM_Spec AS (Select spec.ID_NUMBER,
         spec.NO_EMAIL_IND,
         spec.NO_CONTACT,
       spec.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling spec),

KSM_Alt AS (select distinct email.id_number
, Listagg (email.email_address, ';  ') Within Group
(Order By email.email_address) As email_address
From email
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = email.id_number
Where email.preferred_ind = 'N'
And email.email_status_code = 'A'
Group By email.id_number)



Select distinct deg.ID_NUMBER,
v_datamart_ids.emplid,
entity.first_name,
entity.last_name,
       deg.FIRST_KSM_YEAR,
       deg.PROGRAM,
       deg.PROGRAM_GROUP,
       case when KSM_Email.email_address is not null and KSM_Spec.NO_EMAIL_IND is null and KSM_Spec.NO_CONTACT is null
         then KSM_Email.email_address else ' ' End as Preferred_Email,
        case when KSM_Alt.email_address  is not null and KSM_Spec.NO_EMAIL_IND is null and KSM_Spec.NO_CONTACT is null
          then KSM_Alt.email_address  else ' ' End as Alt_Email,
         KSM_spec.NO_EMAIL_IND,
         KSM_spec.NO_CONTACT
From rpt_pbh634.v_entity_ksm_degrees deg
left join entity on entity.id_number = deg.ID_NUMBER
left join v_datamart_ids on v_datamart_ids.catracks_id = deg.ID_NUMBER
left join KSM_Email on KSM_Email.id_number = deg.id_number
left join KSM_Alt on KSM_Alt.id_number = deg.id_number
left join KSM_Spec on KSM_Spec.id_number = deg.ID_NUMBER
where deg.PROGRAM = 'FT-2Y'
and deg.FIRST_KSM_YEAR = '2019'
and (KSM_Spec.NO_EMAIL_IND is null
and KSM_Spec.NO_CONTACT is null)
Order by entity.last_name ASC
