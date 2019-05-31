USE TestDB
GO


IF OBJECT_ID('DF_Pool_ModifiedDate', 'D') IS NOT NULL
    ALTER TABLE dbo.[Pool] DROP CONSTRAINT DF_Pool_ModifiedDate
GO


ALTER TABLE dbo.[Pool] ADD CONSTRAINT DF_Pool_ModifiedDate DEFAULT GETDATE() FOR ModifiedDate
GO