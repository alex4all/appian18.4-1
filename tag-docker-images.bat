@echo off

IF [%1] == [] (
  echo ERROR: Proper usage is 'tag-docker-images.bat ^<OLD_APPIAN_VERSION_NUMBER^>'
  EXIT /B
)

set OLD_VERSION=%1
docker tag appian-base appian-base:%OLD_VERSION%
docker tag appian-web-application appian-web-application:%OLD_VERSION%
docker tag appian-search-server appian-search-server:%OLD_VERSION%
docker tag appian-data-server appian-data-server:%OLD_VERSION%
docker tag appian-service-manager appian-service-manager:%OLD_VERSION%
docker tag appian-rdbms appian-rdbms:%OLD_VERSION%
