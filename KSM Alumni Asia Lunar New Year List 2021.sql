/* • Catracks IDs
• First Name
• Last Name
• Country
• Program
• Gift Officer, if they have one
• Kellogg Alumni Board of Asia (Y/N)
• GAB (Y/N)
• Trustee (Y/N)
• No Email Code (Y/N)
• No Contact Code (Y/N)
*/


With KSM_Email AS (select email.id_number,
       email.email_address,
       email.preferred_ind,
       email.forwards_to_email_address
From email
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = email.id_number
Where email.preferred_ind = 'Y'),

/*

manual_adds as (select entity.id_number
from entity 
where  entity.id_number IN (0000296253  ,
0000462015  ,
0000548666  ,
0000328796  ,
0000595858  ,
0000718559  ,
0000732640  ,
0000289491  ,
0000653298  ,
0000484537  ,
0000649400) ),

*/

--- nickname: Using Zach's Dean Salutation

nickname as (select d.ID_NUMBER,
       d.degrees_concat,
       d.P_Dean_Salut,
       d.p_pref_mail_name
from rpt_zrc8929.v_dean_salutation d),

KSM_Spec AS (Select spec.ID_NUMBER,
spec.NO_CONTACT,
spec.NO_EMAIL_IND,
spec.GAB,
spec.TRUSTEE,
       spec.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling spec),

--- Kellogg Executive Board Asia

keba As (Select asia.id_number,
       asia.short_desc
       FROM TABLE(rpt_pbh634.ksm_pkg.tbl_committee_asia) asia)


select market.id_number,
--- First Name
       entity.first_name,
--- Last Name
       entity.last_name,
       nickname.P_Dean_Salut,
       nickname.p_pref_mail_name,
       market.Gender_Code,
--- Program Information
       market.FIRST_KSM_YEAR,
       market.PROGRAM,
       market.PROGRAM_GROUP,
--- Household Address Information
       market.HOUSEHOLD_CITY,
       market.HOUSEHOLD_ZIP,
       market.HOUSEHOLD_COUNTRY,
       market.HOUSEHOLD_CONTINENT,
---- Prospect Manager
       market.prospect_manager,
---- LGO
       market.lgos,
--- Managers Concat
       market.managers,
--- KEBA Indicator
       keba.short_desc as kellogg_exec_board_asia_ind,
--- GAB, Trustee, No Contact, No Email Special Handling Codes
       KSM_Spec.GAB as GAB_IND,
       KSM_Spec.TRUSTEE as Trustee_IND,
       KSM_Spec.NO_CONTACT,
       KSM_Spec.NO_EMAIL_IND
from vt_alumni_market_sheet market
left join KSM_Email on KSM_Email.id_number = market.id_number
left join KSM_Spec on KSM_Spec.id_number = market.id_number
left join entity on entity.id_number = market.id_number
left join keba on keba.id_number = market.id_number
left join nickname on nickname.id_number = market.id_number
--- Alumni in China, Hong Kong (separate from the rest of China), Vietnam, South Korea,
---- Singapore, Malaysia, Philippines, Indonesia, Thailand,
Where market.HOUSEHOLD_COUNTRY IN ('China',
'Hong Kong', 'Vietnam', 'South Korea', 'Singapore',
'Malaysia', 'Philippines', 'Indonesia', 'Thailand', 'Taiwan')
order by market.HOUSEHOLD_COUNTRY ASC
