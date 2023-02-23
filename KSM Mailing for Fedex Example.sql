--- Household as base
with h as (select *
from RPT_PBH634.V_ENTITY_KSM_HOUSEHOLDS),

--- Dean Salutation as base
p as (select *
from RPT_PBH634.V_DEAN_SALUTATION),

--- Zach's code which pulls preferred address, but also considers seasonal address for the time of year

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
      ,  t.telephone_type_code
      ,  t.area_code
      ,  t.telephone_number
      FROM address a
      INNER JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN telephone t on t.telephone_type_code = a.addr_type_code
      and t.id_number = a.id_number
      WHERE a.addr_pref_IND = 'Y'
      AND a.addr_status_code IN('A','K')
),

--- We Want Preferred Address OR HOME (if Preferred is a business)
home_address as (

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
      ,  t.telephone_type_code
      ,  t.area_code
      ,  t.telephone_number
      FROM address a
      INNER JOIN tms_addr_status ON tms_addr_status.addr_status_code = a.addr_status_code
      LEFT JOIN tms_address_type ON tms_address_type.addr_type_code = a.addr_type_code
      LEFT JOIN tms_country ON tms_country.country_code = a.country_code
      LEFT JOIN telephone t on t.telephone_type_code = a.addr_type_code
      and t.id_number = a.id_number
      WHERE a.addr_pref_IND = 'N'
      AND a.addr_type_code = 'H')


-- this subquery is pulling each id's seasonal address when the current date falls in between the seasonal address time
, Seas_Address AS(
      SELECT *
      FROM rpt_dgz654.v_seasonal_addr SA
      WHERE CURRENT_DATE
        BETWEEN SA.real_start_date1 AND SA.real_stop_date1
        OR CURRENT_DATE BETWEEN SA.real_start_date2 AND SA.real_stop_date2
),

--- Special Handling Code

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_MAIL_IND,
       spec.NO_CONTACT
From rpt_pbh634.v_entity_special_handling spec),

Phone as (Select t.id_number,
t.preferred_ind,
t.telephone_type_code,
t.area_code,
t.telephone_number
From telephone t
where t.preferred_ind = 'Y')

Select

      entity.id_number,
--- Preferred Indicator

     Case
     When SA.ADDRESS_TYPE = 'Seasonal' Then SA.addr_pref_ind
     When PA.Address_type = 'Home' Then PA.addr_pref_ind
     When PA.Address_type != 'Home' Then HA.addr_pref_ind
     Else Null
       End Preferred_address_ind,




---- Company Name

Case
     When SA.ADDRESS_TYPE = 'Seasonal' Then SA.Address_Type
     When PA.Address_type = 'Home' Then PA.Address_Type
     When PA.Address_type != 'Home' Then HA.Address_Type
     Else Null
       End Business_Name

--- Contact (AKA Preferred Name)

, h.PREF_MAIL_NAME


---- Street, City, State, Zipcode, Country

   ,Case
     When SA.ADDRESS_TYPE = 'Seasonal' Then SA.Street1
     When PA.Address_type = 'Home' Then PA.Street1
      When PA.Address_type != 'Home' Then HA.Street1
     Else Null
       End Street1
   ,Case
     When SA.ADDRESS_TYPE = 'Seasonal' Then SA.Street2
     When PA.Address_type = 'Home' Then PA.Street2
       When PA.Address_type != 'Home' Then HA.Street2
     Else Null
       End Street2
   ,Case
     When SA.ADDRESS_TYPE = 'Seasonal' Then SA.City
     When PA.Address_type = 'Home' Then PA.City
     When PA.Address_type != 'Home' Then HA.City
     Else Null
       End City
  ,Case
     When SA.ADDRESS_TYPE = 'Seasonal' Then SA.State_Code
     When PA.Address_type = 'Home' Then PA.State_Code
       When PA.Address_type != 'Home' Then HA.State_Code
     Else Null
       End State
  ,Case
     When SA.ADDRESS_TYPE = 'Seasonal' Then SA.Zipcode
     When PA.Address_type = 'Home'  Then PA.Zipcode
       When PA.Address_type != 'Home' Then HA.Zipcode
     Else Null
       End Zipcode
  ,Case
     When SA.ADDRESS_TYPE = 'Seasonal' Then SA.Country
     When PA.Address_type = 'Home' Then PA.Country
       When PA.Address_type != 'Home' Then HA.Country
     Else Null
       End Country
  ,




/* Rule is....

If Preferred address = Home, then telephone Home

If Preferred address does not equal home, then active home address and home phone

If no home phone on file, then default to the preferred home


*/


  ---- Phone Type

  --- If preferred address is home, then grab the telephone that is home
    case when pa.telephone_type_code = 'H' then pa.telephone_type_code
  --- If preferred addres is NOT home, then grab active home address and active home phone
      when pa.telephone_type_code != 'H' then ha.telephone_type_code
  --- However, If there are no home telephones, then we settle for the preferred phone
      else phone.telephone_type_code end as telephone_type_code,


  ---- Area Code
    case when  pa.telephone_type_code = 'H'  then pa.area_code
      when pa.telephone_type_code != 'H' then ha.area_code
      else phone.area_code end as phone_area_code,

  --- Phone Number
  case when pa.telephone_type_code = 'H' then pa.telephone_number
  when pa.telephone_type_code != 'H' then ha.telephone_number
      else phone.telephone_number end as telephone_number


from entity
left join PrefAddress pa on pa.id_number = entity.id_number
left join Seas_Address sa on sa.id_number = entity.id_number
left join home_address ha on ha.id_number = entity.id_number
left join h on h.id_number = entity.id_number
left join p on p.id_number = entity.id_number
left join KSM_Spec on KSM_Spec.id_number = entity.id_number
---- Preferred Phone just in case
left join phone on phone.id_number = entity.id_number
order by entity.last_name asc
