With

Subquery AS (
--- Club Leaders SQL Code but they are now former members and before August 31st 2018
Select

--- Pulling Biographic Info

entity.id_Number,
entity.first_name,
entity.last_name,
entity.record_status_code,
entity.record_type_code,

--- Pulling Committee Name, Role, Role Status, Start + Stop Date

committee_Header.short_desc As Club_Title,
tms_committee_role.short_desc As Leadership_Title,
committee.committee_status_code,
committee.start_dt,
committee.stop_dt,

--- Pulling Degree Info

rpt_pbh634.v_entity_ksm_degrees.DEGREES_VERBOSE,
rpt_pbh634.v_entity_ksm_degrees.FIRST_KSM_YEAR,
rpt_pbh634.v_entity_ksm_degrees.PROGRAM

--- Using Committee as Main Table

From committee

--- Left Join Entity, Committee Header, Degree Table
Left Join Entity ON Entity.Id_Number = committee.id_number
Left Join committee_header ON committee_header.committee_code = committee.committee_code
Left Join rpt_pbh634.v_entity_ksm_degrees ON rpt_pbh634.v_entity_ksm_degrees.ID_NUMBER = committee.id_number

--- Inner Joining Description of Committee

Inner Join tms_committee_role ON tms_committee_role.committee_role_code = committee.committee_role_code

Where

--- Roles: Executive, Club Leader, President, Vice President, Director, Secretary, President Elect, Treasurer, Executive
 (committee.committee_role_code = 'CL'
    OR  committee.committee_role_code = 'P'
    OR  committee.committee_role_code = 'I'
    OR  committee.committee_role_code = 'DIR'
    OR  committee.committee_role_code = 'S'
    OR  committee.committee_role_code = 'PE'
    OR  committee.committee_role_code = 'T'
    OR  committee.committee_role_code = 'E')

--- Pulling Current Members Only

   AND  (committee.committee_status_code = 'F'

--- Excluding Kellogg Club Leader (KACLE) Group, Kellogg Alumni Club Regional, Kellogg Women Leadership Advisory, Gift Class Committee, Kellogg Global Advisory Board

   And committee.committee_code != 'KACLE'
   And committee.Committee_Code != '535'
   And committee.committee_code != 'KCGC'
   And committee.committee_code != 'KWLC'
   And committee_header.short_desc != 'KSM Global Advisory Board')

--- Pull Committee Codes that Start With: KSM, Kellogg or NU- (This is for the NU-Kellogg Clubs, Pull NU Club of Switzerland

   AND (committee_header.short_desc LIKE '%KSM%'
   Or committee_header.short_desc LIKE '%Kellogg%'
   Or committee_header.short_desc LIKE '%NU-%'
   Or committee_header.short_desc = 'NU Club of Switzerland'
)
   AND entity.record_status_code = 'A'

   And committee.stop_dt <= '20180831'

--- Sort by Club Name

Order BY committee_header.short_desc)

Select
subquery.id_number,
subquery.first_name,
subquery.last_name,
subquery.record_status_code,
subquery.record_type_code,
subquery.Club_Title,
subquery.Leadership_Title,
subquery.committee_status_code,
subquery.start_dt,
subquery.stop_dt,
subquery.DEGREES_VERBOSE,
subquery.FIRST_KSM_YEAR,
subquery.PROGRAM,
vt_alumni_market_sheet.HOUSEHOLD_CITY,
vt_alumni_market_sheet.HOUSEHOLD_STATE,
vt_alumni_market_sheet.HOUSEHOLD_COUNTRY,
telephone.area_code,
telephone.telephone_number,
email.email_address,
email.email_status_code,
email.preferred_ind,
vt_alumni_market_sheet.prospect_manager_id,
vt_alumni_market_sheet.prospect_manager

From subquery
Left Join vt_alumni_market_sheet ON vt_alumni_market_sheet.id_number = subquery.id_Number
Left Join Email on Email.Id_Number = subquery.id_number
Left Join telephone On telephone.id_number = subquery.id_number
Where Email.Preferred_Ind = 'Y'
And
telephone.preferred_ind = 'Y'
