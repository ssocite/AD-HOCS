With
-- Employment table subquery
employ As (
  Select id_number
  , job_title
  , employment.fld_of_work_code
  , fow.short_desc As fld_of_work
  , employer_name1,
    -- If there's an employer ID filled in, use the entity name
    Case
      When employer_id_number Is Not Null And employer_id_number != ' ' Then (
        Select pref_mail_name
        From entity
        Where id_number = employer_id_number)
      -- Otherwise use the write-in field
      Else trim(employer_name1 || ' ' || employer_name2)
    End As employer_name
  From employment
  Left Join tms_fld_of_work fow
       On fow.fld_of_work_code = employment.fld_of_work_code
  Where employment.primary_emp_ind = 'Y'
)

SELECT mail.id_number,
       house.REPORT_NAME,
       mail.mail_list_code,
       TMS_MAIL_LIST_CODE.short_desc,
       mail.start_dt,
       mail.xcomment,
       employ.job_title,
       employ.employer_name
  FROM  mailing_list mail 
  left join TMS_MAIL_LIST_CODE on TMS_MAIL_LIST_CODE.mail_list_code_code = mail.mail_list_code
  left join rpt_pbh634.v_entity_ksm_households house on house.ID_NUMBER = mail.id_number
  left join employ on employ.id_number = mail.id_number 
 WHERE  mail.xcomment LIKE '%Fortune 500%'
 --- mail code of 100 = famous person in CATracks
 and mail.mail_list_code = '100'
 order BY employ.employer_name ASC
