--- Ethnicity

With KSM_Ethnicity AS (select distinct deg.ID_NUMBER,
entity.ethnic_code,
Tms_Ethnic_Source.short_desc as eth_source,
TMS_RACE.ethnic_code As Eth_Code,
TMS_RACE.short_desc
from entity
Left Join TMS_RACE ON TMS_RACE.ethnic_code = entity.ethnic_code
Left Join Tms_Ethnic_Source ON Tms_Ethnic_Source.ethnic_src_code = entity.ethnic_src_code
Inner Join rpt_pbh634.v_entity_ksm_degrees Deg ON Deg.ID_NUMBER = Entity.Id_Number
Where TMS_RACE.short_desc IN ('African American','Hispanic')),

--- HH Address

KSM_House As(select hh.ID_NUMBER,
       hh.HOUSEHOLD_CITY,
       hh.HOUSEHOLD_STATE,
       hh.HOUSEHOLD_GEO_CODES,
       hh.HOUSEHOLD_COUNTRY
From rpt_pbh634.v_entity_ksm_households hh),

--- Preferred Email

KSM_Email AS (Select Email.Id_Number, Email.Email_Address
From Email
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = email.id_number
Where Email.Preferred_Ind = 'Y'),

--- PM and LGO

KSM_Assignment As (Select summary.id_number,
summary.prospect_manager,
summary.lgos,
summary.managers,
summary.curr_ksm_manager
From rpt_pbh634.v_assignment_summary summary),

--- Special Handling: No Contact, No Phone, No Email Indicator

KSM_Handling AS
(select handle.ID_NUMBER,
       handle.NO_CONTACT,
       handle.NO_PHONE_IND,
       handle.NO_EMAIL_IND
FROM rpt_pbh634.v_entity_special_handling handle),

--- Pref Phone Number

KSM_Phone As (select t.id_number,
       t.area_code,
       t.telephone_number,
       t.preferred_ind
from telephone t
where t.preferred_ind = 'Y'),

--- Indicator of LGBTQ with Kellogg Pride Committee

KSM_Pride As (Select Committee.Id_Number,
       Committee.Committee_Code,
       Committee.Committee_Status_Code,
       TMS_COMMITTEE_TABLE.short_desc AS KSM_Pride_Committee
From Committee
Left Join TMS_COMMITTEE_TABLE on Committee.Committee_Code = TMS_COMMITTEE_TABLE.committee_code
Where Committee.Committee_Code = 'KACGL'),

--- Indicator or LGBTQ with Student Activities

Student_Pride As (Select stact.id_number,
stact.student_activity_code,
TMS_STUDENT_ACT.short_desc
FROM  student_activity stact
LEFT JOIN TMS_STUDENT_ACT ON TMS_STUDENT_ACT.student_activity_code = stact.student_activity_code
WHERE  stact.student_activity_code IN ('KSB14','KSA23','34617','GLMA'))


Select deg.ID_NUMBER,
       deg.REPORT_NAME,
       deg.RECORD_STATUS_CODE As Record_Status,
       deg.FIRST_KSM_YEAR AS KSM_Degree_Year,
       deg.PROGRAM As KSM_Program,
       deg.DEGREES_VERBOSE,
       deg.CLASS_SECTION,
       KSM_House.HOUSEHOLD_CITY AS City,
       KSM_House.HOUSEHOLD_STATE AS State,
       KSM_House.HOUSEHOLD_GEO_CODES AS Geo_Code,
       KSM_House.HOUSEHOLD_COUNTRY As Country,
       KSM_Email.Email_Address AS Pref_Email,
       KSM_Phone.area_code,
       KSM_Phone.telephone_number,
       KSM_Handling.NO_CONTACT,
       KSM_Handling.NO_PHONE_IND,
       KSM_Handling.NO_EMAIL_IND,
       KSM_Ethnicity.short_desc AS Ethnicity,
       KSM_Ethnicity.eth_source As Ethnicity_Source,
       KSM_Assignment.prospect_manager,
       KSM_Assignment.lgos,
       KSM_Assignment.managers,
       KSM_Assignment.curr_ksm_manager
From rpt_pbh634.v_entity_ksm_degrees deg
Inner Join KSM_Ethnicity ON KSM_Ethnicity.id_number = deg.ID_NUMBER
Left Join KSM_House ON deg.ID_NUMBER = KSM_House.id_number
Left Join KSM_Email on KSM_Email.id_number = deg.ID_NUMBER
Left Join KSM_Handling ON KSM_Handling.id_number = deg.ID_NUMBER
Left Join KSM_Assignment ON KSM_Assignment.id_number = deg.ID_NUMBER
Left Join KSM_Phone ON KSM_Phone.id_number = deg.id_number
Where deg.FIRST_KSM_YEAR IN ('2019','2018','2017','2016')
And deg.RECORD_STATUS_CODE = 'A'
Order By deg.REPORT_NAME ASC
