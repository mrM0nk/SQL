@echo on
echo starting scripts > test2.txt
set work_dir=%~dp0
for %%B in (%work_dir%code\ddl\*table*.sql %work_dir%code\ddl\*constraint*.sql) do ((echo -- processing %%B >> test2.txt)&(sqlcmd -S . -i %%B >> test2.txt))
set work_dir=
echo %USERNAME% %TIME% %DATE% >> test2.txt
