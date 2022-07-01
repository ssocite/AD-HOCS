With birth as (select  entity.id_number,
rpt_pbh634.ksm_pkg.get_fiscal_year (entity.birth_dt) as birth_year,
entity.birth_dt
from entity)


select market.id_number,
       market.REPORT_NAME,
market.Gender_Code,
       market.FIRST_KSM_YEAR,
       birth.birth_year,
       market.PROGRAM,
       market.PROGRAM_GROUP,
       market.fld_of_work_code,
       market.fld_of_work,
       market.employer_name,
       market.job_title,

       ---- Create indicators of each city because the geocode data has a bunch - ALA Tableau Calculations on your markesheet.
       case when market.HOUSEHOLD_GEO_CODES IN ('Chicago', 'Chicago; Chicagoland' ,
'Chicago; Chicagoland; Gary IN; Northwest Indiana',
'Chicago; Gary IN; Northwest Indiana',
'Chicago; Madison WI; Milwaukee-Kenosha-Racine (SW WI)',
'Chicago; Milwaukee-Kenosha-Racine (SW WI)',
'Chicago; Rockford IL',
'Chicagoland',
'Chicagoland; Gary IN; Northwest Indiana') Then 'Chicago' Else '' END as City_IND,

market.HOUSEHOLD_CITY,
       market.HOUSEHOLD_STATE,
       market.HOUSEHOLD_ZIP,
       market.HOUSEHOLD_GEO_CODES

from vt_alumni_market_sheet market
left join birth on birth.id_number = market.id_number
where market.HOUSEHOLD_GEO_CODES IN
--- Chicago
('Chicago', 'Chicago; Chicagoland' ,
'Chicago; Chicagoland; Gary IN; Northwest Indiana',
'Chicago; Gary IN; Northwest Indiana',
'Chicago; Madison WI; Milwaukee-Kenosha-Racine (SW WI)',
'Chicago; Milwaukee-Kenosha-Racine (SW WI)',
'Chicago; Rockford IL',
'Chicagoland',
'Chicagoland; Gary IN; Northwest Indiana')
--- We Want Anyone Under 40
and (birth.birth_year > 1982
or (market.FIRST_KSM_YEAR > 2010 and birth.birth_year is null))
order by birth.birth_year asc
