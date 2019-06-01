USE TestDB
GO

--load data about clubs
INSERT INTO dbo.SwimmingClub (City, [NAME])
SELECT city, team 
FROM dbo.clean_Competitions
GROUP BY city, team 
GO