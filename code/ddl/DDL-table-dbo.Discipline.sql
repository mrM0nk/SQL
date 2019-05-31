USE TestDB
GO


IF OBJECT_ID('dbo.Discipline', 'U') IS NOT NULL
    DROP TABLE dbo.Discipline
GO


CREATE TABLE dbo.Discipline
(
    DisciplineID INT          NOT NULL IDENTITY,

	Style        NVARCHAR(50) NOT NULL,
	Distance     INT          NOT NULL,
	ModifiedDate DATETIME     NOT NULL,

	CONSTRAINT PK_Discipline PRIMARY KEY
	(
	    DisciplineID
	)
)
GO