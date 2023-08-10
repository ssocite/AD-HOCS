--- Subquery to get EMPLIDs 

With I as (Select ids_base.id_number
    , ids_base.other_id as emplid 
  From entity --- Kellogg Alumni Only
  Left Join ids_base
    On ids_base.id_number = entity.id_number
    --- SES = EMPLID 
  Where ids_base.ids_type_code In ('SES')),

--- Email (preferred and alternative)


KSM_Email AS (select email.id_number,
       email.email_address,
       email.preferred_ind,
       email.forwards_to_email_address
From email
Where email.preferred_ind = 'Y'),


KSM_Alt AS (select distinct email.id_number
       , Listagg (email.email_address, ';  ') Within Group (Order By email.email_address) As Alt_Email
From email
Where email.preferred_ind = 'N'
And email.email_status_code = 'A'
Group By email.id_number),

--- Special Handling Codes: 

--- Special Handling Codes - Provide No Email/No Contact Flags

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_CONTACT,
       spec.NO_EMAIL_IND
From rpt_pbh634.v_entity_special_handling spec),

--- My degree Subquery 
D as (Select degrees.Id_Number,
       Degrees.School_Code,
       Degrees.Degree_Code,
       Degrees.Degree_Year,
       Degrees.Dept_Code, 
       case when Degrees.Dept_Code = '01KGS1Y' then 'FT-1Y'
         when Degrees.Dept_Code = '01KGS2Y' then 'FT-2Y'
           when Degrees.Dept_Code = '01MMS' then 'FT-MS'
             when Degrees.Dept_Code = '13JDM' then 'FT-JDMBA'
               when Degrees.Dept_Code = '01MDB' then 'FT-JDMBA'
                 when Degrees.Dept_Code = '01MMM' then 'FT-MMM'
                   when Degrees.Dept_Code = '01KEN' then 'FT-KENNEDY' end as dept_code_description,
        RPT_PBH634.ksm_pkg_tmp.to_date2 (degrees.grad_dt) as graduation_date
From degrees 
--- Using Degrees Table, Not Paul's Degree View, so we have to consider the following: 
Where 
--- School = Kellogg
Degrees.School_Code = 'KSM'
--- Degree Code = MBA Holders (People could have multiple KSM degrees, so just pull the MBA) 
AND (Degrees.Degree_Code = 'MBA')
and degrees.dept_code IN 
(--- 1Y MBA
'01KGS1Y',
--- 2Y MBA
'01KGS2Y',
--- FS-MS - KSM MS in Management Studies
'01MMS',
--- FT-JDMBA - Law/Kellogg - JD/MBA
'13JDM',
--- MD/MBA
'01MDB',
--- FT MMM 
'01MMM',
--- Kennedy
'01KEN')),


final_grad as (select d.id_number,
d.dept_code_description,
d.Degree_Year, 
d.graduation_date
from d 
--- Between 10/01/2014 and 09/30/2017
where graduation_date Between to_date ('10/01/2014', 'mm/dd/yyyy')
and to_date ('09/30/2017', 'mm/dd/yyyy')
Order by graduation_date ASC)

/* Final Query 

o  Entity ID
o  EMPL ID
o  First Name
o  Last Name
o  Preferred Email Address
o  Alternative Email Address
o  Degree Program
o  Graduating Year
o  Special Handling Codes (No Contact, No Email) */ 

select entity.id_number,
I.emplid,
entity.first_name,
entity.last_name,
KSM_Email.email_address as preferred_email,
KSM_Alt.Alt_Email as alt_emails,
g.dept_code_description as degree_program,
g.Degree_Year,
g.graduation_date,
KSM_Spec.NO_CONTACT,
KSM_Spec.NO_EMAIL_IND
from entity 
inner join final_grad g on g.id_number = entity.id_number 
left join I on I.id_number = entity.id_number
left join KSM_Email on KSM_Email.id_number = entity.id_number 
left join KSM_Alt on KSM_Alt.id_number = entity.id_number 
left join KSM_Spec on KSM_Spec.id_number = entity.id_number
