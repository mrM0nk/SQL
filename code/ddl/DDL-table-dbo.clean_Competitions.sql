USE TestDB
GO


IF OBJECT_ID('dbo.clean_Competitions', 'U') IS NOT NULL
    DROP TABLE dbo.clean_Competitions
GO


CREATE TABLE dbo.clean_Competitions
(
    id               INT           NOT NULL IDENTITY,

    place            INT           NULL,
	last_name        NVARCHAR(50)  NULL,
	first_name       NVARCHAR(50)  NULL,
	birth_year       INT           NULL,
	city             NVARCHAR(50)  NULL,
	team             NVARCHAR(50)  NULL,
	country          NVARCHAR(50)  NULL,
	result           TIME(2)       NULL,
	disc             NVARCHAR(50)  NULL,
	points           INT           NULL,
	athlete_group    NVARCHAR(50)  NULL,
	distance         INT           NULL,
	style            NVARCHAR(50)  NULL,
	[date]           DATE          NULL,
	pool_city        NVARCHAR(50)  NULL,
	pool_description NVARCHAR(50)  NULL,
	gender           CHAR(1)       NULL,
	SwimmerID        INT           NULL,
	SwimmingClubID   INT           NULL,
	PoolID           INT           NULL,
	DisciplineID     INT           NULL,
	GroupID          INT           NULL,
	CompetitionID    INT           NULL,
	
	CONSTRAINT PK_clean_Competitions PRIMARY KEY
	(
	    id
	)
)
GO