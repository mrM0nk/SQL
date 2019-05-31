USE TestDB
GO


;WITH cte_trim_fields
AS
(
    SELECT LTRIM(RTRIM(F1)) AS F1,
           LTRIM(RTRIM(F2)) AS F2,
           LTRIM(RTRIM(F3)) AS F3,
           LTRIM(RTRIM(F4)) AS F4,
           LTRIM(RTRIM(F5)) AS F5,
           LTRIM(RTRIM(F6)) AS F6,
           LTRIM(RTRIM(F7)) AS F7,
           id
    FROM dbo.stg_Competitions
),
cte_competition_info
AS
(
    SELECT c.id, 
           c.F2 AS competition_info,
           RTRIM(LEFT(c.F2, CHARINDEX(',', c.F2) - 1)) AS pool_city,
           LTRIM(RIGHT(c.F2, CHARINDEX(',', REVERSE(c.F2)) - 1)) AS pool_description        
    FROM dbo.stg_Competitions c    
    JOIN dbo.stg_Competitions c3 on c.id+4 = c3.id    
    WHERE c3.F1 = '1' AND (CHARINDEX('-', c.F2)<>0)
),
cte_list_of_competition_days
AS
(
    SELECT c.id, 
           c.F2 AS competition_day
    FROM dbo.stg_Competitions c    
    JOIN dbo.stg_Competitions c3 ON c.id+3 = c3.id
    WHERE c3.F1 = '1' AND (CHARINDEX('-', c.F2)<>0)
),
cte_list_of_group_discipline
AS
(
    SELECT c.id, 
           c.F2 AS group_discipline
    FROM cte_trim_fields c
    JOIN cte_trim_fields c1 ON c.id+1 = c1.id
    JOIN cte_trim_fields c2 ON c.id+2 = c2.id
    WHERE (c1.F1 = '1' AND (CHARINDEX('-', c.F2)<>0)) OR 
          (c2.F1 = '1' AND (CHARINDEX('-', c.F2)<>0))
),
cte_list_of_ranges_competition_days
AS
(
    SELECT piv.start_id, ISNULL(end_id, num.cnt) end_id
    FROM 
    (
        SELECT id start_id, 
               lead(id) OVER(ORDER BY id) end_id
        FROM cte_list_of_competition_days
    ) piv
    CROSS JOIN (SELECT COUNT(1) cnt FROM dbo.stg_Competitions) num
),
cte_list_of_ranges_discipline
AS
(
    SELECT piv.start_id, ISNULL(end_id, num.cnt) end_id
    FROM 
    (
        SELECT id start_id, 
               lead(id) OVER(ORDER BY id) end_id
        FROM cte_list_of_group_discipline
    ) piv
    CROSS JOIN (SELECT COUNT(1) cnt FROM dbo.stg_Competitions) num    
),
cte_pivot
AS
(
    SELECT c.*, 
           gd.group_discipline, 
           cd.competition_day, 
           --ci.competition_info,
           ci.pool_city,
           ci.pool_description
    FROM cte_trim_fields c
    JOIN cte_list_of_ranges_discipline rd        ON c.id BETWEEN rd.start_id AND rd.end_id-1
    JOIN cte_list_of_group_discipline gd         ON gd.id = rd.start_id
    JOIN cte_list_of_ranges_competition_days rcd ON c.id BETWEEN rcd.start_id AND rcd.end_id-1
    JOIN cte_list_of_competition_days cd         ON cd.id = rcd.start_id
    CROSS JOIN cte_competition_info ci
),
cte_transform
AS
(
    SELECT 
           F1 AS place,

           IIF(CHARINDEX(' ', F2)<>0, LTRIM(RTRIM(LEFT(F2, CHARINDEX(' ', F2) - 1))), F2) AS last_name,
           IIF(CHARINDEX(' ', F2)<>0, LTRIM(RTRIM(RIGHT(F2, LEN(F2) - CHARINDEX(' ', F2)))), null) AS first_name,

           IIF(LEN(F3)=2, IIF(LEFT(F3, 1) IN ('8','9'), '19'+F3,'20'+F3), F3) AS birth_year,

           IIF(CHARINDEX(',', F4)<>0, LEFT(F4, CHARINDEX(',', F4) - 1), F4) AS city,
           IIF(CHARINDEX(',', F4)<>0, RIGHT(F4, LEN(F4) - CHARINDEX(',', F4)), NULL) AS team,
           
           F5 AS country,     
          
           IIF(CHARINDEX('D', F6)=0, IIF(LEN(F6)=2, F6+'.00', F6), NULL) AS result,
           IIF(CHARINDEX('D', F6)<>0, F6, NULL) AS disc,
           
           F7 as points,
              
           RTRIM(LEFT(group_discipline, LEN(group_discipline) - CHARINDEX('-', REVERSE(group_discipline)))) AS athlete_group,
           LTRIM(RIGHT(group_discipline, CHARINDEX('-', REVERSE(group_discipline)) - 1)) AS discipline,
           
           LTRIM(RIGHT(competition_day, LEN(competition_day) - CHARINDEX('-', competition_day))) AS [date],

           pool_city,
           pool_description,

           id
    FROM cte_pivot
    WHERE F1 IS NOT NULL
),
cte_parse_time
AS
(
    SELECT LEFT(result, LEN(result) - PATINDEX('%[:,.]%', REVERSE(result))) left_to_parse, 
           TRY_PARSE(RIGHT(result, PATINDEX('%[:,.]%', REVERSE(result)) - 1) AS INT) token,
           it = 1,
           id
    FROM cte_transform
    UNION ALL
    SELECT IIF(PATINDEX('%[:,.]%', REVERSE(left_to_parse)) <> 0, LEFT(left_to_parse, LEN(left_to_parse) - PATINDEX('%[:,.]%', REVERSE(left_to_parse))), '0') left_to_parse, 
           TRY_PARSE(IIF(PATINDEX('%[:,.]%', REVERSE(left_to_parse)) <> 0, RIGHT(left_to_parse, PATINDEX('%[:,.]%', REVERSE(left_to_parse)) - 1), left_to_parse) AS INT) token,
           it = it + 1,
           id
    FROM cte_parse_time
    WHERE it < 4     
), 
cte_clean_and_format
AS
(
    SELECT TRY_PARSE(place AS INT) place,
           LEFT(last_name, LEN(last_name) - CHARINDEX(' ', REVERSE(last_name))) last_name,
           LEFT(first_name, LEN(first_name) - CHARINDEX(' ', REVERSE(first_name))) first_name,
           TRY_PARSE(birth_year AS INT) birth_year,
           city,
           REPLACE(REPLACE(team, '"', ''), '''', '') team,
           country,
           TIMEFROMPARTS(h.token, m.token, s.token, ms.token, 2) result,
           disc,
           TRY_PARSE(points AS INT) points,           
           athlete_group,               
           TRY_PARSE(LEFT(discipline, CHARINDEX(' ', discipline)) AS INT) distance,
           RIGHT(discipline, LEN(discipline) - CHARINDEX(' ', discipline) ) AS style,
           TRY_CONVERT(DATE, [date], 104) [date],
           pool_city,
           pool_description,
           t.id
    FROM cte_transform t
    JOIN cte_parse_time h  ON t.id = h.id AND h.it = 4
    JOIN cte_parse_time m  ON t.id = m.id AND m.it = 3
    JOIN cte_parse_time s  ON t.id = s.id AND s.it = 2
    JOIN cte_parse_time ms ON t.id = ms.id AND ms.it = 1
)
INSERT INTO dbo.clean_Competitions (place, last_name, first_name, birth_year, city, team, country, result,
	                                disc, points, athlete_group, distance, style, [date], pool_city, pool_description)
SELECT place, LTRIM(RTRIM(last_name)), LTRIM(RTRIM(first_name)), LTRIM(RTRIM(birth_year)), city, team, 
        country, result, disc, points, athlete_group, distance, style, [date], pool_city, pool_description
FROM cte_clean_and_format
ORDER BY id
GO