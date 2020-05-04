--- Pulling KSM Alumni involved in Treks. 

Select Activity.Id_Number,
       deg.REPORT_NAME,
       deg.RECORD_STATUS_CODE,
       deg.FIRST_KSM_YEAR,
       deg.PROGRAM,
       Activity.Start_Dt,
       Activity.Stop_Dt,
       Activity.Activity_Code,
       TMS_ACTIVITY_TABLE.short_desc,
       Activity.Xcomment,
       Activity.Date_Added,
       Activity.Date_Modified,
       Activity.Operator_Name
From Activity 
Left Join TMS_ACTIVITY_TABLE ON TMS_ACTIVITY_TABLE.activity_code = Activity.Activity_Code
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = activity.id_number
Where Activity.Activity_Code = 'KAGT'
Order By Deg.REPORT_NAME ASC
