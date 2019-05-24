USE TestDB
GO

--проставл€ем пол спортсмена
DECLARE @number_id INT
DECLARE @len_list INT
DECLARE @check_list NVARCHAR(50)

SET @number_id = 0
SET @len_list = (SELECT MAX(id) FROM dbo.clean_Competitions)
SET @check_list = ''
WHILE @number_id < @len_list
    BEGIN
	    SET @number_id = @number_id + 1
		SELECT @check_list = athlete_group
        FROM dbo.clean_Competitions
		WHERE id = @number_id

		IF @check_list LIKE N'%ћал%' OR  @check_list LIKE N'%ён%'
		    UPDATE dbo.clean_Competitions 
            SET gender = N'м'
            WHERE id = @number_id
		IF @check_list LIKE N'%ƒев%'
		    UPDATE dbo.clean_Competitions 
            SET gender = N'д'
            WHERE id = @number_id
	END
GO

--вставл€ем данные о клубах спортсменов
INSERT INTO dbo.SwimmingClub (City, [NAME])
SELECT city, team 
FROM dbo.clean_Competitions
GROUP BY city, team 
GO

--вставл€ем данные о бассейне и месте проведени€ соревнований
INSERT INTO dbo.[Pool] (City, PoolSize)
SELECT pool_city, pool_description 
FROM dbo.clean_Competitions
GROUP BY pool_city, pool_description
GO

--вставл€ем данные о группах плавцов на соревновании
INSERT INTO dbo.[Group] ([Name], Gender)
SELECT athlete_group, gender
FROM dbo.clean_Competitions
GROUP BY athlete_group, gender
GO

--вставл€ем данные о стил€х заплыва
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

--узнаем ид соревновани€ дл€ каждого пловца
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

--импортируем данные в таблицу Disqualification
INSERT INTO dbo.Disqualification ( CompetitionID, SwimmerID)
SELECT CompetitionID, SwimmerID
FROM dbo.clean_Competitions
WHERE disc IS NOT NULL
GO