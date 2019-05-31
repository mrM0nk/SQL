USE TestDB
GO


IF OBJECT_ID('dbo.[Group]', 'U') IS NOT NULL
    DROP TABLE dbo.[Group]
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