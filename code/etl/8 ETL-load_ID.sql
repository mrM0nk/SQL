USE TestDB
GO

--import ID out of SwimmingClub, Pool, Discipline, Group
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