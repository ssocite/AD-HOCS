With ksm_giving as
(Select Give.ID_NUMBER,
       give.NGC_LIFETIME,
       give.NU_MAX_HH_LIFETIME_GIVING
From RPT_PBH634.v_Ksm_Giving_Summary Give),

assign as (select assign.id_number,
       assign.prospect_manager,
       assign.lgos,
       assign.managers,
       assign.curr_ksm_manager
from rpt_pbh634.v_assignment_summary assign),

ksm_prospect AS (
Select TP.ID_NUMBER,
       TP.PREF_MAIL_NAME,
       TP.LAST_NAME,
       TP.FIRST_NAME,
       TP.PROSPECT_MANAGER,
       TP.EVALUATION_RATING,
       TP.OFFICER_RATING

From nu_prs_trp_prospect TP
where Tp.Evaluation_Rating IN ('A1 $100M+' ,
'A2 $50M - 99.9M' ,
'A3 $25M - $49.9M'  ,
'A4 $10M - $24.9M'  ,
'A5 $5M - $9.9M'  ,
'A6 $2M - $4.9M'  ,
'A7 $1M - $1.9M'  ,
'B  $500K - $999K'  ,
'C  $250K - $499K'  ,
'D  $100K - $249K'  ,
'E  $50K - $99K'  ,
'F  $25K - $49K'  ,
'G  $10K - $24K'  ,
'H  Under $10K' )
or
TP.OFFICER_RATING IN ('A1 $100M+' ,
'A2 $50M - 99.9M' ,
'A3 $25M - $49.9M'  ,
'A4 $10M - $24.9M'  ,
'A5 $5M - $9.9M'  ,
'A6 $2M - $4.9M'  ,
'A7 $1M - $1.9M'  ,
'B  $500K - $999K'  ,
'C  $250K - $499K'  ,
'D  $100K - $249K'  ,
'E  $50K - $99K'  ,
'F  $25K - $49K'  ,
'G  $10K - $24K'  ,
'H  Under $10K' )),

c as (Select rpt_pbh634.v_addr_continents.country_code,
             rpt_pbh634.v_addr_continents.country,
             rpt_pbh634.v_addr_continents.continent,
             rpt_pbh634.v_addr_continents.KSM_Continent
from rpt_pbh634.v_addr_continents
where continent = 'South America'
or KSM_Continent = 'Latin_America'),

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


Select
house.id_number,
house.REPORT_NAME,
house.RECORD_STATUS_CODE,
house.FIRST_KSM_YEAR,
house.PROGRAM,
house.HOUSEHOLD_CITY,
house.HOUSEHOLD_STATE,
house.HOUSEHOLD_COUNTRY,
employ.job_title,
employ.employer_name,
assign.prospect_manager,
assign.lgos,
ksm_prospect.EVALUATION_RATING,
ksm_prospect.OFFICER_RATING,
ksm_giving.NGC_LIFETIME as KSM_NGC_Lifetime,
ksm_giving.NU_MAX_HH_LIFETIME_GIVING

From rpt_pbh634.v_entity_ksm_households house
Inner Join ksm_prospect ON ksm_prospect.ID_NUMBER = house.id_number
Left Join ksm_giving ON ksm_giving.id_number = house.id_number
Left Join assign on assign.id_number = house.ID_number
Left Join employ on employ.id_number = house.id_number
Inner Join c on c.country = house.HOUSEHOLD_COUNTRY
Where house.PROGRAM_GROUP is not null
and house.RECORD_STATUS_CODE NOT Like 'C'
Order By house.HOUSEHOLD_COUNTRY ASC
