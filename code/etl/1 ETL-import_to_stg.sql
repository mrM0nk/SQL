USE TestDB
GO


TRUNCATE TABLE dbo.stg_Competitions

BULK INSERT dbo.stg_Competitions
FROM 'C:/temp/sql/samples/protocol1.csv'
   WITH (
      FORMAT = 'csv',
	  CODEPAGE = 65001,	 
	  FORMATFILE = 'c:/temp/project/samples/stg_competitions.fmt',
	  --firstrow = 1,
      FIELDTERMINATOR = ',' 
)
GO
