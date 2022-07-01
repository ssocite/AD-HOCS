With KSM_DEGREES AS (
 SELECT
   KD.ID_NUMBER
   ,KD.PROGRAM
   ,KD.PROGRAM_GROUP
   ,KD.CLASS_SECTION
 FROM RPT_PBH634.V_ENTITY_KSM_DEGREES KD),

KSM_REUNION AS (
SELECT
A.ID_NUMBER,
A.CLASS_YEAR
,GC.P_GEOCODE_Desc
FROM AFFILIATION A
INNER JOIN KSM_DEGREES KD
ON A.ID_NUMBER = KD.ID_NUMBER
LEFT JOIN RPT_DGZ654.V_GEO_CODE GC
  ON A.ID_NUMBER = GC.ID_NUMBER
    AND GC.ADDR_PREF_IND = 'Y'
     AND GC.GEO_STATUS_CODE = 'A'
Where A.AFFIL_CODE = 'KM'
AND A.AFFIL_LEVEL_CODE = 'RG'
),


KFN AS (select k.id_number,
       k.role,
       k.committee_title,
       k.committee_code,
       k.short_desc
From table (rpt_pbh634.ksm_pkg.tbl_committee_KFN) k),

KSM_Email AS (select email.id_number,
       email.email_address,
       email.preferred_ind,
       email.forwards_to_email_address
From email
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = email.id_number
Where email.preferred_ind = 'Y'),

Phone as (Select t.id_number,
t.telephone_type_code,
TMS_TELEPHONE_TYPE.short_desc,
t.preferred_ind,
t.area_code,
t.telephone_number
from telephone t
left join TMS_TELEPHONE_TYPE on TMS_TELEPHONE_TYPE.telephone_type_code = t.telephone_type_code
where t.preferred_ind = 'Y'),

KSM_Spec AS (Select spec.ID_NUMBER,
         spec.NO_CONTACT,
         spec.NO_PHONE_IND,
         spec.NO_EMAIL_IND,
       spec.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling spec),

--- Registrations on April 23+24 Reunion Weekends

reunion1 as (select EP_REGISTRATION.CONTACT_ID_NUMBER,
EP_REGISTRATION.EVENT_ID,
TMS_EVENT_REGISTRATION_STATUS.short_desc,
EP_REGISTRATION.RESPONSE_DATE
from EP_REGISTRATION
left join TMS_EVENT_REGISTRATION_STATUS ON TMS_EVENT_REGISTRATION_STATUS.registration_status_code = EP_REGISTRATION.REGISTRATION_STATUS_CODE
where EP_REGISTRATION.EVENT_ID = '26358'),


----Participants on April 23+24 Reunion Weekends

p1 as (select p.id_number
from rpt_pbh634.v_nu_event_participants_fast p
where p.event_id = '26358'),

reunion2 as (select EP_REGISTRATION.CONTACT_ID_NUMBER,
EP_REGISTRATION.EVENT_ID,
TMS_EVENT_REGISTRATION_STATUS.short_desc,
EP_REGISTRATION.RESPONSE_DATE
from EP_REGISTRATION
left join TMS_EVENT_REGISTRATION_STATUS ON TMS_EVENT_REGISTRATION_STATUS.registration_status_code = EP_REGISTRATION.REGISTRATION_STATUS_CODE
where EP_REGISTRATION.EVENT_ID = '26385'),

p2 as (select p.id_number
from rpt_pbh634.v_nu_event_participants_fast p
where p.event_id = '26385'),

KSM_Address as (Select
         a.Id_number
      ,  a.addr_pref_ind
      ,  a.street1
      ,  a.street2
      ,  a.street3
      ,  a.zipcode
      ,  a.city
      ,  a.state_code
      ,  a.country_code
      FROM address a
      WHERE a.addr_pref_IND = 'Y')


select distinct hh.ID_NUMBER,
--- Name
    hh.PREF_MAIL_NAME,
    --- Record Stat
    hh.RECORD_STATUS_CODE,
    entity.first_name,
    entity.last_name,
    v_ksm_club_leaders.Club_Title,
    v_ksm_club_leaders.Leadership_title,
    KSM_Email.email_address,
    Phone.area_code,
    Phone.telephone_number,
    --- Program
    hh.PROGRAM,
    hh.PROGRAM_GROUP,
    hh.FIRST_KSM_YEAR,
--- Registered for April 30 + May 1st?
case when reunion1.CONTACT_ID_NUMBER is not null then 'Registered_Apr23_24' Else '' End as Reg_First_Weekend_IND,
case when reunion2.CONTACT_ID_NUMBER is not null then 'Registered_Apr30_May1st' Else '' End as Reg_Second_Weekend_IND,
case when p1.id_number is not null then 'Participate_Apr23_24' Else '' End as Part_First_Weekend_IND,
case when p2.id_number is not null then 'Patricipate_Apr30_May1st' Else '' End as Part_Second_Weekend_IND,
         a.addr_pref_ind
      ,  a.street1
      ,  a.street2
      ,  a.street3
      ,  a.zipcode
      ,  a.city
      ,  a.state_code
      ,  a.country_code,
         KSM_Spec.NO_PHONE_IND,
         KSM_Spec.NO_CONTACT,
         KSM_Spec.NO_EMAIL_IND

From rpt_pbh634.v_entity_ksm_households hh
--- Just KFN
inner join v_ksm_club_leaders on v_ksm_club_leaders.id_number = hh.id_number
inner join KSM_Address a on a.id_number = hh.id_number
left join entity on entity.id_number = hh.id_number
left join KSM_REUNION on KSM_REUNION.id_number = hh.ID_NUMBER
left join KSM_Email on KSM_Email.id_number = hh.id_number
left join KSM_Spec on KSM_Spec.id_number = hh.id_number
left join Phone on Phone.id_number = hh.id_number
left join p1 on p1.id_number = hh.id_number
left join p2 on p2.id_number = hh.id_number
left join reunion1 on reunion1.CONTACT_ID_NUMBER = hh.id_number
left join reunion2 on reunion2.CONTACT_ID_NUMBER = hh.id_number
order by entity.last_name
