Select rpt_pbh634.v_entity_nametags.id_number,
       rpt_pbh634.v_entity_nametags.pref_mail_name,
       rpt_pbh634.v_entity_nametags.record_status_code,
       rpt_pbh634.v_entity_nametags.institutional_suffix,
       rpt_pbh634.v_entity_nametags.degrees_concat,
       rpt_pbh634.v_entity_nametags.pref_first_name_source,
       rpt_pbh634.v_entity_nametags.pref_first_name,
       rpt_pbh634.v_entity_nametags.first_name,
       rpt_pbh634.v_entity_nametags.middle_name,
       rpt_pbh634.v_entity_nametags.last_name,
       rpt_pbh634.v_entity_nametags.pers_suffix,
       rpt_pbh634.v_entity_nametags.nu_degrees_string
From rpt_pbh634.v_entity_nametags
Where id_number In ()
order by rpt_pbh634.v_entity_nametags.last_name ASC
