USE TestDB
GO

--����������� ������ � ������� Competition
INSERT INTO dbo.Competition (GroupID, DisciplineID, PoolID, [Date])
SELECT GroupID, DisciplineID, PoolID, [date]
FROM dbo.clean_Competitions
GROUP BY GroupID, DisciplineID, PoolID, [date]
GO