with d as (select *
from rpt_pbh634.v_entity_ksm_degrees d),

---- EMBA 2012,2017,2019 Domestic Only

a as (select distinct
degrees.id_number,
TMS_CAMPUS.short_desc
from degrees
left join TMS_CAMPUS on TMS_CAMPUS.campus_code = degrees.campus_code
left join d on d.id_number = degrees.id_number
where degrees.division_code = 'EMP'
and degrees.school_code = 'KSM'
and degrees.non_grad_code = ' '
and degrees.campus_code IN ('MIA','EV')
and (d.FIRST_MASTERS_YEAR IN ('2012','2017','2019')
 or degrees.degree_year IN ('2012', '2017', '2019'))
),


--- 2012,2017,2019 FT 1Y, 2Y, MMM, E&W

c as (Select d.ID_NUMBER
From d
Where d.FIRST_MASTERS_YEAR IN ('2012','2017','2019')
And (d.PROGRAM_GROUP = 'TMP'
or d.PROGRAM IN ('FT-1Y','FT-2Y','FT-MMM'))),

--- Add concentration: Used Listagg as I was getting blank duplicates even though concentration just has one field and I filterted on MBA

concentration as (select distinct
degrees.id_number,
Listagg (TMS_CONCENTRATION.short_desc, ';  ') Within Group (Order By TMS_CONCENTRATION.short_desc) As short_desc
from degrees
Left Join TMS_CONCENTRATION on TMS_CONCENTRATION.concentration_code = degrees.concentration_code
and degrees.degree_code = 'MBA'
Group By degrees.id_number),

--- Pref Email

e as (select email.id_number,
       email.email_address
From email
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = email.id_number
Where email.preferred_ind = 'Y'),

--- Emplid

i as (Select ids_base.id_number,
ids_base.other_id
  From d --- Kellogg Alumni Only
  Left Join ids_base
    On ids_base.id_number = d.id_number
  Where ids_base.ids_type_code In ('SES') --- SES
),

--- Special Handling

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_CONTACT,
       spec.NO_EMAIL_IND
From rpt_pbh634.v_entity_special_handling spec),

M as (select degrees.id_number,
Listagg (TMS_MAJORS.short_desc,';  ') Within Group (Order By TMS_MAJORS.short_desc) As Major
from degrees
Left Join TMS_MAJORS on TMS_MAJORS.major_code = degrees.major_code1
where degrees.degree_code = 'MBA'
and degrees.school_code = 'KSM'
Group By degrees.id_number)

--- •  ID, EMPLID, first name, last name, preferred email, degree type (should be MBA), degree year, degree program, majors, Concentration, EMBA cohort, graduation date

Select distinct d.ID_NUMBER,
       i.other_id as emplid,
       entity.first_name,
       entity.last_name,
       e.email_address as preferred_email,
       degrees.degree_code,
       d.FIRST_MASTERS_YEAR,
       d.PROGRAM,
       d.DEGREES_VERBOSE,
       d.DEGREES_CONCAT,
       --- Add Concentration 10/12/2021
       d.class_section,
       concentration.short_desc as concentration,
       M.major
From d
Left Join entity on entity.id_number = d.id_number
Left Join degrees on degrees.id_number = d.id_number
Left Join a on a.id_number = d.id_number
Left Join c on c.id_number = d.id_number
Left Join e on e.id_number = d.id_number
Left Join i on i.id_number = d.id_number
Left Join KSM_Spec on KSM_Spec.id_number = d.id_number
Left Join M on M.id_number = d.id_number
--- Add Concentration 10/12
Left Join concentration on concentration.id_number = d.id_number
--- Use where to aggregrate population of subquries
Where (a.id_number is not null
or c.id_number is not null)
--- Check Spot for MBA
and degrees.degree_code = 'MBA'
--- Take away No Contact, No Email
and (KSM_Spec.NO_CONTACT is null
and KSM_Spec.NO_EMAIL_IND is null)
--- Keep Lost and Active (No Deceased)
and entity.record_status_code IN ('L','A')
Order by d.FIRST_MASTERS_YEAR ASC
