USE TestDB
GO

--load data about styles
INSERT INTO dbo.Discipline (Style, Distance)
SELECT style, distance
FROM dbo.clean_Competitions
GROUP BY style, distance
GO