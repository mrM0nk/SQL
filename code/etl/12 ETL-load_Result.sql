USE TestDB
GO

--load data to table Result
INSERT INTO dbo.Result (CompetitionID, SwimmerID, [Time])
SELECT CompetitionID, SwimmerID, result
FROM dbo.clean_Competitions
WHERE disc IS NULL
GO