USE TestDB
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