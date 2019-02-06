#!/bin/bash
echo Seeding initial kdb files into data directory
echo and creating logs folder.
echo This should take less than a minute.

id=$(docker create appian-base)
APPIAN_HOME=/usr/local/appian/ae

mkdir -p ./data
mkdir -p ./logs/tomcat
mkdir -p ./logs/data-server/data-metrics

mkdir -p ./data/verify-data-was-initialized
touch ./data/verify-data-was-initialized/successful.txt

docker cp $id:${APPIAN_HOME}/server ./data
docker cp $id:${APPIAN_HOME}/_admin ./data
docker cp $id:${APPIAN_HOME}/services/data/kafka-logs ./data
docker cp $id:${APPIAN_HOME}/services/data/data-server ./data

# The directories mounted into the docker containers must be owned by the appian
# user on Linux host machines. Otherwise, the containers will not have access
# to write to those directories at run time.
chown -R appian data/ logs/ conf/

docker rm -v $id >/dev/null
