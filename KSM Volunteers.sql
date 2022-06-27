--- Club Leaders

with leader as (select distinct v_ksm_club_leaders.id_Number
from v_ksm_club_leaders),

 --- Kellogg Admission Leadership Council
kalc as(
select distinct k.id_number
       FROM TABLE(rpt_pbh634.ksm_pkg.tbl_committee_KALC) k),

 --- Kellogg Alumni Council

 kac as( select distinct
ka.id_number
FROM TABLE(rpt_pbh634.ksm_pkg.tbl_committee_kac) ka),

--- Kellogg Real Estate

 rea as ( select distinct
re.id_number
FROM TABLE(rpt_pbh634.ksm_pkg.tbl_committee_RealEstCouncil) re),

--- Kellogg Global Advisory Board

gab as (select distinct
g.id_number
FROM TABLE(rpt_pbh634.ksm_pkg.tbl_committee_gab) g),

--- Kellogg Pete Henderson Society

phs as (select distinct p.id_number
FROM TABLE(rpt_pbh634.ksm_pkg.tbl_committee_phs) p),

--- Kellogg Private Equity Advisory Council

 pea as (select distinct pe.id_number
FROM TABLE(rpt_pbh634.ksm_pkg.tbl_committee_privateequity) pe),

--- Kellogg Executive Board for Asia

kasia as (select distinct pe.id_number
FROM TABLE(rpt_pbh634.ksm_pkg.tbl_committee_asia) pe),

--- Kellogg Speakers

Speak as (select distinct
act.id_number
  FROM  activity act
 WHERE  act.activity_code = 'KSP'
   AND  act.activity_participation_code = 'P'),


   --- Kellogg Alumni Mentoring Program
mentor as (select distinct

comm.id_number
  FROM  committee comm
 WHERE  comm.committee_code = 'KACMP'
   AND  comm.committee_status_code = 'C'),

kic as (select distinct  ki.id_number
       FROM TABLE(rpt_pbh634.ksm_pkg.tbl_committee_kic) ki),

Spec AS (Select rpt_pbh634.v_entity_special_handling.ID_NUMBER,
       rpt_pbh634.v_entity_special_handling.GAB,
       rpt_pbh634.v_entity_special_handling.TRUSTEE,
       rpt_pbh634.v_entity_special_handling.NO_CONTACT,
       rpt_pbh634.v_entity_special_handling.NO_SOLICIT,
       rpt_pbh634.v_entity_special_handling.NO_PHONE_IND,
       rpt_pbh634.v_entity_special_handling.NO_EMAIL_IND,
       rpt_pbh634.v_entity_special_handling.NO_MAIL_IND,
       rpt_pbh634.v_entity_special_handling.SPECIAL_HANDLING_CONCAT
From rpt_pbh634.v_entity_special_handling)


select h.ID_NUMBER,
       entity.institutional_suffix,
       h.REPORT_NAME,
       h.FIRST_KSM_YEAR,
       h.PROGRAM,
       h.PROGRAM_GROUP,
       case when leader.id_number is not null then 'Club Leader' End as club_Leader_IND,
       case when kalc.id_number is not null then 'KALC' End as Kalc_IND,
       case when speak.id_number is not null then 'Speaker' End as Speaker_IND,
       case when mentor.id_number is not null then 'Mentor' End as Mentor_IND,
case when kac.id_number is not null then 'KAC' End as KAC_IND,
case when kic.id_number is not null then 'KIC' End as KIC_IND,
case when rea.id_number is not null then 'Real Estate' End as Real_Estate_IND,
case when pea.id_number is not null then 'Private Equity Advisory Council' End as Private_Equity_IND,
case when kasia.id_number is not null then 'Kellogg Executive Board for Asia' End as Exec_Board_Asia_IND,
case when gab.id_number is not null then 'GAB' End as GAB_IND,
case when phs.id_number is not null then 'PHS' End as PHS_IND,
spec.NO_CONTACT,
spec.NO_EMAIL_IND


from rpt_pbh634.v_entity_ksm_households h
left join leader on leader.id_number = h.id_number
left join kalc on kalc.id_number = h.id_number
left join kac on kac.id_number = h.id_number
left join kic on kic.id_number = h.id_number
left join rea on rea.id_number = h.id_number
left join gab on gab.id_number = h.id_number
left join speak on speak.id_number = h.id_number
left join mentor on mentor.id_number = h.id_number
left join phs on phs.id_number = h.id_number
left join entity on entity.id_number = h.id_number
left join pea on pea.id_number = h.id_number
left join kasia on kasia.id_number = h.id_number
left join spec on spec.id_number = h.id_number
where

(leader.id_number is not null or
kalc.id_number is not null or
speak.id_number is not null or
mentor.id_number is not null)
and h.PROGRAM is not null
