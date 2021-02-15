---- Edit 12.17.2020 : Only Include 1Y, 2Y, JDMBA, MDMBA, MMM 


With Degrees As (select deg.ID_NUMBER,
deg.REPORT_NAME,
deg.RECORD_STATUS_CODE,
deg.PROGRAM,
deg.PROGRAM_GROUP,
deg.FIRST_KSM_YEAR
from rpt_pbh634.v_entity_ksm_degrees deg
where deg.FIRST_KSM_YEAR >= 1980
and deg.PROGRAM in ('FT-1Y','FT-2Y','FT-JDMBA','FT-MDMBA', 'FT-MMM')),

--- KALC

KALC AS (
select kalc.id_number,
kalc.short_desc
from table (rpt_pbh634.ksm_pkg.tbl_committee_KALC) kalc),

--- Trustee

Trustee AS (
select trustee.id_number,
trustee.short_desc
from table (rpt_pbh634.ksm_pkg.tbl_committee_trustee) trustee),

--- GAB

GAB AS (select gab.id_number,
gab.short_desc
from table (rpt_pbh634.ksm_pkg.tbl_committee_gab) gab),

--- KAC

KAC as (select kac.id_number,
kac.short_desc
from table (rpt_pbh634.ksm_pkg.tbl_committee_kac) kac),


--- PHS

PHS as (select phs.id_number,
phs.short_desc
from table (rpt_pbh634.ksm_pkg.tbl_committee_phs) phs),

--- KAMP (AKA: AMP Advisory council)

KAMP as (select amp.id_number,
amp.short_desc
from table (rpt_pbh634.ksm_pkg.tbl_committee_AMP) amp),

--- Real Estate (Real Estate

Real_Estate as (select RE.id_number,
RE.short_desc
from table (rpt_pbh634.ksm_pkg.tbl_committee_RealEstCouncil) RE),

--- Health

health as (select health.id_number,
health.short_desc
from table (rpt_pbh634.ksm_pkg.tbl_committee_healthcare) health),

--- TASK FORCE KPETC Kellogg Private Equity Taskforce Council - Kellogg Development (KMDV)

PE as (select comm.id_number, comm.committee_code
FROM  committee comm
WHERE  comm.committee_code = 'KPETC' 
AND  comm.committee_status_code = 'C'),


--- Race

KSM_R AS (select distinct deg.ID_NUMBER,
TMS_RACE.ethnic_code,
TMS_RACE.short_desc
from entity
Left Join TMS_RACE ON TMS_RACE.ethnic_code = entity.ethnic_code
Inner Join rpt_pbh634.v_entity_ksm_degrees Deg ON Deg.ID_NUMBER = Entity.Id_Number),

--- KSM_Giving Summary

ksm_give as (select give.ID_NUMBER,
       give.NGC_CFY,
       give.NGC_PFY1,
       give.NGC_PFY2,
       give.NGC_LIFETIME
From rpt_pbh634.v_ksm_giving_summary give),

--- Loyal Donors (2010-2015 --- Three Consecutive Years of Giving or at least $500 over Any Year Past 5)

ksm_loyal as (select give.ID_NUMBER
From rpt_pbh634.v_ksm_giving_summary give
inner join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = give.ID_NUMBER
where deg.FIRST_KSM_YEAR in ('2015','2014','2013','2012','2011')
And (NGC_CFY > 0 AND NGC_PFY1 > 0 AND NGC_PFY2 > 0)
OR
(give.NGC_CFY > 500
or give.NGC_PFY1 > 500
or give.NGC_PFY2 > 500
or give.NGC_PFY3 > 500
or give.NGC_PFY4 > 500
or give.NGC_PFY5 > 500)),

--- KSM Model Scores

ksm_mg as (select mg.id_number,
       mg.pr_segment,
       mg.pr_score
from rpt_pbh634.v_ksm_model_mg mg),

--- KSM Preferred Emails

KSM_Email AS (select email.id_number,
       email.email_address,
       email.preferred_ind,
       email.forwards_to_email_address
From email
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = email.id_number
Where email.preferred_ind = 'Y'),

--- KSM Special Handling (""No Email")

KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_EMAIL_IND,
       spec.NO_CONTACT,
       spec.ACTIVE_WITH_RESTRICTIONS,
       spec.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling spec)

select distinct degrees.id_number,
       degrees.REPORT_NAME,
       degrees.RECORD_STATUS_CODE,
       market.Gender_Code,
       KSM_R.short_desc as race,
       degrees.FIRST_KSM_YEAR,
       degrees.PROGRAM,
       degrees.PROGRAM_GROUP,
       market.employer_name,
       market.job_title,
       market.fld_of_work as industry,
       market.HOUSEHOLD_CITY,
       market.HOUSEHOLD_STATE,
       market.HOUSEHOLD_ZIP,
       market.HOUSEHOLD_GEO_CODES,
       market.HOUSEHOLD_COUNTRY,
       kac.short_desc as kac_indicator,
       phs.short_desc as phs_indicator,
       kalc.short_desc as kalc_indicator,
       kamp.short_desc as kamp_indicator,
       trustee.short_desc as trustee_indicator,
       gab.short_desc as gab_indicator,
       health.short_desc as health_indicator,
       pe.committee_code as pe_indicator,
       real_estate.short_desc as real_estate_indicator,
       ksm_give.NGC_CFY,
       ksm_give.NGC_PFY1,
       ksm_give.NGC_PFY2,
       ksm_give.NGC_LIFETIME,
       market.prospect_manager,
       market.lgos,
       ksm_mg.pr_segment,
       ksm_mg.pr_score,
       market.managers,
       KSM_Email.email_address,
       KSM_Spec.NO_EMAIL_IND,
       KSM_Spec.NO_CONTACT,
       KSM_Spec.ACTIVE_WITH_RESTRICTIONS
from vt_alumni_market_sheet market
left join KALC ON KALC.ID_NUMBER = MARKET.id_number
left join GAB ON GAB.ID_NUMBER = MARKET.id_number
left join KAC ON KAC.ID_NUMBER = MARKET.id_number
left join PHS ON PHS.ID_NUMBER = MARKET.id_number
left join KAMP ON KAMP.ID_NUMBER = MARKET.id_number
left join Real_Estate ON Real_Estate.ID_NUMBER = MARKET.id_number
left join health on health.id_number = market.id_number
left join KSM_R on KSM_R.id_number = market.id_number
left join ksm_give on ksm_give.id_number = market.id_number
left join ksm_loyal on ksm_loyal.id_number = market.id_number
left join ksm_mg on ksm_mg.id_number = market.id_number
left join KSM_Email on KSM_Email.id_number = market.id_number
left join KSM_Spec on KSM_Spec.id_number = market.id_number
left join Trustee on Trustee.id_number = market.id_number
left join entity on entity.id_number = market.id_number
left join PE on PE.id_number = market.id_number
inner join degrees on degrees.id_number = market.id_number


--- Include all the committee members, plus the young loyal donors)
--- Committee Membership

--- Exclude the following 12.17.2020 **************************** 
--- GAB
---- Trustees, 
---  Kellogg Real Estate Advisory Council members
---- Kellogg Healthcare Advisory members
---- PE Task Force members
---- List from Linda: '0000708621', '0000532911', '0000286238','0000532664', '0000595547', '0000530209', '0000564111', 
--- '0000286994', '0000646899', '0000501054', '0000647162'



Where
(kac.id_number is not null
or phs.id_number is not null
or kalc.id_number is not null
or KAMP.id_number is not null
--- Or ""Loyal Donor""
or ksm_loyal.id_number is not null)

--- NO TRUSTEES
and (trustee.id_number is null
and entity.institutional_suffix Not Like '%Trustee%'

--- NO GABS
and GAB.id_number is null

--- NO REAL ESTATE COUNCIL Kellogg Real Estate Advisory Council members

and Real_Estate.id_number is null

--- No Healthcare Kellogg Healthcare Advisory members

and health.id_number is null

--- No Kellogg Private Equity Taskforce Council - Kellogg Development (KMDV)

and PE.id_number is null

--- Kellogg Alumni must NOT have any type of Special Handling Code

and KSM_Spec.NO_EMAIL_IND is null 
and KSM_Spec.NO_CONTACT is null
and KSM_Spec.ACTIVE_WITH_RESTRICTIONS is null)

and market.id_number not IN ('0000708621',
'0000532911',
'0000286238',
'0000532664',
'0000595547',
'0000530209',
'0000564111',
'0000286994',
'0000646899',
'0000501054',
'0000647162',
--- Gil Penchina ID exclude
'0000283788')


Order BY degrees.REPORT_NAME asc
