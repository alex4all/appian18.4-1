@echo off

rem  Upgrade Guide:
rem  https://docs.appian.com/suite/help/18.1/Upgrade_Guide.html

IF [%1] == [] (
  echo ERROR: Proper usage is 'copy-engine-data ^<DATA_BACKUP_DIR^>'
  EXIT /B
)
IF %1 == data (
  echo ERROR: Proper usage is 'copy-engine-data ^<DATA_BACKUP_DIR^>'
  EXIT /B
)

rem Part of Step 5
rd /s /q data/kafka-logs
rd /s /q data/zookeeper

rem Step 6
rd /s /q "data\server\process\analytics\0000\gw1" 2>NUL
rd /s /q "data\server\process\analytics\0001\gw1" 2>NUL
rd /s /q "data\server\process\analytics\0002\gw1" 2>NUL

set OLD_DIR=%1
set NEW_DIR="data"

copy /y %OLD_DIR%\server\channels\gw1\channels*  %NEW_DIR%\server\channels\gw1
copy /y %OLD_DIR%\server\collaboration\gw1\dc*   %NEW_DIR%\server\collaboration\gw1
copy /y %OLD_DIR%\server\collaboration\gw1\stat* %NEW_DIR%\server\collaboration\gw1
copy /y %OLD_DIR%\server\forums\gw1\af*          %NEW_DIR%\server\forums\gw1
copy /y %OLD_DIR%\server\notifications\gw1\s*    %NEW_DIR%\server\notifications\gw1
copy /y %OLD_DIR%\server\notifications\gw1\n*    %NEW_DIR%\server\notifications\gw1
copy /y %OLD_DIR%\server\personalization\gw1\ag* %NEW_DIR%\server\personalization\gw1
copy /y %OLD_DIR%\server\portal\gw1\ap*          %NEW_DIR%\server\portal\gw1
copy /y %OLD_DIR%\server\process\design\gw1\pd*  %NEW_DIR%\server\process\design\gw1
copy /y %OLD_DIR%\server\process\exec\00\gw1\pe* %NEW_DIR%\server\process\exec\00\gw1
copy /y %OLD_DIR%\server\process\exec\01\gw1\pe* %NEW_DIR%\server\process\exec\01\gw1
copy /y %OLD_DIR%\server\process\exec\02\gw1\pe* %NEW_DIR%\server\process\exec\02\gw1


rem Step 7

rd /s /q  %NEW_DIR%\_admin\accdocs1\         2>NUL
rd /s /q  %NEW_DIR%\_admin\accdocs2\         2>NUL
rd /s /q  %NEW_DIR%\_admin\accdocs3\         2>NUL
rd /s /q  %NEW_DIR%\_admin\mini\             2>NUL
rd /s /q  %NEW_DIR%\_admin\models\           2>NUL
rd /s /q  %NEW_DIR%\_admin\plugins\          2>NUL
rd /s /q  %NEW_DIR%\_admin\process_notes\    2>NUL
rd /s /q  %NEW_DIR%\_admin\search\           2>NUL
rd /s /q  %NEW_DIR%\_admin\shared\           2>NUL
rd /s /q  %NEW_DIR%\server\archived-process\ 2>NUL
rd /s /q  %NEW_DIR%\server\msg\              2>NUL

xcopy /s /i /q /y %OLD_DIR%\_admin\accdocs1         %NEW_DIR%\_admin\accdocs1
xcopy /s /i /q /y %OLD_DIR%\_admin\accdocs2         %NEW_DIR%\_admin\accdocs2
xcopy /s /i /q /y %OLD_DIR%\_admin\accdocs3         %NEW_DIR%\_admin\accdocs3
xcopy /s /i /q /y %OLD_DIR%\_admin\mini             %NEW_DIR%\_admin\mini
xcopy /s /i /q /y %OLD_DIR%\_admin\models           %NEW_DIR%\_admin\models
xcopy /s /i /q /y %OLD_DIR%\_admin\plugins          %NEW_DIR%\_admin\plugins
xcopy /s /i /q /y %OLD_DIR%\_admin\process_notes    %NEW_DIR%\_admin\process_notes
xcopy /s /i /q /y %OLD_DIR%\_admin\search           %NEW_DIR%\_admin\search
xcopy /s /i /q /y %OLD_DIR%\_admin\shared           %NEW_DIR%\_admin\shared
xcopy /s /i /q /y %OLD_DIR%\server\archived-process %NEW_DIR%\server\archived-process
xcopy /s /i /q /y %OLD_DIR%\server\msg              %NEW_DIR%\server\msg

rem Step 10
xcopy /s /i /q /y %OLD_DIR%\mysql %NEW_DIR%\mysql

rem Step not found in original Update Guide
xcopy /s /i /q /y %OLD_DIR%\data-server %NEW_DIR%\data-server

rem Adding a file that will later be used to check for migration when starting containers
mkdir .\data\check-migration
type NUL > .\data\check-migration\run-migration.txt

echo.
echo Files copied from ^"%OLD_DIR%^" to %NEW_DIR%.
echo It is expected that some of the directories may be missing. Not all directories will be present in all Appian instances.
echo ^(If all of the directories are missing, check the name of the data backup directory that you entered.^)
echo.
echo If there are more than 3 Process-Execution engines, delete their analytics dirs and copy their kdbs manually.
echo See Step 6 of the Appian Update Guide for more information.
