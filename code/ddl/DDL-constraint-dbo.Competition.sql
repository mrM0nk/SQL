USE TestDB
GO


IF OBJECT_ID('DF_Competition_ModifiedDate', 'D') IS NOT NULL
    ALTER TABLE dbo.Competition DROP CONSTRAINT DF_Competition_ModifiedDate
GO


ALTER TABLE dbo.Competition ADD CONSTRAINT DF_Competition_ModifiedDate DEFAULT GETDATE() FOR ModifiedDate
GO