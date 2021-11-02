Select mailing_list.id_number,
       mailing_list.stop_dt,
       mailing_list.start_dt,
       mailing_list.xcomment
FROM  mailing_list
WHERE  mail_list_code = '100' 
AND  UPPER(xcomment) LIKE 'KSM NOTABLE ALUMNI%'
