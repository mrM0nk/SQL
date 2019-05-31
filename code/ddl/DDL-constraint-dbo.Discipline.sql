USE TestDB
GO


IF OBJECT_ID('DF_Discipline_ModifiedDate', 'D') IS NOT NULL
    ALTER TABLE dbo.Discipline DROP CONSTRAINT DF_Discipline_ModifiedDate
GO


ALTER TABLE dbo.Discipline ADD CONSTRAINT DF_Discipline_ModifiedDate DEFAULT GETDATE() FOR ModifiedDate
GO