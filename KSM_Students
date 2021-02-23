With

ksm_ids As (
  Select ids_base.id_number
    , ids_base.ids_type_code
    , ids_base.other_id
  From entity --- Kellogg Alumni Only
  Left Join ids_base
    On ids_base.id_number = entity.id_number
  Where ids_base.ids_type_code In ('SES') --- SES = EMPLID + KSF = Salesforce ID + NET = NetID + KEX = KSM EXED ID
),

KSM_Email AS (select email.id_number,
       email.email_address,
       email.preferred_ind,
       email.forwards_to_email_address
From email
Where email.preferred_ind = 'Y'),

KSM_telephone AS (Select t.id_number,
t.area_code,
t.telephone_number
From telephone t
Where t.preferred_ind = 'Y'),

ksm_address As (
  Select
    address.id_number
    , trim(address.business_title) As business_job_title
    , trim(
        trim(address.company_name_1) || ' ' || trim(address.company_name_2)
      ) As business_company_name
    , address.street1
    , address.street2
    , address.city
    , address.state_code
    , address.country_code
    , address.addr_type_code
    , address.addr_status_code
    , address.start_dt
  From address
  Where address.addr_pref_ind = 'Y'
)

Select Distinct
    ksm_ids.other_id As emplid
  , ksm_ids.id_number As catracks_id
  , entity.first_name
  , entity.last_name
  , entity.record_type_code
  , entity.record_status_code
  , entity.institutional_suffix
  , ksm_email.email_address
  , ksm_address.street1
  , ksm_address.street2
  , ksm_address.city
  , ksm_address.state_code
  , ksm_address.country_code
  , KSM_telephone.area_code
  , KSM_telephone.telephone_number
From entity
Inner Join ksm_ids On ksm_ids.id_number = entity.id_number
Left Join ksm_address on ksm_address.id_number = entity.id_number
Left Join ksm_ids On ksm_ids.id_number = entity.id_number
Left Join KSM_Email on KSM_Email.id_number = entity.id_number
Left Join KSM_telephone on KSM_telephone.id_number = entity.id_number
  Where ksm_ids.other_id is not null
  And ksm_ids.ids_type_code = 'SES'
  And entity.record_type_code = 'ST'
  And entity.pref_school_code = 'KSM'
  Order By entity.last_name ASC
