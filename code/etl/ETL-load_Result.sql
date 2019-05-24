USE TestDB
GO

--импортируем данные в таблицу Result
INSERT INTO dbo.Result (CompetitionID, SwimmerID, [Time])
SELECT CompetitionID, SwimmerID, result
FROM dbo.clean_Competitions
WHERE disc IS NULL
GO