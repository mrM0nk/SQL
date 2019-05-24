USE TestDB
GO


DROP TABLE IF EXISTS dbo.[Pool]
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


ALTER TABLE dbo.[Pool]
    ADD CONSTRAINT DF_Pool_ModifiedDate DEFAULT GETDATE()
    FOR ModifiedDate
GO