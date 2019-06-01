USE TestDB
GO

--load data sbout athlete group
INSERT INTO dbo.[Group] ([Name], Gender)
SELECT athlete_group, gender
FROM dbo.clean_Competitions
GROUP BY athlete_group, gender
GO