USE TestDB
GO


IF OBJECT_ID('DF_Swimmer_ModifiedDate', 'D') IS NOT NULL
    ALTER TABLE dbo.Swimmer DROP CONSTRAINT DF_Swimmer_ModifiedDate
GO


ALTER TABLE dbo.Swimmer ADD CONSTRAINT DF_Swimmer_ModifiedDate DEFAULT GETDATE() FOR ModifiedDate
GO