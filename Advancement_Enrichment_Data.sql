With KSM_Email AS (select email.id_number,
       email.email_address,
       email.preferred_ind
From email
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = email.id_number
Where email.preferred_ind = 'Y'),

KSM_telephone AS (Select t.id_number, t.telephone_number, t.area_code
From telephone t
Inner Join rpt_pbh634.v_entity_ksm_degrees deg ON deg.ID_NUMBER = t.id_number
Where t.preferred_ind = 'Y'),

KSM_Give AS (Select give.ID_NUMBER,
give.NGC_LIFETIME
from rpt_pbh634.v_ksm_giving_summary give
where give.NGC_LIFETIME >= 100000),

--- Linkedin Subquery

linked as (select distinct ec.id_number,
max(ec.start_dt) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) As Max_Date,
max (ec.econtact) keep(dense_rank First Order By ec.start_dt Desc, ec.econtact asc) as linkedin_address
from econtact ec
where  ec.econtact_status_code = 'A'
and  ec.econtact_type_code = 'L'
Group By ec.id_number)

select distinct deg.id_number,
       entity.first_name,
       entity.last_name,
       deg.PROGRAM_GROUP,
       deg.FIRST_KSM_YEAR,
       KSM_telephone.area_code,
       KSM_telephone.telephone_number,
       KSM_Email.email_address,
       entity.birth_dt,
       KSM_GIVE.NGC_LIFETIME,
       linked.linkedin_address

from rpt_pbh634.v_entity_ksm_degrees deg
Inner join KSM_Give ON KSM_Give.id_number = deg.ID_NUMBER
left join entity on entity.id_number = deg.ID_NUMBER
left join KSM_Email on KSM_Email.id_number = deg.id_number
left join KSM_telephone on KSM_telephone.id_number = deg.id_number
left join linked on linked.id_number = deg.ID_NUMBER

UNION

select distinct deg.id_number,
       entity.first_name,
       entity.last_name,
       deg.PROGRAM_GROUP,
       deg.FIRST_KSM_YEAR,
       KSM_telephone.area_code,
       KSM_telephone.telephone_number,
       KSM_Email.email_address,
       entity.birth_dt,
       KSM_GIVE.NGC_LIFETIME,
       linked.linkedin_address
from rpt_pbh634.v_entity_ksm_degrees deg
left join KSM_Give ON KSM_Give.id_number = deg.ID_NUMBER
left join entity on entity.id_number = deg.ID_NUMBER
left join KSM_Email on KSM_Email.id_number = deg.id_number
left join KSM_telephone on KSM_telephone.id_number = deg.id_number
left join linked on linked.id_number = deg.ID_NUMBER
where deg.FIRST_KSM_YEAR IN ('1975','1976','1977','1978','1979','1980','1981','1982','1983','1984','1985','1986','1987','1988',
'1989','1990','1991','1992','1993','1994','1995')
and deg.PROGRAM_GROUP IN ('FT','EMP')