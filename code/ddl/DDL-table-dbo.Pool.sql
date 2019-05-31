USE TestDB
GO


IF OBJECT_ID('dbo.[Pool]', 'U') IS NOT NULL
    DROP TABLE dbo.[Pool]
GO


CREATE TABLE dbo.[Pool]
(
    PoolID       INT           NOT NULL IDENTITY,

	City         NVARCHAR(50)  NOT NULL,
	[Name]       NVARCHAR(100) NULL,
	PoolSize     NVARCHAR(50)  NOT NULL,
	ModifiedDate DATETIME      NOT NULL,

	CONSTRAINT PK_Pool PRIMARY KEY
	(
	    PoolID
	)
)
GO