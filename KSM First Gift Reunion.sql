With subquery AS (
--- First Time Making a Gift
select
household_id,
min (date_of_record) As minimum_dor
From rpt_pbh634.v_ksm_giving_trans_hh gth
 Where
  -- Not counting matching gifts
  gth.tx_gypm_ind <> 'M'
  -- Sum of Gifts Over $0
 And gth.RECOGNITION_CREDIT > 0
  Group By
  household_id
  )


select

--- Pull Household View: ID Number, Report Namae, Program Year + Group
rpt_pbh634.v_entity_ksm_households.ID_NUMBER,
rpt_pbh634.v_entity_ksm_households.REPORT_NAME,
rpt_pbh634.v_entity_ksm_households.HOUSEHOLD_KSM_YEAR,
rpt_pbh634.v_entity_ksm_households.DEGREES_CONCAT,
rpt_pbh634.v_entity_ksm_households.HOUSEHOLD_PROGRAM_GROUP,


--- Pull Through First Time Giver View: HouseHold ID, Minimum Date of Gift
subquery.household_id,
subquery.minimum_dor,



--- Pull From Market Sheet Events View: Event ID, Name, Status, Start Date
vt_alumni_clubs_engagement.Event_Id,
vt_alumni_clubs_engagement.Event_Name,
vt_alumni_clubs_engagement.Event_Status_Code,
vt_alumni_clubs_engagement.Event_Start_Datetime

--- Household view will be the Base

From rpt_pbh634.v_entity_ksm_households

--- Left Join First Time Giver View on Household ID

Left Join subquery ON rpt_pbh634.v_entity_ksm_households.HOUSEHOLD_ID = subquery.household_id

---- Left Join Event View on ID Number

Left Join vt_alumni_clubs_engagement ON vt_alumni_clubs_engagement.Id_Number = rpt_pbh634.v_entity_ksm_households.ID_NUMBER


--- First Donation Between 05-05-2019 to 08-31-2019


Where minimum_dor Between To_Date ('20190505', 'yyyymmdd') And To_Date ('20191231', 'yyyymmdd')

--- Number of first time gifts by Reunion 2018 attendees, between 5/5/19-12/31/19

And

--- Searching for 2019 Reunion Only

vt_alumni_clubs_engagement.Event_Name = 'KSM19 Reunion Weekend'

Order By minimum_dor ASC
