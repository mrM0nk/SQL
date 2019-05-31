USE TestDB
GO


IF OBJECT_ID('dbo.Result', 'U') IS NOT NULL
    DROP TABLE dbo.Result
GO


CREATE TABLE dbo.Result
(
    ResultID      INT      NOT NULL IDENTITY,

    CompetitionID INT      NOT NULL,
	SwimmerID     INT      NOT NULL,
	[Time]        TIME(2)  NOT NULL,
	ModifiedDate  DATETIME NOT NULL,

	CONSTRAINT PK_Result PRIMARY KEY
	(
	    ResultID
	)
)
GO