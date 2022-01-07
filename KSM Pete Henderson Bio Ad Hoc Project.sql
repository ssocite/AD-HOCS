/* Statistics on the group:
•  How many are managed - Counting via KSM Managers - Used Assignments
•  How many are rated $1M+ - Get Evaluation Ratings - Use Eval and Officer Ratings Subquery
•  How many are rated $250K+ - Get Evaluation Ratings - Use Eval and Officer Ratings Subquery
•  How many are major gift donors? - What is a major gift donor? - Use 100K + Lifetime NGC
•  How many are Kellogg Leadership Circle donors? - Use KLC code from datamart
•  How many are donors? - Let's do a count of donors - donors would be lifetime NGC > 0.

Statistics on our current programming to date:

Use Amy's Report on Tableau - Download Full Data and Then Create a Pivot Table

•  Attendees - Look for PHS Events - Do a case when and pull attendance - might have to do it by name
•  Attendees who are donors - 
•  Cvent giving from programming- We will have to pull this from Cvent or Check Amy's Report*/


--- Current PHS Members

With PHS AS  (select phs.id_number,
       phs.committee_code,
       phs.short_desc,
       phs.status
From table (rpt_pbh634.ksm_pkg.tbl_committee_phs) phs),

--- Household View for Basic Data Points

h As (select *
FROM rpt_pbh634.v_entity_ksm_households),

---- Giving subquery to reference

g As (select *
FROM rpt_pbh634.v_ksm_giving_summary give),

--- Major Gift Subquery 

mg as (select g.ID_NUMBER,
g.NGC_LIFETIME
from g
where g.NGC_LIFETIME > 100000),

--- Donor Indicator
---- Combine these indicators into a case when

cd as (select g.ID_NUMBER,
g.NGC_LIFETIME
from g
where g.NGC_LIFETIME > 0),

--- assignment Prospect Manager + LGO (Assignment Summary)

assign AS (Select a.id_number,
a.lgos,
a.prospect_manager,
a.managers,
a.curr_ksm_manager
From rpt_pbh634.v_assignment_summary a),

--- Eval and Officer Ratings

ratings as (select distinct 
TP.ID_NUMBER,
Tp.Evaluation_Rating,
Tp.Officer_Rating
From nu_prs_trp_prospect TP),

--- Million Plus Ratings

Million As (select 
ratings.ID_NUMBER,
ratings.Evaluation_Rating,
ratings.Officer_Rating
From ratings
where ratings.Evaluation_Rating like '%A%'
or ratings.Officer_Rating like '%A%'),

--- At Least 250K Ratings

c as (select distinct 
ratings.ID_NUMBER,
ratings.Evaluation_Rating,
ratings.Officer_Rating
From ratings
where (ratings.Evaluation_Rating like '%A%'
or ratings.Evaluation_Rating like '%B%'
or ratings.Evaluation_Rating like '%C%')
or (ratings.Officer_Rating like '%A%'
or ratings.Officer_Rating like '%B%'
or ratings.Officer_Rating like '%C%')),

--- KLC Donor Level Last 5 Years 
--- KLC = Over $2500 in any of the last 5 years (CRU From Giving Summary)

KLC as (select g.ID_NUMBER,
g.CRU_CFY,
g.CRU_PFY1,
g.CRU_PFY2,
g.CRU_PFY3,
g.CRU_PFY4,
g.CRU_PFY5
FROM g
where g.CRU_CFY > 2500
or g.CRU_PFY1 > 2500
or g.CRU_PFY2 > 2500
or g.CRU_PFY3 > 2500
or g.CRU_PFY4 > 2500
or g.CRU_PFY5 > 2500)

--- Household as Base
 
select h.ID_NUMBER,
       h.REPORT_NAME,
       PHS.short_desc as PHS_IND,
       h.RECORD_STATUS_CODE,
       h.FIRST_KSM_YEAR,
       h.PROGRAM,
       h.PROGRAM_GROUP,
       h.INSTITUTIONAL_SUFFIX,
       h.HOUSEHOLD_CITY,
       h.HOUSEHOLD_STATE,
       h.HOUSEHOLD_ZIP,
       h.HOUSEHOLD_GEO_CODES,
       h.HOUSEHOLD_COUNTRY,
       assign.lgos,
       assign.prospect_manager,
       assign.managers,
       assign.curr_ksm_manager,
       g.NGC_Lifetime,
       ---- Overal Donor Indicator
       case when cd.id_number is not null then 'Donor' Else '' End as Donor_IND,
         ---- AF Giving Check to compare KLC Indicator
       g.CRU_CFY,
       g.CRU_PFY1,
g.CRU_PFY2,
g.CRU_PFY3,
g.CRU_PFY4,
g.CRU_PFY5,
--- KLC Donors IND
       case when klc.id_number is not null then 'KLC' else '' END as KLC_Membership,
--- Major Gift Donor IND
       case when mg.id_number is not null then 'Major_Gift_Donor' Else '' END As Major_Gift,
--- Overall Eval and Officer Rating
         ratings.Evaluation_Rating,
         ratings.Officer_Rating,
--- 1M+ Eval and Officer Ratings IND
         case when million.id_number is not null then '1M+_Evaluation' Else '' END as One_Million_Eval,
--- 250K+ Eval and Officer Ratings
         case when c.ID_NUMBER is not null then '250K+_Evaluation' Else '' END as Eval_250K
         
from h
--- Inner Join PHS
inner join phs on phs.id_number = h.id_number
--- major gits
left join mg on mg.id_number = h.id_number 
--- gift subquery
left join g on g.id_number = h.id_number
--- overall ratings
left join ratings on ratings.id_number = h.id_number
--- million plus ratings
left join million on million.id_number = h.id_number
--- 250K+ Ratings
left join c on c.id_number = h.id_number
--- KLC Membership
left join klc on klc.id_number = h.id_number
--- Donor Indicator 
left join cd on cd.id_number = h.id_number
--- Managers
left join assign on assign.id_number = h.id_number

