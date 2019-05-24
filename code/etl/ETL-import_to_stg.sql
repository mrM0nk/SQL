USE TestDB
GO


TRUNCATE TABLE dbo.stg_Competitions

BULK INSERT dbo.stg_Competitions
FROM 'C:/temp/project/samples/protocol.csv'
   WITH (
      FORMAT = 'csv',
	  CODEPAGE = 65001,	 
	  FORMATFILE = 'c:/temp/project/samples/stg_competitions.fmt',
	  --firstrow = 1,
      FIELDTERMINATOR = ',' 
)
GO


