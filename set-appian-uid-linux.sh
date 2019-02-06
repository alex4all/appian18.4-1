#!/bin/bash

APPIAN_UID=$(id -u appian)

if [[ -z $APPIAN_UID ]]; then
  echo "ERROR: No 'appian' user found in /etc/passwd. Did you create the 'appian' user on this machine?"
  exit 1
fi

echo "'appian' user found with uid: $APPIAN_UID"
echo "Setting the value of 'APPIAN_USER_ID' in docker-compose.yml to $APPIAN_UID"

sed -i "s/# args: #.*/args:/" docker-compose.yml
sed -i "s/# - APPIAN_USER_ID=<.*/- APPIAN_USER_ID=$APPIAN_UID/" docker-compose.yml
