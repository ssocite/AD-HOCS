Select Entity.Id_Number,
       Entity.Record_Type_Code,
       Entity.Record_Status_Code,
       Entity.Institutional_Suffix,
       Degrees.School_Code,
       Degrees.Degree_Code,
       Degrees.Degree_Year,
       Degrees.Dept_Code
From Entity
Full Outer Join Degrees ON Entity.Id_Number = Degrees.Id_Number
Where Degrees.School_Code = 'KSM'
AND (Degrees.Degree_Code = 'MBA' OR Degrees.Degree_Code = 'MMM' OR Degrees.Degree_Code = 'MMGT')
AND Entity.Record_Type_Code = 'AL'
AND (Entity.Record_Status_Code = 'A' OR Entity.Record_Status_Code = 'L' OR Entity.Record_Status_Code = 'C')
