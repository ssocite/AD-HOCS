with ksm_event AS (select event.event_id,
       event.event_name,
       event.event_type,
       event.event_type_desc,
       event.start_dt,
       event.stop_dt,
       event.start_dt_calc
from rpt_pbh634.v_nu_events event



where event.event_id in ('23644','23376','23671','23013','23767','23334','23766','23787','23765','23777','24350','24265',
'24181','24223','24110','24033','24031','24020','24304','24303','23786','23671','23798','23799','23800','23805','23806','23804',
'23801','23802','23803','23797')
Order By event.start_dt ASC),

ksm_give as (select give.ID_NUMBER,
                      give.HOUSEHOLD_ID,
                      give.NGC_CFY,
                      give.NGC_PFY1,
                      give.NGC_PFY2,
                      give.NGC_PFY3,
                      give.NGC_PFY4,
                      give.NGC_PFY5,
                      give.LAST_GIFT_TX_NUMBER,
                      give.LAST_GIFT_DATE,
                      give.LAST_GIFT_TYPE,
                      give.LAST_GIFT_ALLOC_CODE,
                      give.LAST_GIFT_ALLOC
from rpt_pbh634.v_ksm_giving_summary give),

ksm_model as (select models.id_number,
       models.segment_year,
       models.segment_month,
       models.id_code,
       models.id_segment,
       models.id_score,
       models.pr_code,
       models.pr_segment,
       models.pr_score,
       models.est_probability
from rpt_pbh634.v_ksm_model_mg models),

assignment as (select assign.id_number,
       assign.prospect_manager,
       assign.lgos,
       assign.managers,
       assign.curr_ksm_manager
from rpt_pbh634.v_assignment_summary assign),

employ as (
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
  Where employment.primary_emp_ind = 'Y'),

interest as (select distinct rpt_pbh634.v_datamart_career_interests.catracks_id,
Listagg (rpt_pbh634.v_datamart_career_interests.interest_desc, ';  ') Within Group (Order By rpt_pbh634.v_datamart_career_interests.interest_desc) As interest_desc
from rpt_pbh634.v_datamart_career_interests
group by rpt_pbh634.v_datamart_career_interests.catracks_id),

Finance AS (select Distinct interest.catracks_id,
interest.interest_desc
from rpt_pbh634.v_datamart_career_interests interest
where interest.interest_code IN ('L43')),

Consulting AS (select Distinct interest.catracks_id,
interest.interest_desc
from rpt_pbh634.v_datamart_career_interests interest
where interest.interest_code IN ('L81')),

Marketing AS (select Distinct interest.catracks_id,
interest.interest_desc
from rpt_pbh634.v_datamart_career_interests interest
where interest.interest_code IN ('L84')),

IT AS (select Distinct interest.catracks_id,
interest.interest_desc
from rpt_pbh634.v_datamart_career_interests interest
where interest.interest_code IN ('L64')),

Building AS (select Distinct interest.catracks_id,
interest.interest_desc
from rpt_pbh634.v_datamart_career_interests interest
where interest.interest_code IN ('L14')),

Food AS (select Distinct interest.catracks_id,
interest.interest_desc
from rpt_pbh634.v_datamart_career_interests interest
where interest.interest_code IN ('L46')),

Health AS (select Distinct interest.catracks_id,
interest.interest_desc
from rpt_pbh634.v_datamart_career_interests interest
where interest.interest_code IN ('L55')),

Pharmaceuticals AS (select Distinct interest.catracks_id,
interest.interest_desc
from rpt_pbh634.v_datamart_career_interests interest
where interest.interest_code IN ('LRX')),

Real_Estate AS (select Distinct interest.catracks_id,
interest.interest_desc
from rpt_pbh634.v_datamart_career_interests interest
where interest.interest_code IN ('LRE')),

Education AS (select Distinct interest.catracks_id,
interest.interest_desc
from rpt_pbh634.v_datamart_career_interests interest
where interest.interest_code IN ('L34'))

select distinct participant.id_number,
       participant.event_id,
       participant.report_name,
       house.FIRST_KSM_YEAR,
       house.PROGRAM,
       house.PROGRAM_GROUP,
       house.HOUSEHOLD_CITY,
       house.HOUSEHOLD_STATE,
       house.HOUSEHOLD_ZIP,
       house.HOUSEHOLD_GEO_CODES,
       house.HOUSEHOLD_COUNTRY,
       participant.degrees_concat,
       participant.event_name,
       participant.start_dt,
       participant.start_fy_calc,
       participant.event_type,
       employ.job_title,
       employ.employer_name,
       employ.fld_of_work,
       interest.interest_desc as interest_concat,
       finance.interest_desc as finance_Interest,
       consulting.interest_desc as consulting_interest,
       marketing.interest_desc as marketing_interest,
       IT.interest_desc as IT_interest,
       Building.interest_desc as building_interest,
       Food.interest_desc as food_interest,
       Health.interest_desc as health_interest,
       Pharmaceuticals.interest_desc as Pharmaceuticals_interest,
       Real_Estate.interest_desc as Real_Estate_interest,
       education.interest_desc as education_interest,
       ksm_give.NGC_CFY,
       ksm_give.NGC_PFY1,
       ksm_give.NGC_PFY2,
       ksm_give.NGC_PFY3,
       ksm_give.NGC_PFY4,
       ksm_give.NGC_PFY5,
       ksm_give.LAST_GIFT_TX_NUMBER,
       ksm_give.LAST_GIFT_DATE,
       ksm_give.LAST_GIFT_TYPE,
       ksm_give.LAST_GIFT_ALLOC_CODE,
       ksm_give.LAST_GIFT_ALLOC,
       ksm_model.id_segment,
       ksm_model.id_score,
       ksm_model.pr_segment,
       ksm_model.pr_score,
       assignment.prospect_manager,
       assignment.lgos,
       assignment.managers,
       assignment.curr_ksm_manager
from rpt_pbh634.v_nu_event_participants_fast participant
inner join ksm_event on ksm_event.event_id = participant.event_id
left join rpt_pbh634.v_entity_ksm_households house on house.ID_NUMBER = participant.id_number
left join ksm_give on ksm_give.HOUSEHOLD_ID = participant.id_number
left join Finance on finance.catracks_id = participant.id_number
left join Consulting on consulting.catracks_id = participant.id_number
left join Marketing on marketing.catracks_id = participant.id_number
left join IT on IT.catracks_id = participant.id_number
left join Building on Building.catracks_id = participant.id_number
left join Food on Food.catracks_id = participant.id_number
left join Health on Health.catracks_id = participant.id_number
left join Pharmaceuticals on Pharmaceuticals.catracks_id = participant.id_number
left join Real_Estate on Real_Estate.catracks_id = participant.id_number
left join Education on Education.catracks_id = participant.id_number
left join ksm_model on ksm_model.id_number = participant.id_number
left join assignment on assignment.id_number = participant.id_number
left join employ on employ.id_number = participant.id_number
left join interest on interest.catracks_id = participant.id_number
left join Finance on Finance.catracks_id = participant.id_number
left join Consulting on Consulting.catracks_id = participant.id_number
order by participant.report_name asc
