with a as (select aff.id_number,
             aff.affil_code,
             aff.affil_status_code,
             aff.affil_level_code,
             aff.record_type_code,
        TMS_AFFILIATION_LEVEL.short_desc as aff_status_desc,
        TMS_AFFIL_STATUS.short_desc as status,
        Listagg (TMS_AFFIL_CODE.short_desc, ';  ') Within Group (Order By TMS_AFFIL_CODE.short_desc)  as school
from affiliation aff
left join TMS_AFFIL_CODE on TMS_AFFIL_CODE.affil_code = aff.affil_code
left join TMS_AFFILIATION_LEVEL on TMS_AFFILIATION_LEVEL.affil_level_code = aff.affil_level_code
left join TMS_AFFIL_STATUS on TMS_AFFIL_STATUS.affil_status_code = aff.affil_status_code
 WHERE  aff.affil_level_code = 'AU'
   AND  aff.record_type_code = 'ST'
   Group By aff.id_number,
             aff.affil_code,
             aff.affil_status_code,
             aff.affil_level_code,
             aff.record_type_code,
        TMS_AFFILIATION_LEVEL.short_desc,
        TMS_AFFIL_STATUS.short_desc),

assignment as (select assign.id_number,
       assign.prospect_manager,
       assign.lgos,
       assign.managers,
       assign.curr_ksm_manager
from rpt_pbh634.v_assignment_summary assign),

employ As (
  Select id_number
  , employment.employer_id_number
  , employment.job_status_code
  , employment.primary_emp_ind
  , employment.fld_of_work_code
  , job_title
  , Case
      When trim(employer_id_number) Is Not Null And employer_id_number != ' ' Then (
        Select pref_mail_name
        From entity
        Where id_number = employer_id_number)
      Else trim(employer_name1 || ' ' || employer_name2)
    End As employer_name
  , employment.stop_dt
  , employment.date_modified
  From employment
Where employment.primary_emp_ind = 'Y'
and employment.job_status_code = 'C'),

KSM_Give AS (Select give.ID_NUMBER,
give.NGC_LIFETIME,
give.LAST_GIFT_DATE
from rpt_pbh634.v_ksm_giving_summary give),

TP AS (select tp.id_number, tp.pref_mail_name, TP.evaluation_rating, TP.Officer_rating
from nu_prs_trp_prospect TP),

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.SPECIAL_HANDLING_CONCAT,
       spec.GAB,
       spec.TRUSTEE,
       spec.EBFA,
       spec.NO_CONTACT,
       spec.NO_PHONE_IND,
       spec.NO_EMAIL_IND,
       spec.NO_MAIL_IND
From rpt_pbh634.v_entity_special_handling spec)

select distinct relationship.id_number,
       deg.report_name,
       entity.institutional_suffix,
       entity.record_type_code,
       entity.record_status_code,
       deg.FIRST_KSM_YEAR,
       deg.PROGRAM,
       deg.DEGREES_VERBOSE,
       relationship.relation_id_number,
       ---- entity 2 = the child's name. Join on entity and relation ID (Which is the Child's ID)
       entity2.report_name as child_name,
       TMS_RELATIONSHIPS.short_desc as relationship_type,
        entity2.record_type_code as child_record_type,
        entity2.institutional_suffix as child_ins_suffix,
        --- Created Calc to find Seniors, Juniors, Soph, and Freshmen
               case when entity2.institutional_suffix like '%23%' then 'Senior'
                 when entity2.institutional_suffix like '%22%' then 'Senior'
         when entity2.institutional_suffix like '%24%' then 'Junior'
           when entity2.institutional_suffix like '%25%' then 'Sophomore'
             when entity2.institutional_suffix like '%26%' then 'Freshman' End as child_class_year,
        a.aff_status_desc as child_aff,
        a.status as child_enrollment_status,
       assignment.lgos,
       assignment.prospect_manager,
       TP.evaluation_rating,
       TP.Officer_rating,
       KSM_Give.NGC_LIFETIME,
       KSM_Give.LAST_GIFT_DATE,
       assignment.prospect_manager,
       assignment.lgos,
       employ.job_status_code,
       employ.job_title as current_job_title,
       employ.employer_name as current_employer_name,
       house.FIRST_KSM_YEAR,
       house.PROGRAM,
       house.PROGRAM_GROUP,
       house.HOUSEHOLD_CITY,
       house.HOUSEHOLD_STATE,
       house.HOUSEHOLD_COUNTRY,
       s.SPECIAL_HANDLING_CONCAT,
       s.GAB,
       s.TRUSTEE,
       s.EBFA,
       s.NO_CONTACT,
       s.NO_PHONE_IND,
       s.NO_EMAIL_IND,
       s.NO_MAIL_IND
--- The Relationship Table will be my based due to ad-hoc request
from relationship
--- Entity of Alumni
left join entity on entity.id_number = relationship.id_number
--- Just Want KSM Alumni
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.id_number = relationship.id_number
--- Entity of Alumni child - Join entity on relation.id_number (this is the ID of the child)
left join entity entity2 on entity2.id_number = relationship.relation_id_number
    --- Relationship Table
left join TMS_RELATIONSHIPS on TMS_RELATIONSHIPS.relation_type_code = relationship.relation_type_code
--- A = Affilation
--- The Inner Join will help us just get the entities that are children who are just Undergrad NU alumni
inner join a on a.id_number = relationship.relation_id_number
---- Standard Points in Sara's Ad-Hocs
left join assignment on assignment.id_number = relationship.id_number
Left join employ on employ.id_number = relationship.ID_NUMBER
left join KSM_Give on KSM_Give.id_number = relationship.id_number
left join TP on TP.id_number = relationship.id_number
left join rpt_pbh634.v_entity_ksm_households house on house.id_number = relationship.id_number
left join KSM_spec s on s.id_number = relationship.id_number
--- We Just want KSM alumni with a child that is a undergrad student at NU
--- the A subquery accounts for the undergrad students at NU, now just need to add where clause of """"Child""""
where TMS_RELATIONSHIPS.short_desc = 'Grandchild'
order by deg.report_name ASC
