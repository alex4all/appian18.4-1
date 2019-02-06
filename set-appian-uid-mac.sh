#!/bin/bash

echo "Setting the value of 'APPIAN_USER_ID' in docker-compose.yml to 9999"

sed -i '' "s/# args: #.*/args:/" docker-compose.yml
sed -i '' "s/# - APPIAN_USER_ID=<.*/- APPIAN_USER_ID=9999/" docker-compose.yml
