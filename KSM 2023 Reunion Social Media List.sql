--- Need Emails

With KSM_Email AS (select email.id_number,
       email.email_address,
       email.preferred_ind,
       email.forwards_to_email_address
From email
Where email.preferred_ind = 'Y'),

--- Prefer Address
PrefAddress AS(
      Select
         a.Id_number
      ,  tms_addr_status.short_desc AS Address_Status
      ,  tms_address_type.short_desc AS Address_Type
      ,  a.addr_type_code
      ,  a.addr_pref_ind
      ,  a.company_name_1
      ,  a.company_name_2
      ,  a.street1
      ,  a.street2
      ,  a.street3
      ,  a.foreign_cityzip
      ,  a.city
      ,  a.state_code
      ,  a.zipcode
      ,  tms_country.short_desc AS Country
      FROM address a
      INNER JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      WHERE a.addr_pref_IND = 'Y'
      AND a.addr_status_code IN('A','K')
),

--- Pref Phone
Phone as (Select t.id_number,
t.preferred_ind,
t.telephone_type_code,
t.area_code,
t.telephone_number
From telephone t
where t.preferred_ind = 'Y')


select r.ID_NUMBER,
entity.first_name,
entity.last_name,
r.DEGREE_PROGRAM,
r.PROGRAM_GROUP,
r.CLASS_YEAR,
pref.Address_Type as pref_address_type,
k.email_address as pref_email_address,
pref.street1,
pref.street2,
pref.street3,
pref.city,
pref.state_code,
pref.Country,
p.telephone_type_code,
p.area_code,
p.telephone_number
--- Reunion Members as my Base
from V_KSM_23_REUNION r
inner join entity on entity.id_number = r.ID_NUMBER
left join KSM_Email k on k.id_number = r.ID_NUMBER
left join PrefAddress pref on pref.id_number = r.id_number
left join Phone p on p.id_number = r.id_number
--- Exclude no contacts! """"""""""""""""No Emails"""""""""""""""" is okay for this project because we are not directly emailing them
where r.NO_CONTACT is null
--- We want lost and active records
and r.RECORD_STATUS_CODE IN ('A','L')
---- EDIT for list on 3/8/2023
---- We are excluding 2022 Graduates and HCC 1963-1972
and r.CLASS_YEAR NOT IN ('1963','1964','1965','1966','1967','1968','1969','1970','1971','1972')
Order By r.CLASS_YEAR DESC
