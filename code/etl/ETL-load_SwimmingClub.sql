USE TestDB
GO

--вставляем данные о клубах спортсменов
INSERT INTO dbo.SwimmingClub (City, [NAME])
SELECT city, team 
FROM dbo.clean_Competitions
GROUP BY city, team 
GO