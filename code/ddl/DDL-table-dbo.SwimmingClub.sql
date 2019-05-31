USE TestDB
GO


IF OBJECT_ID('dbo.SwimmingClub', 'U') IS NOT NULL
    DROP TABLE dbo.SwimmingClub
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