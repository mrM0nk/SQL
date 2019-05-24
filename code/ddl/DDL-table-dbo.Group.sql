USE TestDB
GO


DROP TABLE IF EXISTS dbo.[Group]
GO


CREATE TABLE dbo.[Group]
(
    GroupID          INT           NOT NULL IDENTITY,

	[Name]           NVARCHAR(50)  NOT NULL,
	Gender           NVARCHAR(20)  NOT NULL,
	LimitDescriprion NVARCHAR(255) NULL,
	ModifiedDate     DATETIME      NOT NULL,

	CONSTRAINT PK_Group PRIMARY KEY
	(
	    GroupID
	)
)
GO


ALTER TABLE dbo.[Group]
    ADD CONSTRAINT DF_Group_ModifiedDate DEFAULT GETDATE()
    FOR ModifiedDate
GO
