With org_employer As 
(Select id_number, report_name
From entity 
Where entity.person_or_org = 'O')

--- Employment Past and Present
Select employ.id_Number AS catracks_id,
       employ.start_dt As start_date,
       rpt_pbh634.ksm_pkg.to_date2 (employ.start_dt) As employ_start_date,
       employ.Stop_Dt As stop_date,
       rpt_pbh634.ksm_pkg.to_date2 (employ.Stop_Dt) As employt_stop_date,
       employ.job_status_code As job_status,
       employ.primary_emp_Ind AS primary_employer_indicator,
       employ.self_employ_Ind As self_employed_indicator,
       employ.employer_id_Number,     
       org_employer.report_name,
       (Case When Employ.Employer_Name1 = ' ' then org_employer.report_name Else Employ.Employer_Name1 End) As Employer_Concat,       
       employ.employer_name1 As employer_name,
       employ.job_title,
       employ.fld_of_work_code As fld_of_work_code_desc,
       fow.short_desc,
       employ.date_added,
       employ.date_modified,
       employ.operator_name
       


From employment employ
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = employ.id_number
Inner Join tms_fld_of_work fow on employ.fld_of_work_code = fow.fld_of_work_code
Left Join org_employer ON org_employer.id_number = employ.employer_id_number
Where employ.job_status_code IN ('C','P','Q','R', ' ', 'L')
--- Employment Key: C = Current, P = Past, Q = Semi Retired R = Retired L = On Leave 

--- Case when name is blank, then do something, else do something else
