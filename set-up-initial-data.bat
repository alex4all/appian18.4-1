@echo off
echo Seeding initial kdb files into data directory
echo and creating logs folder.
echo This should take less than a minute.

for /f %%w in ('docker create appian-base') do set id=%%w
set APPIAN_HOME=\usr\local\appian\ae

mkdir .\data
mkdir .\logs\tomcat

mkdir .\data\verify-data-was-initialized
type NUL > .\data\verify-data-was-initialized\successful.txt

docker cp %id%:%APPIAN_HOME%\server .\data
docker cp %id%:%APPIAN_HOME%\_admin .\data
docker cp %id%:%APPIAN_HOME%\services\data\kafka-logs .\data
docker cp %id%:%APPIAN_HOME%\services\data\data-server .\data

docker rm -v %id% >NUL
