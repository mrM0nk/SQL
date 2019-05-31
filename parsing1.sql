USE TestDB
GO


IF OBJECT_ID('dbo.stg_Competitions', 'U') IS NOT NULL
    DROP TABLE dbo.stg_Competitions
GO

CREATE TABLE dbo.stg_Competitions
(
    id  INT           NOT NULL IDENTITY,

    F1  NVARCHAR(255) NULL,
	F2  NVARCHAR(255) NULL,
	F3  NVARCHAR(255) NULL,
	F4  NVARCHAR(255) NULL,
	F5  NVARCHAR(255) NULL,
	F6  NVARCHAR(255) NULL,
	F7  NVARCHAR(255) NULL,
	F8  NVARCHAR(255) NULL,
	F9  NVARCHAR(255) NULL,

	CONSTRAINT PK_stg_Competitions PRIMARY KEY
	(
	    id
	)
)
GO


TRUNCATE TABLE dbo.stg_Competitions

BULK INSERT dbo.stg_Competitions
FROM 'C:\temp\sql\samples\protocol1.csv'
   WITH (
      FORMAT = 'csv',
	  CODEPAGE = 65001,	 
	  FORMATFILE = 'c:/temp/sql/samples/stg_competitions.fmt',
	  --firstrow = 1,
      FIELDTERMINATOR = ',' 
)
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


;WITH cte_trim_fields
AS
(
    SELECT LTRIM(RTRIM(F1)) AS F1,
           LTRIM(RTRIM(F2)) AS F2,
           LTRIM(RTRIM(F3)) AS F3,
           LTRIM(RTRIM(F4)) AS F4,
           LTRIM(RTRIM(F5)) AS F5,
           LTRIM(RTRIM(F6)) AS F6,
           LTRIM(RTRIM(F7)) AS F7,
           id
    FROM dbo.stg_Competitions
),
cte_competition_info
AS
(
    SELECT c.id, 
           c.F2 AS competition_info,
           RTRIM(LEFT(c.F2, CHARINDEX(',', c.F2) - 1)) AS pool_city,
           LTRIM(RIGHT(c.F2, CHARINDEX(',', REVERSE(c.F2)) - 1)) AS pool_description        
    FROM dbo.stg_Competitions c    
    JOIN dbo.stg_Competitions c3 on c.id+4 = c3.id    
    WHERE c3.F1 = '1' AND (CHARINDEX('-', c.F2)<>0)
),
cte_list_of_competition_days
AS
(
    SELECT c.id, 
           c.F2 AS competition_day
    FROM dbo.stg_Competitions c    
    JOIN dbo.stg_Competitions c3 ON c.id+3 = c3.id
    WHERE c3.F1 = '1' AND (CHARINDEX('-', c.F2)<>0)
),
cte_list_of_group_discipline
AS
(
    SELECT c.id, 
           c.F2 AS group_discipline
    FROM cte_trim_fields c
    JOIN cte_trim_fields c1 ON c.id+1 = c1.id
    JOIN cte_trim_fields c2 ON c.id+2 = c2.id
    WHERE (c1.F1 = '1' AND (CHARINDEX('-', c.F2)<>0)) OR 
          (c2.F1 = '1' AND (CHARINDEX('-', c.F2)<>0))
),
cte_list_of_ranges_competition_days
AS
(
    SELECT piv.start_id, ISNULL(end_id, num.cnt) end_id
    FROM 
    (
        SELECT id start_id, 
               lead(id) OVER(ORDER BY id) end_id
        FROM cte_list_of_competition_days
    ) piv
    CROSS JOIN (SELECT COUNT(1) cnt FROM dbo.stg_Competitions) num
),
cte_list_of_ranges_discipline
AS
(
    SELECT piv.start_id, ISNULL(end_id, num.cnt) end_id
    FROM 
    (
        SELECT id start_id, 
               lead(id) OVER(ORDER BY id) end_id
        FROM cte_list_of_group_discipline
    ) piv
    CROSS JOIN (SELECT COUNT(1) cnt FROM dbo.stg_Competitions) num    
),
cte_pivot
AS
(
    SELECT c.*, 
           gd.group_discipline, 
           cd.competition_day, 
           --ci.competition_info,
           ci.pool_city,
           ci.pool_description
    FROM cte_trim_fields c
    JOIN cte_list_of_ranges_discipline rd        ON c.id BETWEEN rd.start_id AND rd.end_id-1
    JOIN cte_list_of_group_discipline gd         ON gd.id = rd.start_id
    JOIN cte_list_of_ranges_competition_days rcd ON c.id BETWEEN rcd.start_id AND rcd.end_id-1
    JOIN cte_list_of_competition_days cd         ON cd.id = rcd.start_id
    CROSS JOIN cte_competition_info ci
),
cte_transform
AS
(
    SELECT 
           F1 AS place,

           IIF(CHARINDEX(' ', F2)<>0, LTRIM(RTRIM(LEFT(F2, CHARINDEX(' ', F2) - 1))), F2) AS last_name,
           IIF(CHARINDEX(' ', F2)<>0, LTRIM(RTRIM(RIGHT(F2, LEN(F2) - CHARINDEX(' ', F2)))), null) AS first_name,

           IIF(LEN(F3)=2, IIF(LEFT(F3, 1) IN ('8','9'), '19'+F3,'20'+F3), F3) AS birth_year,

           IIF(CHARINDEX(',', F4)<>0, LEFT(F4, CHARINDEX(',', F4) - 1), F4) AS city,
           IIF(CHARINDEX(',', F4)<>0, RIGHT(F4, LEN(F4) - CHARINDEX(',', F4)), NULL) AS team,
           
           F5 AS country,     
          
           IIF(CHARINDEX('D', F6)=0, IIF(LEN(F6)=2, F6+'.00', F6), NULL) AS result,
           IIF(CHARINDEX('D', F6)<>0, F6, NULL) AS disc,
           
           F7 as points,
              
           RTRIM(LEFT(group_discipline, LEN(group_discipline) - CHARINDEX('-', REVERSE(group_discipline)))) AS athlete_group,
           LTRIM(RIGHT(group_discipline, CHARINDEX('-', REVERSE(group_discipline)) - 1)) AS discipline,
           
           LTRIM(RIGHT(competition_day, LEN(competition_day) - CHARINDEX('-', competition_day))) AS [date],

           pool_city,
           pool_description,

           id
    FROM cte_pivot
    WHERE F1 IS NOT NULL
),
cte_parse_time
AS
(
    SELECT LEFT(result, LEN(result) - PATINDEX('%[:,.]%', REVERSE(result))) left_to_parse, 
           TRY_PARSE(RIGHT(result, PATINDEX('%[:,.]%', REVERSE(result)) - 1) AS INT) token,
           it = 1,
           id
    FROM cte_transform
    UNION ALL
    SELECT IIF(PATINDEX('%[:,.]%', REVERSE(left_to_parse)) <> 0, LEFT(left_to_parse, LEN(left_to_parse) - PATINDEX('%[:,.]%', REVERSE(left_to_parse))), '0') left_to_parse, 
           TRY_PARSE(IIF(PATINDEX('%[:,.]%', REVERSE(left_to_parse)) <> 0, RIGHT(left_to_parse, PATINDEX('%[:,.]%', REVERSE(left_to_parse)) - 1), left_to_parse) AS INT) token,
           it = it + 1,
           id
    FROM cte_parse_time
    WHERE it < 4     
), 
cte_clean_and_format
AS
(
    SELECT TRY_PARSE(place AS INT) place,
           LEFT(last_name, LEN(last_name) - CHARINDEX(' ', REVERSE(last_name))) last_name,
           LEFT(first_name, LEN(first_name) - CHARINDEX(' ', REVERSE(first_name))) first_name,
           TRY_PARSE(birth_year AS INT) birth_year,
           city,
           REPLACE(REPLACE(team, '"', ''), '''', '') team,
           country,
           TIMEFROMPARTS(h.token, m.token, s.token, ms.token, 2) result,
           disc,
           TRY_PARSE(points AS INT) points,           
           athlete_group,               
           TRY_PARSE(LEFT(discipline, CHARINDEX(' ', discipline)) AS INT) distance,
           RIGHT(discipline, LEN(discipline) - CHARINDEX(' ', discipline) ) AS style,
           TRY_CONVERT(DATE, [date], 104) [date],
           pool_city,
           pool_description,
           t.id
    FROM cte_transform t
    JOIN cte_parse_time h  ON t.id = h.id AND h.it = 4
    JOIN cte_parse_time m  ON t.id = m.id AND m.it = 3
    JOIN cte_parse_time s  ON t.id = s.id AND s.it = 2
    JOIN cte_parse_time ms ON t.id = ms.id AND ms.it = 1
)
INSERT INTO dbo.clean_Competitions (place, last_name, first_name, birth_year, city, team, country, result,
	                                disc, points, athlete_group, distance, style, [date], pool_city, pool_description)
SELECT place, LTRIM(RTRIM(last_name)), LTRIM(RTRIM(first_name)), LTRIM(RTRIM(birth_year)), city, team, 
        country, result, disc, points, athlete_group, distance, style, [date], pool_city, pool_description
FROM cte_clean_and_format
ORDER BY id
GO

--проставляем пол спортсмена
DECLARE @number_id INT
DECLARE @len_list INT
DECLARE @check_list NVARCHAR(50)

SET @number_id = 0
SET @len_list = (SELECT MAX(id)
				  FROM dbo.clean_Competitions)
SET @check_list = ''
WHILE @number_id < @len_list
    BEGIN
	    SET @number_id = @number_id + 1
		SELECT @check_list = athlete_group
        FROM dbo.clean_Competitions
		WHERE id = @number_id

		IF @check_list LIKE N'%Мал%' OR  @check_list LIKE N'%Юн%'
		    UPDATE dbo.clean_Competitions 
            SET gender = N'м'
            WHERE id = @number_id
		IF @check_list LIKE N'%Дев%'
		    UPDATE dbo.clean_Competitions 
            SET gender = N'д'
            WHERE id = @number_id
	END
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

IF OBJECT_ID('DF_Disqualification_ModifiedDate', 'D') IS NOT NULL
    ALTER TABLE dbo.Disqualification DROP CONSTRAINT DF_Disqualification_ModifiedDate
GO

ALTER TABLE dbo.Disqualification ADD CONSTRAINT DF_Disqualification_ModifiedDate DEFAULT GETDATE() FOR ModifiedDate
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

IF OBJECT_ID('DF_Result_ModifiedDate', 'D') IS NOT NULL
    ALTER TABLE dbo.Result DROP CONSTRAINT DF_Result_ModifiedDate
GO

ALTER TABLE dbo.Result ADD CONSTRAINT DF_Result_ModifiedDate DEFAULT GETDATE() FOR ModifiedDate
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

IF OBJECT_ID('DF_SwimmingClub_ModifiedDate', 'D') IS NOT NULL
    ALTER TABLE dbo.SwimmingClub DROP CONSTRAINT DF_SwimmingClub_ModifiedDate
GO

ALTER TABLE dbo.SwimmingClub ADD CONSTRAINT DF_SwimmingClub_ModifiedDate DEFAULT GETDATE() FOR ModifiedDate
GO


IF OBJECT_ID('dbo.Competition', 'U') IS NOT NULL
    DROP TABLE dbo.Competition
GO

CREATE TABLE dbo.Competition
(
    CompetitionID INT      NOT NULL IDENTITY,

    GroupID       INT      NOT NULL,
	DisciplineID  INT      NOT NULL,
	PoolID        INT      NOT NULL,
	[Date]        DATE     NULL,
	ModifiedDate  DATETIME NOT NULL,

	CONSTRAINT PK_Competition PRIMARY KEY
	(
	    CompetitionID
	)
)
GO

IF OBJECT_ID('DF_Competition_ModifiedDate', 'D') IS NOT NULL
    ALTER TABLE dbo.Competition DROP CONSTRAINT DF_Competition_ModifiedDate
GO

ALTER TABLE dbo.Competition ADD CONSTRAINT DF_Competition_ModifiedDate DEFAULT GETDATE() FOR ModifiedDate
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

IF OBJECT_ID('DF_Swimmer_ModifiedDate', 'D') IS NOT NULL
    ALTER TABLE dbo.Swimmer DROP CONSTRAINT DF_Swimmer_ModifiedDate
GO

ALTER TABLE dbo.Swimmer ADD CONSTRAINT DF_Swimmer_ModifiedDate DEFAULT GETDATE() FOR ModifiedDate
GO


IF OBJECT_ID('dbo.[Group]', 'U') IS NOT NULL
    DROP TABLE dbo.[Group]
GO

CREATE TABLE dbo.[Group]
(
    GroupID          INT           NOT NULL IDENTITY,

	[Name]           NVARCHAR(50)  NOT NULL,
	Gender           NVARCHAR(20)  NOT NULL,
	LimitDescriprion NVARCHAR(255) NULL,
	ModifiedDate     DATETIME      NOT NULL,

	CONSTRAINT PK_Group PRIMARY KEY
	(
	    GroupID
	)
)
GO

IF OBJECT_ID('DF_Group_ModifiedDate', 'D') IS NOT NULL
    ALTER TABLE dbo.[Group] DROP CONSTRAINT DF_Group_ModifiedDate
GO

ALTER TABLE dbo.[Group] ADD CONSTRAINT DF_Group_ModifiedDate DEFAULT GETDATE() FOR ModifiedDate
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

IF OBJECT_ID('DF_Discipline_ModifiedDate', 'D') IS NOT NULL
    ALTER TABLE dbo.Discipline DROP CONSTRAINT DF_Discipline_ModifiedDate
GO

ALTER TABLE dbo.Discipline ADD CONSTRAINT DF_Discipline_ModifiedDate DEFAULT GETDATE() FOR ModifiedDate
GO


IF OBJECT_ID('dbo.[Pool]', 'U') IS NOT NULL
    DROP TABLE dbo.[Pool]
GO

CREATE TABLE dbo.[Pool]
(
    PoolID       INT           NOT NULL IDENTITY,

	City         NVARCHAR(50)  NOT NULL,
	[Name]       NVARCHAR(100) NULL,
	PoolSize     NVARCHAR(50)  NOT NULL,
	ModifiedDate DATETIME      NOT NULL,

	CONSTRAINT PK_Pool PRIMARY KEY
	(
	    PoolID
	)
)
GO

IF OBJECT_ID('DF_Pool_ModifiedDate', 'D') IS NOT NULL
    ALTER TABLE dbo.[Pool] DROP CONSTRAINT DF_Pool_ModifiedDate
GO

ALTER TABLE dbo.[Pool] ADD CONSTRAINT DF_Pool_ModifiedDate DEFAULT GETDATE() FOR ModifiedDate
GO

--вставляем данные о клубах спортсменов
INSERT INTO dbo.SwimmingClub (City, [NAME])
SELECT city, team 
FROM dbo.clean_Competitions
GROUP BY city, team 
GO

--вставляем данные о бассейне и месте проведения соревнований
INSERT INTO dbo.[Pool] (City, PoolSize)
SELECT pool_city, pool_description 
FROM dbo.clean_Competitions
GROUP BY pool_city, pool_description
GO

--вставляем данные о группах плавцов на соревновании
INSERT INTO dbo.[Group]([Name], Gender)
SELECT athlete_group, gender
FROM dbo.clean_Competitions
GROUP BY athlete_group, gender
GO

--вставляем данные о стилях заплыва
INSERT INTO dbo.Discipline(Style, Distance)
SELECT style, distance
FROM dbo.clean_Competitions
GROUP BY style, distance
GO

--указываем ID в общей таблице из SwimmingClub, Pool, Discipline, Group
DECLARE @CleanID        INT
DECLARE @SwimmingClubID INT
DECLARE @PoolID         INT
DECLARE @DisciplineID   INT
DECLARE @GroupID        INT

DECLARE @LenCleanID        INT
DECLARE @LenSwimmingClubID INT
DECLARE @LenPoolID         INT
DECLARE @LenDisciplineID   INT
DECLARE @LenGroupID        INT

DECLARE @Check_clean_club       NVARCHAR(255)
DECLARE @Check_clean_pool       NVARCHAR(255)
DECLARE @Check_clean_discipline NVARCHAR(255)
DECLARE @Check_clean_group      NVARCHAR(255)

DECLARE @Check_club       NVARCHAR(255)
DECLARE @Check_pool       NVARCHAR(255)
DECLARE @Check_discipline NVARCHAR(255)
DECLARE @Check_group      NVARCHAR(255)

SET @CleanID = 0
SET @LenCleanID = (SELECT MAX(id) FROM dbo.clean_Competitions)
SET @Check_clean_club = ''
SET @Check_clean_pool = ''
SET @Check_clean_discipline = ''
SET @Check_clean_group = ''

WHILE @CleanID < @LenCleanID
    BEGIN
	    SET @CleanID = @CleanID + 1
		SELECT @Check_clean_club = city + team,
		       @Check_clean_pool = pool_city + pool_description,
			   @Check_clean_discipline = style + CONVERT(NVARCHAR, distance),
			   @Check_clean_group = athlete_group + gender
		FROM dbo.clean_Competitions
		WHERE id = @CleanID

		SET @SwimmingClubID = 0
        SET @LenSwimmingClubID = (SELECT MAX(SwimmingClubID) FROM dbo.SwimmingClub)
        SET @Check_club = ''

		WHILE @SwimmingClubID < @LenSwimmingClubID
		    BEGIN
		        SET @SwimmingClubID = @SwimmingClubID + 1
	    		SELECT @Check_club = City + [NAME]
	    		FROM dbo.SwimmingClub
	    		WHERE SwimmingClubID = @SwimmingClubID

		    	IF @Check_clean_club = @Check_club
		    	    UPDATE dbo.clean_Competitions
		    		SET SwimmingClubID = @SwimmingClubID
		    		WHERE id = @CleanID
		    END

		SET @PoolID = 0
        SET @LenPoolID = (SELECT MAX(PoolID) FROM dbo.[Pool])
        SET @Check_pool = ''

		WHILE @PoolID < @LenPoolID
		    BEGIN
		        SET @PoolID = @PoolID + 1
	    		SELECT @Check_pool = City + PoolSize
	    		FROM dbo.[Pool]
	    		WHERE PoolID = @PoolID 

	    		IF @Check_clean_pool = @Check_pool
	    		    UPDATE dbo.clean_Competitions
		    		SET PoolID = @PoolID
		    		WHERE id = @CleanID
		    END
		
		SET @DisciplineID = 0
        SET @LenDisciplineID = (SELECT MAX(DisciplineID) FROM dbo.Discipline)
        SET @Check_discipline = ''

		WHILE @DisciplineID < @LenDisciplineID
		    BEGIN
			    SET @DisciplineID = @DisciplineID + 1
				SELECT @Check_discipline = Style + CONVERT(NVARCHAR, Distance)
				FROM dbo.Discipline
				WHERE DisciplineID = @DisciplineID

				IF @Check_clean_discipline = @Check_discipline
				    UPDATE dbo.clean_Competitions
					SET DisciplineID = @DisciplineID
					WHERE id = @CleanID
			END
	    
		SET @GroupID = 0
        SET @LenGroupID = (SELECT MAX(DisciplineID) FROM dbo.Discipline)
        SET @Check_group = ''

		WHILE @GroupID < @LenGroupID
		    BEGIN
			    SET @GroupID = @GroupID + 1
				SELECT @Check_group = [Name] + Gender
				FROM dbo.[Group]
				WHERE GroupID = @GroupID

				IF @Check_clean_group = @Check_group
				    UPDATE dbo.clean_Competitions
					SET GroupID = @GroupID
					WHERE id = @CleanID
			END
	END
GO

--импортируем данные в таблицу Competition
INSERT INTO dbo.Competition (GroupID, DisciplineID, PoolID, [Date])
SELECT GroupID, DisciplineID, PoolID, [date]
FROM dbo.clean_Competitions
GROUP BY GroupID, DisciplineID, PoolID, [date]
GO

--импортируем данные в таблицу Swimmer
INSERT INTO dbo.Swimmer (LastName, FirstName, YearOfBirth, SwimmingClubID, Gender)
SELECT LTRIM(RTRIM(last_name)), LTRIM(RTRIM(first_name)), LTRIM(RTRIM(birth_year)), SwimmingClubID, gender
FROM dbo.clean_Competitions
GROUP BY last_name, first_name, birth_year, SwimmingClubID, gender
GO

--узнаем ид соревнования для каждого пловца
DECLARE @CleanID   INT
DECLARE @SwimmerID INT
DECLARE @CompID    INT

DECLARE @LenClean   INT
DECLARE @LenSwimmer INT
DECLARE @LenComp    INT

DECLARE @CheckCleanSwimmer NVARCHAR(255)
DECLARE @CheckCleanComp    NVARCHAR(255)
DECLARE @CheckSwimmer      NVARCHAR(255)
DECLARE @CheckComp         NVARCHAR(255)

SET @CleanID = 0
SET @LenClean = (SELECT MAX(id) FROM dbo.clean_Competitions)
SET @CheckCleanSwimmer = ''
SET @CheckCleanComp = ''

WHILE @CleanID < @LenClean
    BEGIN
	    SET @CleanID = @CleanID + 1
		SELECT @CheckCleanSwimmer = LTRIM(RTRIM(last_name)) + LTRIM(RTRIM(first_name)) + CONVERT(NVARCHAR, birth_year),
		       @CheckCleanComp = CONVERT(NVARCHAR, GroupID) + CONVERT(NVARCHAR, DisciplineID) + CONVERT(NVARCHAR, PoolID) + CONVERT(NVARCHAR, [Date])
		FROM dbo.clean_Competitions
		WHERE id = @CleanID

		SET @SwimmerID = 0
		SET @LenSwimmer = (SELECT MAX(SwimmerID) FROM dbo.Swimmer)
		SET @CheckSwimmer = ''

		WHILE @SwimmerID < @LenSwimmer
		    BEGIN
			    SET @SwimmerID = @SwimmerID + 1
				SELECT @CheckSwimmer = LTRIM(RTRIM(LastName)) + LTRIM(RTRIM(FirstName)) + CONVERT(NVARCHAR, YearOfBirth)
		        FROM dbo.Swimmer
		        WHERE SwimmerID = @SwimmerID

				IF @CheckCleanSwimmer = @CheckSwimmer
				    UPDATE dbo.clean_Competitions
					SET SwimmerID = @SwimmerID
					WHERE id = @CleanID
			END

		SET @CompID = 0
		SET @LenComp = (SELECT MAX(CompetitionID) FROM dbo.Competition)
		SET @CheckComp = ''

		WHILE @CompID < @LenComp
		    BEGIN
			    SET @CompID = @CompID + 1
				SELECT @CheckComp = CONVERT(NVARCHAR, GroupID) + CONVERT(NVARCHAR, DisciplineID) + CONVERT(NVARCHAR, PoolID) + CONVERT(NVARCHAR, [Date])
				FROM dbo.Competition
				WHERE CompetitionID = @CompID

				IF @CheckCleanComp = @CheckComp
				    UPDATE dbo.clean_Competitions
					SET CompetitionID = @CompID
					WHERE id = @CleanID
			END
	END
GO

--импортируем данные в таблицу Result
INSERT INTO dbo.Result (CompetitionID, SwimmerID, [Time])
SELECT CompetitionID, SwimmerID, result
FROM dbo.clean_Competitions
WHERE disc IS NULL
GO

--импортируем данные в таблицу Result
INSERT INTO dbo.Disqualification ( CompetitionID, SwimmerID)
SELECT CompetitionID, SwimmerID
FROM dbo.clean_Competitions
WHERE disc IS NOT NULL
GO







