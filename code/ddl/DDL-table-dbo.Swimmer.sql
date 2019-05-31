USE TestDB
GO


IF OBJECT_ID('dbo.Swimmer', 'U') IS NOT NULL
    DROP TABLE dbo.Swimmer
GO


CREATE TABLE dbo.Swimmer
(
    SwimmerID      INT          NOT NULL IDENTITY,

    SwimmingClubID INT          NOT NULL,
	FirstName      NVARCHAR(50) NOT NULL,
	LastName       NVARCHAR(50) NOT NULL,
	YearOfBirth    INT          NOT NULL,
	Gender         NVARCHAR(20) NOT NULL,
	ModifiedDate   DATETIME     NOT NULL,

	CONSTRAINT PK_Swimmer PRIMARY KEY
	(
	    SwimmerID
	)
)
GO