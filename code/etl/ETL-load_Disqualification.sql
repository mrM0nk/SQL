USE TestDB
GO

--����������� ������ � ������� Disqualification
INSERT INTO dbo.Disqualification ( CompetitionID, SwimmerID)
SELECT CompetitionID, SwimmerID
FROM dbo.clean_Competitions
WHERE disc IS NOT NULL
GO