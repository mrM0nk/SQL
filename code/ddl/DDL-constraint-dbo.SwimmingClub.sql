USE TestDB
GO


IF OBJECT_ID('DF_SwimmingClub_ModifiedDate', 'D') IS NOT NULL
    ALTER TABLE dbo.SwimmingClub DROP CONSTRAINT DF_SwimmingClub_ModifiedDate
GO


ALTER TABLE dbo.SwimmingClub ADD CONSTRAINT DF_SwimmingClub_ModifiedDate DEFAULT GETDATE() FOR ModifiedDate
GO