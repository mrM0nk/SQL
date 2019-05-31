USE TestDB
GO


IF OBJECT_ID('dbo.Disqualification', 'U') IS NOT NULL
    DROP TABLE dbo.Disqualification
GO


CREATE TABLE dbo.Disqualification
(
    DisqualificationID INT          NOT NULL IDENTITY,

    CompetitionID      INT          NOT NULL,
	SwimmerID          INT          NOT NULL,
	Reason             NVARCHAR(50) NULL,
	ModifiedDate       DATETIME     NOT NULL,

	CONSTRAINT PK_Disqualification PRIMARY KEY
	(
	    DisqualificationID
	)
)
GO