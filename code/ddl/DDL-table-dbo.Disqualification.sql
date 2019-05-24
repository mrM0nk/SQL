USE TestDB
GO


DROP TABLE IF EXISTS dbo.Disqualification
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

ALTER TABLE dbo.Disqualification
    ADD CONSTRAINT DF_Disqualification_ModifiedDate DEFAULT GETDATE()
    FOR ModifiedDate
GO