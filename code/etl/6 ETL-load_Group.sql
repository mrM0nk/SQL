USE TestDB
GO

--вставляем данные о группах плавцов на соревновании
INSERT INTO dbo.[Group] ([Name], Gender)
SELECT athlete_group, gender
FROM dbo.clean_Competitions
GROUP BY athlete_group, gender
GO