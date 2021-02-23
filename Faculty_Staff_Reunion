With reunion_pref as (select A.ID_NUMBER,
TMS_AFFILIATION_LEVEL.short_desc,
a.class_year

FROM AFFILIATION A
INNER JOIN rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = a.id_number
LEFT JOIN TMS_AFFILIATION_LEVEL ON TMS_AFFILIATION_LEVEL.affil_level_code = a.affil_level_code
WHERE A.AFFIL_CODE = 'KM'
AND A.AFFIL_LEVEL_CODE = 'RG'
AND a.class_year IN ('2020','2016','2011','2006','2001','1996','1991','1986','1981','1976','1971','1970',
'1969','1968','1967','1966','1965','1964','1963','1962','1961')),

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
),

second_employ As (
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
  Where employment.employ_relat_code = 'SE'
  And employment.employer_id_number = '0000439808'

)

SELECT
A.ID_NUMBER,
deg.report_name,
employ.job_title,
employ.employer_name,
second_employ.job_title as secondary_jobtitle,
second_employ.employer_name as secondary_employer,
TMS_AFFILIATION_LEVEL.short_desc as Faculty_Staff_Desc,
A.AFFIL_STATUS_CODE,
reunion_pref.class_year as Reunion_Class_Year,
deg.PROGRAM,
deg.PROGRAM_GROUP,
house.HOUSEHOLD_CITY,
house.HOUSEHOLD_GEO_PRIMARY_DESC,
house.HOUSEHOLD_STATE,
house.HOUSEHOLD_COUNTRY,
house.HOUSEHOLD_ZIP


FROM AFFILIATION A
INNER JOIN rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = a.id_number
LEFT JOIN TMS_AFFILIATION_LEVEL ON TMS_AFFILIATION_LEVEL.affil_level_code = a.affil_level_code
Left join rpt_pbh634.v_entity_ksm_households house on house.ID_NUMBER = a.id_number
Left Join employ on employ.id_number = a.id_number
Left Join second_employ on second_employ.id_number = a.id_number
Inner Join reunion_pref on reunion_pref.id_number = a.id_number
WHERE A.AFFIL_CODE = 'KM'
AND A.AFFIL_LEVEL_CODE IN ('ES','EF')
AND A.AFFIL_STATUS_CODE = 'C'
AND deg.RECORD_STATUS_CODE IN ('A','L')
Order BY reunion_pref.class_year ASC
