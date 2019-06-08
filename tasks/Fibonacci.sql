;WITH Fibonacci(iter,a,b,c)
AS
(
	SELECT iter=1, a=1, b=1, c=1+1
	UNION ALL
	SELECT iter+1, a=b, b=c, c=b+c
	FROM Fibonacci
	WHERE b<1000
)
SELECT 'Fibonacci(' + CAST(iter AS VARCHAR) + ') =' + CAST(a AS VARCHAR) AS [output]
FROM Fibonacci
GO