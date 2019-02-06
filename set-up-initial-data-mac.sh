#!/bin/bash
echo Seeding initial kdb files into data directory
echo and creating logs folder.
echo This should take less than a minute.

id=$(docker create appian-base)
APPIAN_HOME=/usr/local/appian/ae

mkdir -p ./data
mkdir -p ./logs/tomcat

mkdir -p ./data/verify-data-was-initialized
touch ./data/verify-data-was-initialized/successful.txt

docker cp $id:${APPIAN_HOME}/server ./data
docker cp $id:${APPIAN_HOME}/_admin ./data
docker cp $id:${APPIAN_HOME}/services/data/kafka-logs ./data
docker cp $id:${APPIAN_HOME}/services/data/data-server ./data

docker rm -v $id >/dev/null
