USE TestDB
GO


DROP TABLE IF EXISTS dbo.Discipline
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


ALTER TABLE dbo.Discipline
    ADD CONSTRAINT DF_Discipline_ModifiedDate DEFAULT GETDATE()
    FOR ModifiedDate
GO
