USE TestDB
GO


DROP TABLE IF EXISTS dbo.Result
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


ALTER TABLE dbo.Result
    ADD CONSTRAINT DF_Result_ModifiedDate DEFAULT GETDATE()
    FOR ModifiedDate
GO