USE TestDB
GO

--вставляем данные о стилях заплыва
INSERT INTO dbo.Discipline (Style, Distance)
SELECT style, distance
FROM dbo.clean_Competitions
GROUP BY style, distance
GO