USE TestDB
GO

--numerate gender swimmers
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

		IF @check_list LIKE N'%Μΰλ%' OR  @check_list LIKE N'%ήν%'
		    UPDATE dbo.clean_Competitions 
            SET gender = N'μ'
            WHERE id = @number_id
		IF @check_list LIKE N'%Δεβ%'
		    UPDATE dbo.clean_Competitions 
            SET gender = N'δ'
            WHERE id = @number_id
	END
GO