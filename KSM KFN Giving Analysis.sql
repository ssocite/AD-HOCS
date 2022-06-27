--- KFN Members

With KFN AS (select k.id_number,
       k.role,
       k.committee_title,
       k.short_desc,
       rpt_pbh634.ksm_pkg.get_fiscal_year (k.start_dt) as FY_Joined_KFN,
       k.start_dt,
       k.stop_dt
From table (rpt_pbh634.ksm_pkg.tbl_committee_KFN) k),

--- Giving Summary

g as (select n.ID_NUMBER,
n.CASH_CFY,
n.CASH_PFY1,
n.CASH_PFY2,
n.CASH_PFY3,
n.CASH_PFY4,
n.CASH_PFY5
from rpt_pbh634.v_ksm_giving_summary n),

--- Subquery to indicate year of joining KFN, which will be used for the before/after giving subquery

KFN_Give_Ind As (select KFN.ID_NUMBER,
Max(Case When cal.curr_fy = FY_Joined_KFN Then 'Yes' Else NULL End) as joined_kfn_cfy,
Max(Case When cal.curr_fy = FY_Joined_KFN + 1 Then 'Yes' Else NULL End) as joined_kfn_pfy1,
Max(Case When cal.curr_fy = FY_Joined_KFN + 2 Then 'Yes' Else NULL End) as joined_kfn_pfy2,
Max(Case When cal.curr_fy = FY_Joined_KFN + 3 Then 'Yes' Else NULL End) as joined_kfn_pfy3,
Max(Case When cal.curr_fy = FY_Joined_KFN + 4 Then 'Yes' Else NULL End) as joined_kfn_pfy4,
Max(Case When cal.curr_fy = FY_Joined_KFN + 5 Then 'Yes' Else NULL End) as joined_kfn_pfy5
from KFN
cross join rpt_pbh634.v_current_calendar cal
group BY KFN.ID_NUMBER),

--- Count Total KFN Years

KFN_Count As (Select distinct KFN.ID_NUMBER,
Sum (cal.curr_fy - FY_Joined_KFN) as years_in_kfn
from KFN
cross join rpt_pbh634.v_current_calendar cal
GROUP BY KFN.ID_NUMBER),

Before_kfn as ( select KFN_Give_Ind.id_number,

--- Before Joining KFN
Case when KFN_Give_Ind.joined_kfn_cfy  is not null then g.cash_pfy1
when KFN_Give_Ind.joined_kfn_pfy1 is not null then g.cash_pfy2
when KFN_Give_Ind.joined_kfn_pfy2 is not null then g.cash_pfy3
when KFN_Give_Ind.joined_kfn_pfy3 is not null then g.cash_pfy4
when KFN_Give_Ind.joined_kfn_pfy4 is not null then g.cash_pfy5  else 0 END as Cash_Year_Before_KFN
from KFN_Give_Ind
left join g on g.id_number = KFN_Give_Ind.id_number ),

--- After Joining KFN

After_KFN as (Select KFN_Give_Ind.id_number,
Case when KFN_Give_Ind.joined_kfn_pfy1 is not null then g.cash_cfy
when KFN_Give_Ind.joined_kfn_pfy2 is not null then g.cash_pfy1
when KFN_Give_Ind.joined_kfn_pfy3 is not null then g.cash_pfy2
when KFN_Give_Ind.joined_kfn_pfy4 is not null then g.cash_pfy3
when KFN_Give_Ind.joined_kfn_pfy5 is not null then g.cash_pfy4 else 0 END as Cash_Year_After_KFN
from KFN_Give_Ind
left join g on g.id_number = KFN_Give_Ind.id_number),

--- Giving in the Year of Joining KFN

Year_Joined as (Select KFN_Give_Ind.id_number,
Case when KFN_Give_Ind.joined_kfn_cfy is not null then g.cash_cfy
when KFN_Give_Ind.joined_kfn_pfy1 is not null then g.cash_pfy1
when KFN_Give_Ind.joined_kfn_pfy2 is not null then g.cash_pfy2
when KFN_Give_Ind.joined_kfn_pfy3 is not null then g.cash_pfy3
when KFN_Give_Ind.joined_kfn_pfy4 is not null then g.cash_pfy4
when KFN_Give_Ind.joined_kfn_pfy5 is not null then g.cash_pfy5 else 0 END as cash_Year_Joined_KFN
from KFN_Give_Ind
left join g on g.id_number = KFN_Give_Ind.id_number)

Select distinct KFN.ID_NUMBER,
entity.first_name,
entity.last_name,
--- Start of KFN Fiscal Year Date
KFN.FY_Joined_KFN,
Before_kfn.cash_Year_Before_KFN,
Year_Joined.cash_Year_Joined_KFN,
After_KFN.cash_Year_After_KFN,
KFN_Give_Ind.joined_kfn_cfy,
KFN_Give_Ind.joined_kfn_pfy1,
KFN_Give_Ind.joined_kfn_pfy2,
KFN_Give_Ind.joined_kfn_pfy3,
KFN_Give_Ind.joined_kfn_pfy4,
KFN_Give_Ind.joined_kfn_pfy5,
--- KLC Total Years on Record
KFN_COUNT.years_in_kfn
from KFN
left join entity on entity.id_number = KFN.id_number
left join KFN_Count on KFN_Count.ID_NUMBER = KFN.ID_NUMBER
left join KFN_Give_Ind on KFN_Give_Ind.ID_NUMBER = KFN.ID_NUMBER
left join Before_kfn on Before_kfn.id_number = KFN.ID_number
left join After_kfn on After_kfn.id_number = KFN.ID_number
left join Year_Joined on Year_Joined.id_number = KFN.ID_number
