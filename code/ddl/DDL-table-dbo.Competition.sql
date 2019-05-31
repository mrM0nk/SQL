USE TestDB
GO


IF OBJECT_ID('dbo.Competition', 'U') IS NOT NULL
    DROP TABLE dbo.Competition
GO


CREATE TABLE dbo.Competition
(
    CompetitionID INT      NOT NULL IDENTITY,

    GroupID       INT      NOT NULL,
	DisciplineID  INT      NOT NULL,
	PoolID        INT      NOT NULL,
	[Date]        DATE     NULL,
	ModifiedDate  DATETIME NOT NULL,

	CONSTRAINT PK_Competition PRIMARY KEY
	(
	    CompetitionID
	)
)
GO