With manual_dates As (
Select
  2022 AS pfy
  ,2023 AS cfy
  From DUAL
),

h as (select *
from rpt_pbh634.v_entity_ksm_households),

--- international

i as (select *
from rpt_pbh634.v_entity_ksm_households h
where h.HOUSEHOLD_COUNTRY not like '%United States%'),

KSM_Email AS (select email.id_number,
       email.email_address,
       email.email_type_code,
       email.preferred_ind,
       email.forwards_to_email_address
From email
Where email.preferred_ind = 'Y'),

KSM_DEGREES AS (
 SELECT
   KD.ID_NUMBER
   ,KD.PROGRAM
   ,KD.PROGRAM_GROUP
   ,KD.CLASS_SECTION
 FROM RPT_PBH634.V_ENTITY_KSM_DEGREES KD
 WHERE KD.PROGRAM IN ('EMP', 'EMP-FL', 'EMP-IL', 'EMP-CAN', 'EMP-GER', 'EMP-HK', 'EMP-ISR', 'EMP-JAN', 'EMP-CHI', 'FT', 'FT-1Y', 'FT-2Y', 'FT-CB', 'FT-EB', 'FT-JDMBA', 'FT-MMGT', 'FT-MMM', 'TMP', 'TMP-SAT',
'TMP-SATXCEL', 'TMP-XCEL')),

KSM_REUNION AS (
SELECT DISTINCT
A.ID_NUMBER, A.CLASS_YEAR
FROM AFFILIATION A
CROSS JOIN manual_dates MD
INNER JOIN KSM_DEGREES KD
ON A.ID_NUMBER = KD.ID_NUMBER
Inner JOIN rpt_pbh634.v_entity_ksm_households hh ON HH.ID_NUMBER = A.ID_NUMBER
LEFT JOIN RPT_DGZ654.V_GEO_CODE GC
  ON A.ID_NUMBER = GC.ID_NUMBER
    AND GC.ADDR_PREF_IND = 'Y'
     AND GC.GEO_STATUS_CODE = 'A'
WHERE TO_NUMBER(NVL(TRIM(A.CLASS_YEAR),'1')) IN (MD.CFY-1, MD.CFY-5, MD.CFY-10, MD.CFY-15, MD.CFY-20, MD.CFY-25, MD.CFY-30, MD.CFY-35, MD.CFY-40,
  MD.CFY-45, MD.CFY-50, MD.CFY-51, MD.CFY-52, MD.CFY-53, MD.CFY-54, MD.CFY-55, MD.CFY-56, MD.CFY-57, MD.CFY-58, MD.CFY-59, MD.CFY-60)
AND A.AFFIL_CODE = 'KM'
AND A.AFFIL_LEVEL_CODE = 'RG'
),

KSM_Alt AS (select distinct email.id_number
       , Listagg (email.email_address, ';  ') Within Group (Order By email.email_address) As Alt_Home_Email
From email
Inner Join rpt_pbh634.v_entity_ksm_degrees deg on deg.ID_NUMBER = email.id_number
Where email.preferred_ind = 'N'
and email.email_type_code = 'X'
And email.email_status_code = 'A'
Group By email.id_number),

--- Trustee

Trustee As (select trustee.id_number,
trustee.short_desc,
trustee.role
From Table(rpt_pbh634.ksm_pkg.tbl_committee_trustee) Trustee),

--- GAB

GAB AS (Select gab.id_number,
       gab.short_desc,
       gab.status
From table(rpt_pbh634.ksm_pkg.tbl_committee_gab) gab),

--- Kellogg Alumni Council

KAC AS (select k.id_number,
       k.committee_code,
       k.short_desc,
       k.status
From table (rpt_pbh634.ksm_pkg.tbl_committee_kac) k),

--- Working Current KLC Donors- Pulled from Amy's View

KLC AS (select K.ID_NUMBER,
       K.segment,
       K.KLC_lev_cfy
from RPT_ABM1914.V_KLC_MEMBERS K),


KSM_Spec AS (Select spec.ID_NUMBER,
       spec.NO_CONTACT,
       spec.NO_EMAIL_IND,
       spec.ACTIVE_WITH_RESTRICTIONS,
       spec.NEVER_ENGAGED_FOREVER,
       spec.NEVER_ENGAGED_REUNION
From rpt_pbh634.v_entity_special_handling spec),

assign as (select assign.id_number,
       assign.prospect_manager,
       assign.lgos,
       assign.managers,
       assign.curr_ksm_manager
from rpt_pbh634.v_assignment_summary assign)

/*AF as (select distinct
 ID_NUMBER
 ,YR1
 ,DATE1
 ,AMT1
 ,ACCT1
 ,TYPE1
 ,APPEAL1
 ,YR2
 ,DATE2
 ,AMT2
 ,ACCT2
 ,TYPE2
 ,APPEAL2
 ,YR3
 ,DATE3
 ,AMT3
 ,ACCT3
 ,TYPE3
 ,APPEAL3
 ,YR4
 ,DATE4
 ,AMT4
 ,ACCT4
 ,TYPE4
 ,KSM_#_2021
 ,KSM_$_2021
 ,KSM_MATCH_2021
 ,KSM_#_2020
 ,KSM_$_2020
 ,KSM_MATCH_2020
 ,KSM_#_2019
 ,KSM_$_2019
 ,KSM_MATCH_2019
 ,KSM_#_2018   -- GET DOWNLOAD AS XLSX TO NOT APPLY 2 DECIMALS
 ,KSM_$_2018
 ,KSM_MATCH_2018
 ,KSM_#_2017
 ,KSM_$_2017
 ,KSM_MATCH_2017
 FROM V_AF_Request)*/

,AMOUNTS AS(
SELECT
  BS.ID_NUMBER
  ,WT0_GIFTS2.GIFTS(BS.ID_NUMBER, 4, 1+2+4+16+8192+256, '1900', '2100', '^', '^', 'KM') AMT1
 FROM h BS
)

,KSM_MONEY AS
(
SELECT
    GIFT_DONOR_ID
    ,SUM (CASE WHEN GIFT_YEAR_OF_GIVING = '2021' AND ALLOC_SCHOOL = 'KM' THEN GIFT_ASSOCIATED_CREDIT_AMT ELSE 0 END) KSM_$_2021
    ,COUNT(DISTINCT CASE WHEN GIFT_YEAR_OF_GIVING = '2021' AND ALLOC_SCHOOL = 'KM' THEN GIFT_RECEIPT_NUMBER END) KSM_#_2021
    ,SUM (CASE WHEN GIFT_YEAR_OF_GIVING = '2020' AND ALLOC_SCHOOL = 'KM' THEN GIFT_ASSOCIATED_CREDIT_AMT ELSE 0 END) KSM_$_2020
    ,COUNT(DISTINCT CASE WHEN GIFT_YEAR_OF_GIVING = '2020' AND ALLOC_SCHOOL = 'KM' THEN GIFT_RECEIPT_NUMBER END) KSM_#_2020
    ,SUM (CASE WHEN GIFT_YEAR_OF_GIVING = '2019' AND ALLOC_SCHOOL = 'KM' THEN GIFT_ASSOCIATED_CREDIT_AMT ELSE 0 END) KSM_$_2019
    ,COUNT(DISTINCT CASE WHEN GIFT_YEAR_OF_GIVING = '2019' AND ALLOC_SCHOOL = 'KM' THEN GIFT_RECEIPT_NUMBER END) KSM_#_2019
    ,SUM (CASE WHEN GIFT_YEAR_OF_GIVING = '2018' AND ALLOC_SCHOOL = 'KM' THEN GIFT_ASSOCIATED_CREDIT_AMT ELSE 0 END) KSM_$_2018
    ,COUNT(DISTINCT CASE WHEN GIFT_YEAR_OF_GIVING = '2018' AND ALLOC_SCHOOL = 'KM' THEN GIFT_RECEIPT_NUMBER END) KSM_#_2018
    ,SUM (CASE WHEN GIFT_YEAR_OF_GIVING = '2017' AND ALLOC_SCHOOL = 'KM' THEN GIFT_ASSOCIATED_CREDIT_AMT ELSE 0 END) KSM_$_2017
    ,COUNT(DISTINCT CASE WHEN GIFT_YEAR_OF_GIVING = '2017' AND ALLOC_SCHOOL = 'KM' THEN GIFT_RECEIPT_NUMBER END) KSM_#_2017
    ,SUM(GIFT_ASSOCIATED_CREDIT_AMT) NU_$
    ,SUM(CASE WHEN GIFT_ASSOCIATED_ALLOCATION = '3303000891301GFT' THEN GIFT_ASSOCIATED_CREDIT_AMT ELSE 0 END) KSM_AF_$
    ,SUM(CASE WHEN ALLOC_SCHOOL = 'KM' THEN GIFT_ASSOCIATED_CREDIT_AMT ELSE 0 END) KSM_$

FROM GIFT
     ,ALLOCATION
     ,H
WHERE GIFT_DONOR_ID = H.ID_NUMBER
   AND GIFT_ASSOCIATED_ALLOCATION = ALLOCATION_CODE
GROUP BY GIFT_DONOR_ID
),

KSM_MATCHES AS
(
SELECT
   GIFT_DONOR_ID
   ,SUM(CASE WHEN MATCHYEAR = '2021' AND SCHAREA = 'KM' THEN MATCHAMOUNT ELSE 0 END) KSM_MATCH_2021
   ,SUM(CASE WHEN MATCHYEAR = '2020' AND SCHAREA = 'KM' THEN MATCHAMOUNT ELSE 0 END) KSM_MATCH_2020
   ,SUM(CASE WHEN MATCHYEAR = '2019' AND SCHAREA = 'KM' THEN MATCHAMOUNT ELSE 0 END) KSM_MATCH_2019
   ,SUM(CASE WHEN MATCHYEAR = '2018' AND SCHAREA = 'KM' THEN MATCHAMOUNT ELSE 0 END) KSM_MATCH_2018
   ,SUM(CASE WHEN MATCHYEAR = '2017' AND SCHAREA = 'KM' THEN MATCHAMOUNT ELSE 0 END) KSM_MATCH_2017
FROM WT0_SOFT_MATCHES
   ,H
WHERE GIFT_DONOR_ID = H.ID_NUMBER
GROUP BY GIFT_DONOR_ID
)

Select Distinct h.ID_NUMBER,
       h.SPOUSE_ID_NUMBER,
       h.PREF_MAIL_NAME,
       h.SPOUSE_PREF_MAIL_NAME,
       h.RECORD_STATUS_CODE,
       h.PROGRAM,
       h.PROGRAM_GROUP,
       KR.class_year,
       h.HOUSEHOLD_CITY,
       h.HOUSEHOLD_STATE,
       h.HOUSEHOLD_GEO_PRIMARY_DESC,
       h.HOUSEHOLD_COUNTRY,
       h.HOUSEHOLD_CONTINENT,
       Trustee.short_desc as Trustee,
       GAB.short_desc as GAB,
       KAC.short_desc as KAC,
       --- Adding in Spouse GAB/KAC/Trustee Indicators
       Case WHEN WT0_PKG.GetGAB(h.SPOUSE_ID_NUMBER) = 'TRUE' THEN 'Spouse GAB' ELSE ' ' END Spouse_GAB,
         Case WHEN WT0_PKG.GetKAC(h.SPOUSE_ID_NUMBER) = 'TRUE' THEN 'Spouse KAC' ELSE ' ' END Spouse_KAC,
           CASE WHEN WT0_PKG.IsCurrentTrustee(h.SPOUSE_ID_NUMBER) = 'TRUE' THEN 'Spouse Trustee' ELSE ' ' END SPOUSE_TRUSTEE,
       case when klc.ID_NUMBER is not null then 'KLC' else '' End as KLC_22,
       case when KR.class_year <= '1973' then '50th Reunion' End as Reunion_50th,
       /*
       -  Rank for Bridget
       Will you segment the list in these segments
(and this is how they should rank�once they are in one of these segments,
please don�t include them in a future segment):
       -  Trustee, GAB, KAC and their spouses
       -  Class of 2022
       -  FY22 KLC donors
       -  International
       -  50th Reunion
       -  Everyone else */
       case when Trustee.id_number is not null then 'Trustee'
        when GAB.id_number is not null then 'GAB'
         when KAC.id_number is not null then 'KSM Alumni Council'
           when KR.class_year = '2022' then 'Class of 2022'
             when klc.ID_NUMBER is not null then 'FY22 KLC Donors'
               when i.id_number is not null then 'International'
                 when KR.class_year <= '1973' then '50th Reunion'
                          else '' END as List_Rank_For_Email
   ,WT0_PARSE(AM.AMT1, 3, '^') YR1
  ,WT0_PARSE(AM.AMT1, 2, '^') DATE1
  ,WT0_PARSE(AM.AMT1, 1, '^') AMT1
  ,WT0_PARSE(AM.AMT1, 4, '^') ACCT1
  ,WT0_PARSE(AM.AMT1, 6, '^') TYPE1
  ,(SELECT DESCRIPTION
     FROM APPEAL_HEADER
     WHERE APPEAL_CODE = WT0_PARSE(AM.AMT1, 5, '^')) APPEAL1
  ,WT0_PARSE(AM.AMT1,  9, '^') YR2
  ,WT0_PARSE(AM.AMT1,  8, '^') DATE2
  ,WT0_PARSE(AM.AMT1,  7, '^') AMT2
  ,WT0_PARSE(AM.AMT1, 10, '^') ACCT2
  ,WT0_PARSE(AM.AMT1, 12, '^') TYPE2
  ,(SELECT DESCRIPTION
     FROM APPEAL_HEADER
     WHERE APPEAL_CODE = WT0_PARSE(AM.AMT1, 11, '^')) APPEAL2
 ,WT0_PARSE(AMT1, 15, '^') YR3
  ,WT0_PARSE(AMT1, 14, '^') DATE3
  ,WT0_PARSE(AMT1, 13, '^') AMT3
  ,WT0_PARSE(AMT1, 16, '^') ACCT3
  ,WT0_PARSE(AMT1, 18, '^') TYPE3
  ,(SELECT DESCRIPTION
     FROM APPEAL_HEADER
     WHERE APPEAL_CODE = WT0_PARSE(AMT1, 17, '^')) APPEAL3
  ,WT0_PARSE(AMT1, 21, '^') YR4
  ,WT0_PARSE(AMT1, 20, '^') DATE4
  ,WT0_PARSE(AMT1, 19, '^') AMT4
  ,WT0_PARSE(AMT1, 22, '^') ACCT4
  ,WT0_PARSE(AMT1, 24, '^') TYPE4
  ,(SELECT DESCRIPTION
     FROM APPEAL_HEADER
     WHERE APPEAL_CODE = WT0_PARSE(AMT1, 23, '^')) APPEAL4
  ,TO_CHAR(TO_NUMBER(KSMM.KSM_#_2021), '99999990') KSM_#_2021
  ,KSMM.KSM_$_2021
  ,KM.KSM_MATCH_2021
  ,TO_CHAR(TO_NUMBER(KSMM.KSM_#_2020), '99999990') KSM_#_2020
  ,KSMM.KSM_$_2020
  ,KM.KSM_MATCH_2020
  ,TO_CHAR(TO_NUMBER(KSMM.KSM_#_2019), '99999990') KSM_#_2019
  ,KSMM.KSM_$_2019
  ,KM.KSM_MATCH_2019

  ,TO_CHAR(TO_NUMBER(KSMM.KSM_#_2018), '99999990') KSM_#_2018   -- GET DOWNLOAD AS XLSX TO NOT APPLY 2 DECIMALS
  ,KSMM.KSM_$_2018
  ,KM.KSM_MATCH_2018

  ,TO_CHAR(TO_NUMBER(KSMM.KSM_#_2017), '99999990') KSM_#_2017
  ,KSMM.KSM_$_2017
  ,KM.KSM_MATCH_2017
 ,assign.LGOS
 ,assign.Prospect_manager
FROM H
left join gab on gab.id_number = h.id_number
left join trustee on trustee.id_number = h.id_number
left join kac on kac.id_number = h.id_number
left join klc on klc.ID_NUMBER  = h.id_number
left join KSM_Spec on KSM_Spec.id_number = h.id_number
left join i on i.id_number = h.id_number
left join assign on assign.id_number = h.id_number
LEFT JOIN AMOUNTS AM
ON h.ID_NUMBER = AM.ID_NUMBER
LEFT JOIN KSM_MONEY KSMM
ON h.ID_NUMBER = KSMM.GIFT_DONOR_ID
LEFT JOIN KSM_MATCHES KM
ON h.ID_NUMBER = KM.GIFT_DONOR_ID
INNER JOIN KSM_REUNION KR on KR.id_number = h.id_number
/* Please remove the following:
-  Do not contact
-  Do not email
-  Never engaged
-  Non Kellogg alumni */
Where (KSM_Spec.NO_CONTACT is null and
       KSM_spec.NO_EMAIL_IND is null and
       KSM_spec.NEVER_ENGAGED_FOREVER is null)
       and h.RECORD_STATUS_CODE IN ('A','L')
       Order by KR.class_year ASC
