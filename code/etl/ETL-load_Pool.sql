USE TestDB
GO

--��������� ������ � �������� � ����� ���������� ������������
INSERT INTO dbo.[Pool] (City, PoolSize)
SELECT pool_city, pool_description 
FROM dbo.clean_Competitions
GROUP BY pool_city, pool_description
GO