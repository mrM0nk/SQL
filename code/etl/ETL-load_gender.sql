USE TestDB
GO

--проставляем пол спортсмена
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