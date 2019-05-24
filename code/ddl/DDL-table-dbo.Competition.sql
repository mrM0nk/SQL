USE TestDB
GO


DROP TABLE IF EXISTS dbo.Competition
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


ALTER TABLE dbo.Competition
    ADD CONSTRAINT DF_Competition_ModifiedDate DEFAULT GETDATE()
    FOR ModifiedDate
GO
