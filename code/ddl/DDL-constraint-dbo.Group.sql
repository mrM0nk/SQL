USE TestDB
GO


IF OBJECT_ID('DF_Group_ModifiedDate', 'D') IS NOT NULL
    ALTER TABLE dbo.[Group] DROP CONSTRAINT DF_Group_ModifiedDate
GO


ALTER TABLE dbo.[Group] ADD CONSTRAINT DF_Group_ModifiedDate DEFAULT GETDATE() FOR ModifiedDate
GO