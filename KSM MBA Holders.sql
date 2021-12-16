with MBA as (Select distinct degrees.ID_NUMBER,
       Degrees.Degree_Year
From Degrees
Where Degrees.School_Code = 'KSM'
AND (Degrees.Degree_Code = 'MBA' OR Degrees.Degree_Code = 'MMM' OR Degrees.Degree_Code = 'MMGT')
And Degrees.Degree_Year IN ('1987', '1990', '2006', '2007', '2010', '2011')
Order by Degrees.Degree_Year)
