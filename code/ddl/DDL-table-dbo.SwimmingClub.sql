USE TestDB
GO


DROP TABLE IF EXISTS dbo.SwimmingClub
GO


CREATE TABLE dbo.SwimmingClub
(
    SwimmingClubID  INT           NOT NULL IDENTITY,

    [NAME]          NVARCHAR(50)  NULL,
	City            NVARCHAR(50)  NOT NULL,
	[Address]       NVARCHAR(100) NULL,
	Phone           INT           NULL,
	YearEstablished INT           NULL,
	ModifiedDate    DATETIME      NOT NULL,

	CONSTRAINT PK_SwimmingClub PRIMARY KEY
	(
	    SwimmingClubID
	)
)
GO


ALTER TABLE dbo.SwimmingClub
    ADD CONSTRAINT DF_SwimmingClub_ModifiedDate DEFAULT GETDATE()
    FOR ModifiedDate
GO