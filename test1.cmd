@echo on
echo starting scripts > test2.txt
set work_dir=%~dp0
for %%B in (%work_dir%code\ddl\*table*.sql %work_dir%code\ddl\*constraint*.sql) do ((echo -- processing %%B >> test2.txt)&(sqlcmd -S . -i %%B >> test2.txt))

for /L %%C in(%work_dir%code\etl\1 *.sql, 1, %work_dir%code\etl\13 *.sql) do (echo -- processing %%B > test3.txt)

set work_dir=
echo %USERNAME% %TIME% %DATE% >> test2.txt
