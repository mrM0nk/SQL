USE TestDB
GO

--����������� ��� ����������
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

		IF @check_list LIKE N'%���%' OR  @check_list LIKE N'%��%'
		    UPDATE dbo.clean_Competitions 
            SET gender = N'�'
            WHERE id = @number_id
		IF @check_list LIKE N'%���%'
		    UPDATE dbo.clean_Competitions 
            SET gender = N'�'
            WHERE id = @number_id
	END
GO