USE TestDB
GO

--импортируем данные в таблицу Swimmer
INSERT INTO dbo.Swimmer (LastName, FirstName, YearOfBirth, SwimmingClubID, Gender)
SELECT LTRIM(RTRIM(last_name)), LTRIM(RTRIM(first_name)), LTRIM(RTRIM(birth_year)), SwimmingClubID, gender
FROM dbo.clean_Competitions
GROUP BY last_name, first_name, birth_year, SwimmingClubID, gender
GO