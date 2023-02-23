 /*following are specifically used for static ASK 3 information for Reunion

DROP TABLE RPT_ABM1914.AF1_DATA_FOR_ASKS;
CREATE TABLE RPT_ABM1914.AF1_DATA_FOR_ASKS AS*/



/*

Bridget's Ad Hoc

Should have the exact same data points AND Following Criteria and Exclsuions

Criteria:
- Active Alumni from the FT and EMBA program that graduated in 1973, 1978, 1983, 1988, 1993, 1998, 2003, 2008, 2013, 2018: Included KSM alumni that are celebrating their preferred KSM Reunion years from your list.

Exclusions:
- Doesn’t have an address: Excluded anyone without an address or “Lost” record.
- Any international alumni Removed anyone that had an address outside of the United States.
- Do not contact, do not mail: Removed No Contacts, No Mail special handling codes.
- Mailing list exclusion for those that do not want to receive mail from Kellogg The exclusion of No Mail should suffice.
- Never Engaged Reunion and Never Engaged Forever Removed those with special handling codes noted.
- Trustee and their spouses Trustees + Spouses removed.
- Kellogg Faculty and staff Kellogg Faculty and Staff removed.
- Sally Blount and Dean Jain Removed
- MSMS, MDMBA, Harvard program, emba programs that are in other countries Removed MSMS, MDMBA, Harvard, and international EMBA Programs
- Any spouse that is not a Kellogg alum: Spouses provided in the file should just be KSM alumni celebrating their Reunion 2023. */

--- I have to slightly modify Amy's Code, and inner join a Reunion view that finishes suffices
--- the criteria and has the exclusions


WITH
FINAL_SELECT AS(
SELECT
    KHH.HOUSEHOLD_ID
   ,KHH.HOUSEHOLD_PRIMARY
   ,KHH.ID_NUMBER
   ,KHH.SPOUSE_ID_NUMBER as spouse_ID
  -- ,FS.SEGMENTATION
FROM  rpt_pbh634.v_entity_ksm_households KHH
),


NO_EMAIL_SOL AS
 (
   SELECT MAILING_LIST.ID_NUMBER
     FROM MAILING_LIST,
          FINAL_SELECT
    WHERE MAIL_LIST_CODE IN ('AC',  'AS',
                             'NAC',
                             'NAF', 'EC',
                             'ES',  'NSC')
      AND MAIL_LIST_CTRL_CODE = 'EXC'
      AND MAIL_LIST_STATUS_CODE = 'A'
      AND (TRIM(UNIT_CODE) IS NULL OR
           UNIT_CODE = 'KM')
      AND FINAL_SELECT.ID_NUMBER  = MAILING_LIST.ID_NUMBER
   UNION
   SELECT HANDLING.ID_NUMBER
     FROM HANDLING,
          FINAL_SELECT
    WHERE FINAL_SELECT.ID_NUMBER = HANDLING.ID_NUMBER
      AND HND_STATUS_CODE = 'A'
      AND HND_TYPE_CODE IN ('DNS', 'NE', 'NES')
),

  NO_EMAIL_SOL2 AS
  (
  SELECT *
    FROM NO_EMAIL_SOL
    ),

AMOUNTS AS
(
SELECT
  BS.ID_NUMBER
  ,WT0_GIFTS2.GIFTS(BS.ID_NUMBER, 4, 1+2+4+16+8192+256, '1900', '2100', '^', '^', 'KM') AMT1
 FROM FINAL_SELECT BS
),

LOYALTY AS
(
   SELECT GIFT_CLUB_ID_NUMBER,
          DECODE(SCHOOL_CODE,
                 'LB', 'Bronze',
                 'LS', 'Silver',
                 'LG', 'Gold',
                 'LP', 'Platinum',
                 ' ') LEVEL_,
          REPLACE(REPLACE(GIFT_CLUB_COMMENT, CHR(13)), CHR(10)) GIFT_CLUB_COMMENT,
          GIFT_CLUB_REASON
     FROM GIFT_CLUBS,
          FINAL_SELECT
    WHERE GIFT_CLUB_CODE = 'NUL'
      AND GIFT_CLUB_ID_NUMBER = FINAL_SELECT.ID_NUMBER
      AND GIFT_CLUB_STATUS = 'A'
),

LOYAL_CURRENT AS
(
   SELECT DISTINCT FINAL_SELECT.ID_NUMBER
     FROM GIFT_CLUBS,
          FINAL_SELECT
    WHERE GIFT_CLUB_CODE = 'NUL'
    -- Optimize
      AND GIFT_CLUB_ID_NUMBER IN (FINAL_SELECT.ID_NUMBER)
      AND GIFT_CLUB_STATUS = 'A'
),

LOYAL_POTENTIAL AS
(
   SELECT DISTINCT FINAL_SELECT.ID_NUMBER
     FROM FINAL_SELECT
    WHERE WT0_GIFTS2.GetConsecutiveBackwards(FINAL_SELECT.ID_NUMBER, '2017') >= 2
),

PROPOSALS AS
(
SELECT
  EN.ID_NUMBER
  ,WT0_PKG.GetProposal2(EN.ID_NUMBER,NULL) PROPOSAL_STATUS
FROM FINAL_SELECT EN
),

KSM_MONEY AS
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
     ,FINAL_SELECT
WHERE GIFT_DONOR_ID = FINAL_SELECT.ID_NUMBER
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
   ,FINAL_SELECT
WHERE GIFT_DONOR_ID = FINAL_SELECT.ID_NUMBER
GROUP BY GIFT_DONOR_ID
),

GIVING_TRANS AS
(
SELECT HH.*
  FROM RPT_PBH634.V_KSM_GIVING_TRANS_HH HH
),


KLC_YN AS
(
select ID,
        SUM(case when FY =  '2021' then AMT else 0 end) tot_kgifts_FY21,
        SUM(case when FY =  '2022' then AMT else 0 end) tot_kgifts_FY22
  FROM (
SELECT
   HH.ID_NUMBER ID
   ,HH.TX_NUMBER RCPT
   ,HH.FISCAL_YEAR FY
   ,(HH.CREDIT_AMOUNT + nvl(mtch.mtch,0) + nvl(clm.claim,0)) AMT
FROM GIVING_TRANS HH,
  (SELECT
    HH.ID_NUMBER
   ,HH.MATCHED_TX_NUMBER RCPT
   ,HH.ALLOCATION_CODE ALLOC
   ,SUM(HH.CREDIT_AMOUNT) MTCH
    FROM GIVING_TRANS HH
     WHERE HH.TX_GYPM_IND = 'M'
    GROUP BY HH.ID_NUMBER, HH.MATCHED_TX_NUMBER, HH.ALLOCATION_CODE)mtch,
   (SELECT
      HH.ID_NUMBER
      ,HH.TX_NUMBER RCPT
      ,HH.ALLOCATION_CODE ALLOC
      ,SUM(MC.CLAIM_AMOUNT) CLAIM
      FROM GIVING_TRANS HH
      LEFT JOIN MATCHING_CLAIM MC
        ON HH.TX_NUMBER = MC.CLAIM_GIFT_RECEIPT_NUMBER
        AND HH.ALLOCATION_CODE = MC.ALLOCATION_CODE
        --AND HH.TX_SEQUENCE = MC.CLAIM_GIFT_SEQUENCE
     -- WHERE HH.TX_NUMBER = MC.CLAIM_GIFT_RECEIPT_NUMBER
      GROUP BY HH.ID_NUMBER, HH.TX_NUMBER, HH.ALLOCATION_CODE)CLM
     WHERE HH.FISCAL_YEAR IN ('2021', '2022')
     AND HH.ID_NUMBER = MTCH.ID_NUMBER (+)
     AND HH.TX_NUMBER = MTCH.RCPT (+)
     AND HH.ALLOCATION_CODE = MTCH.ALLOC (+)
     AND HH.ID_NUMBER = CLM.ID_NUMBER (+)
     AND HH.TX_NUMBER = CLM.RCPT (+)
     AND HH.ALLOCATION_CODE = CLM.ALLOC (+)
     AND HH.TX_GYPM_IND NOT IN ('P','M')
     AND (HH.AF_FLAG = 'Y' OR HH.CRU_FLAG = 'Y'))
     GROUP BY ID
   )

,TRUSTEE AS (
  SELECT
    ID_NUMBER
    ,SPOUSE_ID_NUMBER
  FROM TABLE(RPT_PBH634.KSM_PKG_TMP.tbl_committee_trustee) T
),

GAB_MEMBER AS (
  SELECT
    ID_NUMBER
    ,SPOUSE_ID_NUMBER
  FROM TABLE(RPT_PBH634.KSM_PKG_TMP.tbl_committee_gab) G
),

KAC AS (
   SELECT
    ID_NUMBER
    ,SPOUSE_ID_NUMBER
  FROM TABLE(RPT_PBH634.KSM_PKG_TMP.tbl_committee_kac) K
),

PHS AS (
   SELECT
     ID_NUMBER
    ,SPOUSE_ID_NUMBER
   FROM TABLE(RPT_PBH634.KSM_PKG_TMP.tbl_committee_phs) P
),


MYDATA AS (
         SELECT
           ID_NUMBER
           ,CREDIT_AMOUNT amt
           ,TX_GYPM_IND
           ,DATE_OF_RECORD dt
           ,TX_NUMBER rcpt
           ,MATCHED_TX_NUMBER m_rcpt
           ,ALLOC_SHORT_NAME acct
           ,AF_FLAG AF
           ,FISCAL_YEAR FY
          FROM GIVING_TRANS
          WHERE TX_GYPM_IND <> 'P'
),

ROWDATA AS(
SELECT
           g.ID_NUMBER
           ,ROW_NUMBER() OVER(PARTITION BY g.ID_NUMBER ORDER BY g.dt DESC)RW
           ,g.amt
           ,m.amt match
           ,c.claim
           ,g.dt
           ,g.rcpt
           ,g.acct
           ,g.AF
           ,g.FY
           -- Optimize
           FROM (SELECT * FROM MYDATA WHERE TX_GYPM_IND <> 'M') g
           LEFT JOIN (SELECT * FROM MYDATA WHERE TX_GYPM_IND = 'M') m
                ON g.rcpt = m.m_rcpt AND g.ID_NUMBER = m.ID_NUMBER
           LEFT JOIN (SELECT
                KSMT.TX_NUMBER
                ,KSMT.ALLOCATION_CODE
                ,SUM(MC.CLAIM_AMOUNT) CLAIM
            FROM GIVING_TRANS KSMT
            INNER JOIN MATCHING_CLAIM MC
              ON KSMT.TX_NUMBER = MC.CLAIM_GIFT_RECEIPT_NUMBER
              AND KSMT.TX_SEQUENCE = MC.CLAIM_GIFT_SEQUENCE
              GROUP BY KSMT.TX_NUMBER, KSMT.ALLOCATION_CODE) C
              ON G.RCPT = C.TX_NUMBER
),
GIFTINFO AS (
    SELECT
     ID_NUMBER
     ,max(decode(RW,1,dt))       gdt1
     ,max(decode(RW,1,amt))     gamt1
     ,max(decode(RW,1,match))   match1
     ,max(decode(RW,2,dt)) gdt2
     ,max(decode(RW,2,amt))     gamt2
     ,max(decode(RW,2,match))   match2
     ,max(decode(RW,3,dt)) gdt3
     ,max(decode(RW,3,amt))     gamt3
     ,max(decode(RW,3,match))   match3
     ,max(decode(RW,4,dt)) gdt4
     ,max(decode(RW,4,amt))     gamt4
     ,max(decode(RW,4,match))   match4
    FROM ROWDATA
    GROUP BY ID_NUMBER
),
PLG AS
(SELECT
   GT.ID_NUMBER
  ,count(distinct case when GT.TX_GYPM_IND = 'P'
         AND GT.PLEDGE_STATUS <> 'R'
         THEN GT.TX_NUMBER END) KSM_PLEDGES
  ,SUM(CASE WHEN GT.TX_GYPM_IND = 'P'
         AND GT.PLEDGE_STATUS <> 'R'
         THEN GT.CREDIT_AMOUNT END) KSM_PLG_TOT
   FROM GIVING_TRANS GT
GROUP BY GT.ID_NUMBER
),
PLEDGE_ROWS AS
 (select ID,
                 max(decode(rw,1,dt)) last_plg_dt,
                 max(decode(rw,1,stat)) status1,
                 max(decode(rw,1,acct)) pacct1,
                 max(decode(rw,1,amt)) pamt1,
                 max(decode(rw,1,bal)) bal1
          FROM
             (SELECT
                 ID
                 ,ROW_NUMBER() OVER(PARTITION BY ID ORDER BY DT DESC)RW
                 ,DT
                 ,STAT
                 ,ACCT
                 ,AMT
                 ,case when (bal * prop) < 0 then 0
                          else round(bal * prop,2) end bal
                FROM

       (SELECT
                      HH.ID_NUMBER ID
                      ,HH.TX_NUMBER AS PLG
                      ,HH.TRANSACTION_TYPE
                      ,HH.TX_GYPM_IND
                      ,HH.ALLOC_SHORT_NAME AS ACCT
                      ,PS.SHORT_DESC AS STAT
                      ,HH.DATE_OF_RECORD AS DT
                      ,HH.CREDIT_AMOUNT
                      ,PP.PRIM_PLEDGE_AMOUNT AS AMT
                      ,PP.PRIM_PLEDGE_ORIGINAL_AMOUNT
                      ,PP.PRIM_PLEDGE_AMOUNT_PAID
                      ,p.pledge_associated_credit_amt
                      ,pp.prim_pledge_amount
                      ,CASE WHEN p.pledge_associated_credit_amt > pp.prim_pledge_amount THEN 1
                         ELSE p.pledge_associated_credit_amt / pp.prim_pledge_amount END PROP
                      ,PP.PRIM_PLEDGE_AMOUNT - pp.prim_pledge_amount_paid as BAL
                   FROM GIVING_TRANS HH
                   LEFT JOIN TMS_PLEDGE_STATUS PS
                   ON HH.PLEDGE_STATUS = PS.pledge_status_code
                   INNER JOIN PLEDGE P
                   ON HH.ID_NUMBER = P.PLEDGE_DONOR_ID
                       AND HH.TX_NUMBER = P.PLEDGE_PLEDGE_NUMBER
                   LEFT JOIN PRIMARY_PLEDGE PP
                   ON P.PLEDGE_PLEDGE_NUMBER = PP.PRIM_PLEDGE_NUMBER
                   WHERE pp.prim_pledge_amount > 0
                   ))
             GROUP BY ID
),

r as (select REUNION_2023_MAILER.ID_NUMBER,
             REUNION_2023_MAILER.SPOUSE_PREF_MAIL_NAME,
             REUNION_2023_MAILER.PROGRAM,
             REUNION_2023_MAILER.PROGRAM_GROUP,
             REUNION_2023_MAILER.CLASS_YEAR,
             Reunion_2023_Mailer.SPOUSE_ID_NUMBER,
             REUNION_2023_MAILER.SPOUSE_PROGRAM,
             REUNION_2023_MAILER.SPOUSE_PROGRAM_GROUP,
            REUNION_2023_MAILER.Spouse_Reunion_Year
From REUNION_2023_MAILER),


--- Join Pref Mail Name IF spouses are in same Reunion year
p as (select p.ID_NUMBER,
       p.Joint_Prefname
from rpt_zrc8929.v_dean_salutation p),

--- KSM Spec
--- Take out the No Mails/No Contacts

KSM_Spec AS (Select spec.ID_NUMBER,
spec.NO_CONTACT,
spec.NO_MAIL_IND
From rpt_pbh634.v_entity_special_handling spec)


SELECT DISTINCT
   E.ID_NUMBER
  ,r.SPOUSE_ID_NUMBER
  ,E.PREF_MAIL_NAME AS PREF_MAIL_NAME1
  ,r.class_year as Pref_KSM_Reunion_Class_Year
  ,r.SPOUSE_PREF_MAIL_NAME
  ,r.Spouse_Reunion_Year as Spouse_Pref_Reunion_Class_Year
/* If spouses are celebrating together, then provide the joint pref mail name
we are still defaulting to the household primary, but giving the team an option*/
  ,case when r.Spouse_Reunion_Year is not null then p.Joint_Prefname
  end as joint_pref_name
  ,case when WT0_PKG.GetRestrictions(E.ID_NUMBER) like '%No Jnt Mail%' then 'No_Joint_Mail'
  end as No_Joint_Mail_IND
  ,A.ADDR_TYPE_CODE
  ,A.CARE_OF
  ,A.COMPANY_NAME_1 as Company_name
  ,A.STREET1
  ,A.STREET2
  ,A.STREET3
  ,DECODE(RTRIM(A.FOREIGN_CITYZIP),
              NULL, A.CITY,
              A.FOREIGN_CITYZIP) CITY
  ,A.STATE_CODE STATE
  ,A.ZIPCODE ZIP

FROM
ENTITY E
LEFT JOIN FINAL_SELECT EN
ON E.ID_NUMBER = EN.ID_NUMBER
LEFT JOIN ENTITY SP
ON EN.SPOUSE_ID = SP.ID_NUMBER
LEFT JOIN ADDRESS A
ON E.ID_NUMBER = A.ID_NUMBER
  AND A.ADDR_PREF_IND = 'Y'
  AND A.ADDR_STATUS_CODE = 'A'
LEFT JOIN rpt_pbh634.v_ksm_model_af_10k AFM
ON E.ID_NUMBER = AFM.ID_NUMBER
LEFT JOIN NO_EMAIL_SOL
ON E.ID_NUMBER = NO_EMAIL_SOL.ID_NUMBER
LEFT JOIN NO_EMAIL_SOL2
ON E.SPOUSE_ID_NUMBER = NO_EMAIL_SOL2.ID_NUMBER
LEFT JOIN KLC_YN KLCYN
ON E.ID_NUMBER = KLCYN.ID
LEFT JOIN TMS_COUNTRY C
ON A.COUNTRY_CODE = C.country_code
LEFT JOIN table(rpt_pbh634.ksm_pkg_tmp.tbl_special_handling_concat) SH
ON E.ID_NUMBER = SH.ID_NUMBER
LEFT JOIN EMAIL EM
ON E.ID_NUMBER = EM.ID_NUMBER
  AND EM.EMAIL_STATUS_CODE = 'A'
  AND EM.PREFERRED_IND = 'Y'
LEFT JOIN TMS_EMAIL_TYPE TEM
ON EM.EMAIL_TYPE_CODE = TEM.email_type_code
LEFT JOIN table(rpt_pbh634.ksm_pkg_tmp.tbl_special_handling_concat) SPSH
ON E.SPOUSE_ID_NUMBER = SPSH.ID_NUMBER
LEFT JOIN EMAIL SPEM
ON E.SPOUSE_ID_NUMBER = SPEM.ID_NUMBER
  AND SPEM.EMAIL_STATUS_CODE = 'A'
  AND SPEM.PREFERRED_IND = 'Y'
LEFT JOIN TMS_EMAIL_TYPE SPTEM
ON SPEM.EMAIL_TYPE_CODE = SPTEM.email_type_code
LEFT JOIN TELEPHONE T
ON E.ID_NUMBER = T.ID_NUMBER
  AND T.TELEPHONE_STATUS_CODE = 'A'
  AND T.PREFERRED_IND = 'Y'
LEFT JOIN TMS_TELEPHONE_TYPE PH
ON T.TELEPHONE_TYPE_CODE = PH.telephone_type_code
LEFT JOIN ADDRESS HA
ON E.ID_NUMBER = HA.ID_NUMBER
  AND HA.ADDR_TYPE_CODE = 'H'
  AND HA.ADDR_STATUS_CODE = 'A'
LEFT JOIN TMS_COUNTRY HC
ON HA.COUNTRY_CODE = HC.country_code
LEFT JOIN RPT_PBH634.V_ADDR_CONTINENTS HCON
ON HA.COUNTRY_CODE = HCON.country_code
LEFT JOIN ADDRESS BUS_ADDR
ON E.ID_NUMBER = BUS_ADDR.ID_NUMBER
  AND BUS_ADDR.ADDR_TYPE_CODE = 'B'
  AND BUS_ADDR.ADDR_STATUS_CODE = 'A'
LEFT JOIN TMS_COUNTRY BC
ON BUS_ADDR.COUNTRY_CODE = BC.country_code
LEFT JOIN RPT_PBH634.V_ADDR_CONTINENTS BCON
ON BUS_ADDR.COUNTRY_CODE = BCON.country_code
LEFT JOIN AMOUNTS AM
ON E.ID_NUMBER = AM.ID_NUMBER
LEFT JOIN PLEDGE_ROWS PR
  ON E.ID_NUMBER = PR.ID
LEFT JOIN KSM_MONEY KSMM
ON E.ID_NUMBER = KSMM.GIFT_DONOR_ID
LEFT JOIN RPT_PBH634.V_ENTITY_KSM_DEGREES D
ON E.ID_NUMBER = D.ID_NUMBER
LEFT JOIN KSM_MATCHES KM
ON E.ID_NUMBER = KM.GIFT_DONOR_ID
LEFT JOIN NU_PRS_TRP_PROSPECT P
ON E.ID_NUMBER = P.ID_NUMBER
LEFT JOIN NU_PRS_TRP_PROSPECT SPM
ON E.SPOUSE_ID_NUMBER = SPM.ID_NUMBER
LEFT JOIN PROPOSALS PROP
ON E.ID_NUMBER = PROP.ID_NUMBER
--- to get joint names
INNER JOIN p
ON p.id_number = e.id_number
--- Inner Join those in Reunion 2023
INNER JOIN r
on r.id_number = e.id_number
--- Special Handling Codes
LEFT JOIN ksm_spec
on ksm_spec.id_number = e.id_number
--- We want the primary household member
Where en.HOUSEHOLD_PRIMARY = 'Y'
and (ksm_spec.NO_CONTACT is null
and ksm_spec.NO_MAIL_IND is null)
ORDER BY Pref_KSM_Reunion_Class_Year ASC
