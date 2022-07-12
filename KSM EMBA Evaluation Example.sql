select m.id_number,
       m.REPORT_NAME,
       m.RECORD_STATUS_CODE,
       m.FIRST_KSM_YEAR,
       m.PROGRAM,
       m.PROGRAM_GROUP,
       m.CLASS_SECTION,
       m.Gender_Code,
       m.fld_of_work_code,
       m.fld_of_work,
       m.employer_name,
       m.job_title,
       m.HOUSEHOLD_CITY,
       m.HOUSEHOLD_STATE,
       m.HOUSEHOLD_ZIP,
       m.HOUSEHOLD_GEO_CODES,
       m.HOUSEHOLD_COUNTRY,
       m.HOUSEHOLD_CONTINENT,
       m.business_city,
       m.business_state_code,
       m.business_zipcode,
       m.business_country,
       m.BUSINESS_GEO_CODE,
       m.prospect_manager,
       m.lgos,
       m.managers,
       m.EVALUATION_RATING,
       m.OFFICER_RATING,
       m.pref_email_ind,
       m.GAB,
       m.TRUSTEE,
       m.NO_CONTACT,
       m.NO_SOLICIT,
       m.NO_PHONE_IND,
       m.NO_EMAIL_IND,
       m.NO_MAIL_IND
from VT_ALUMNI_MARKET_SHEET m
where m.PROGRAM_GROUP = 'EMP'
and m.EVALUATION_RATING IN ('B  $500K - $999K','A7 $1M - $1.9M','A6 $2M - $4.9M','A5 $5M - $9.9M',
'A4 $10M - $24.9M','A3 $25M - $49.9M')

Or

m.OFFICER_RATING IN ('B  $500K - $999K','A7 $1M - $1.9M',

'A6 $2M - $4.9M', 'A5 $5M - $9.9M', 'A4 $10M - $24.9M', 'A3 $25M - $49.9M')
Order by m.REPORT_NAME asc
