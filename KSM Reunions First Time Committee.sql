With AFF AS (
SELECT
A.ID_NUMBER, 
A.CLASS_YEAR
FROM AFFILIATION A
WHERE A.AFFIL_CODE = 'KM'
AND A.AFFIL_LEVEL_CODE = 'RG'
),

REUNION AS (select committee.id_number,
       committee.committee_code,
       committee.start_dt,
       committee.stop_dt,
       TMS_COMMITTEE_TABLE.short_desc,
       committee.committee_status_code,
       committee.date_added,
       committee.date_modified,
       committee.operator_name
FROM committee
Left Join TMS_COMMITTEE_TABLE on committee.committee_code = TMS_COMMITTEE_TABLE.committee_code
where committee.committee_code = '227'
and committee.committee_status_code = 'F'),

first_time as (select house.id_number,
       house.REPORT_NAME,
       house.DEGREES_CONCAT,
       deg.DEGREES_VERBOSE,
       deg.PROGRAM,
       deg.PROGRAM_GROUP,
       deg.CLASS_SECTION,
       aff.CLASS_YEAR,
case when Reunion.start_dt = 20180901  and aff.class_year = '2018' then 'Y' else '' END As First_Milestone_Reunion_2019,
  case when Reunion.start_dt = 20170901 and aff.class_year = '2017'  then 'Y' else '' END As First_Milestone_Reunion_2018,
    case when Reunion.start_dt = 20160901 and aff.class_year = '2016' then 'Y' else '' END As First_Milestone_Reunion_2017,
      case when Reunion.start_dt = 20150901 and aff.class_year = '2015'  then 'Y' else '' END As First_Milestone_Reunion_2016,
       REUNION.short_desc,
       REUNION.committee_code,
       REUNION.start_dt,
       REUNION.stop_dt,
       REUNION.committee_status_code,
       REUNION.date_added,
       REUNION.date_modified
from rpt_pbh634.v_entity_ksm_households house
inner Join REUNION on REUNION.id_number = house.id_number 
left Join AFF on AFF.id_number = house.id_number
left join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = house.ID_NUMBER
where aff.CLASS_YEAR IN ('2015','2016','2017','2018')
order by aff.class_year DESC )


select first_time.id_number,
       first_time.REPORT_NAME,
       first_time.DEGREES_VERBOSE,
       first_time.CLASS_YEAR as Reunion_AFFILIATION_Year,
       first_time.First_Milestone_Reunion_2019,
       first_time.First_Milestone_Reunion_2018,
       first_time.First_Milestone_Reunion_2017,
       first_time.First_Milestone_Reunion_2016,
       first_time.short_desc,
       first_time.committee_code,
       first_time.start_dt,
       first_time.stop_dt,
       first_time.committee_status_code,
       first_time.date_added,
       first_time.date_modified
from first_time
where (first_time.First_Milestone_Reunion_2019 is not null 
       or first_time.First_Milestone_Reunion_2018 is not null 
       or first_time.First_Milestone_Reunion_2017 is not null 
       or first_time.First_Milestone_Reunion_2016 is not null )
