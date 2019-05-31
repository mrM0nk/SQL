USE TestDB
GO


IF OBJECT_ID('DF_Disqualification_ModifiedDate', 'D') IS NOT NULL
    ALTER TABLE dbo.Disqualification DROP CONSTRAINT DF_Disqualification_ModifiedDate
GO


ALTER TABLE dbo.Disqualification ADD CONSTRAINT DF_Disqualification_ModifiedDate DEFAULT GETDATE() FOR ModifiedDate
GO