with a as (select aff.id_number,
             aff.affil_code,
             aff.affil_status_code,
             aff.affil_level_code,
             aff.record_type_code
from affiliation aff
 WHERE  aff.affil_level_code = 'AU'
   AND  aff.record_type_code = 'ST'),
   
assignment as (select assign.id_number,
       assign.prospect_manager,
       assign.lgos,
       assign.managers,
       assign.curr_ksm_manager
from rpt_pbh634.v_assignment_summary assign)

select relationship.id_number,
       deg.report_name,
       entity.institutional_suffix,
       deg.FIRST_MASTERS_YEAR,
       deg.PROGRAM,
       assignment.lgos,
       assignment.prospect_manager,
       relationship.relation_id_number,
       case when relationship.relation_name = ' 'then entity2.pref_mail_name
         when relationship.relation_name is not null then relationship.relation_name
           else ' ' End as realtionship_name,
       TMS_RELATIONSHIPS.short_desc as relationship_type,
       entity2.record_type_code,
        entity2.institutional_suffix,
        TMS_AFFILIATION_LEVEL.short_desc as aff_status_desc,
        TMS_AFFIL_STATUS.short_desc as status,
        TMS_AFFIL_CODE.short_desc as school
    from relationship
left join entity on entity.id_number = relationship.id_number
left join entity entity2 on entity2.id_number = relationship.relation_id_number
left join TMS_RELATIONSHIPS on TMS_RELATIONSHIPS.relation_type_code = relationship.relation_type_code
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.id_number = relationship.id_number
left Join rpt_pbh634.v_entity_ksm_degrees deg1 on deg1.id_number = relationship.relation_id_number
left join a on a.id_number = relationship.relation_id_number
left join TMS_AFFIL_CODE on TMS_AFFIL_CODE.affil_code = a.affil_code
left join TMS_AFFILIATION_LEVEL on TMS_AFFILIATION_LEVEL.affil_level_code = a.affil_level_code
left join TMS_AFFIL_STATUS on TMS_AFFIL_STATUS.affil_status_code = a.affil_status_code
left join assignment on assignment.id_number = entity.id_number
where TMS_RELATIONSHIPS.short_desc = 'Child'
and entity2.record_type_code = 'ST'
and a.affil_level_code = 'AU'
order by relationship.id_number ASC
