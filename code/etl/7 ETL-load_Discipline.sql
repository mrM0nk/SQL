USE TestDB
GO

--��������� ������ � ������ �������
INSERT INTO dbo.Discipline (Style, Distance)
SELECT style, distance
FROM dbo.clean_Competitions
GROUP BY style, distance
GO