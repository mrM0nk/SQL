USE TestDB
GO


IF OBJECT_ID('DF_Result_ModifiedDate', 'D') IS NOT NULL
    ALTER TABLE dbo.Result DROP CONSTRAINT DF_Result_ModifiedDate
GO


ALTER TABLE dbo.Result ADD CONSTRAINT DF_Result_ModifiedDate DEFAULT GETDATE() FOR ModifiedDate
GO