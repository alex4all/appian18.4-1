#!/bin/bash

# Update Guide:
# https://docs.appian.com/suite/help/18.1/Upgrade_Guide.html
# All steps are in reference to this Update Guide

if [[ -z $1 || $1 == "data" ]]; then
  echo "ERROR: Proper usage is './copy-appian-data.sh <DATA_BACKUP_DIR>'"
  exit 1
fi

# Part of Step 5
rm -rf data/kafka-logs
rm -rf data/zookeeper

# Step 6
rm -rf data/server/process/analytics/0000/gw1
rm -rf data/server/process/analytics/0001/gw1
rm -rf data/server/process/analytics/0002/gw1

OLD_DIR=$1
NEW_DIR=data

getHighestKdb() {
  KDB_LIST=$(ls $OLD_DIR/server/$2/gw1 | grep $1.*.kdb)
  NUM_LIST=$(echo $KDB_LIST | grep -o -E '[0-9]+')
  IFS=$'\n'
  HIGHEST_NUM=$(echo "${NUM_LIST[*]}" | sort -nr | head -n1)
  HIGHEST_KDB=$1$HIGHEST_NUM.kdb
  IFS=$' '
}

copyDataToNewDir () {
  getHighestKdb $1 $2
  cp -v $OLD_DIR/server/$2/gw1/$HIGHEST_KDB $NEW_DIR/server/$2/gw1
}

copyDataToNewDir channels channels
copyDataToNewDir dc collaboration
copyDataToNewDir stat collaboration
copyDataToNewDir af forums
copyDataToNewDir s notifications
copyDataToNewDir n notifications
copyDataToNewDir ag personalization
copyDataToNewDir ap portal
copyDataToNewDir pd process/design
copyDataToNewDir pe process/exec/00
copyDataToNewDir pe process/exec/01
copyDataToNewDir pe process/exec/02


# Step 7
rm -rf $NEW_DIR/_admin/accdocs*/
rm -rf $NEW_DIR/_admin/mini/
rm -rf $NEW_DIR/_admin/models/
rm -rf $NEW_DIR/_admin/plugins/
rm -rf $NEW_DIR/_admin/process_notes/
rm -rf $NEW_DIR/_admin/search/
rm -rf $NEW_DIR/_admin/shared/
rm -rf $NEW_DIR/server/archived-process/
rm -rf $NEW_DIR/server/msg/

cp -R $OLD_DIR/_admin/accdocs*         $NEW_DIR/_admin/
cp -R $OLD_DIR/_admin/mini             $NEW_DIR/_admin/
cp -R $OLD_DIR/_admin/models           $NEW_DIR/_admin/
cp -R $OLD_DIR/_admin/plugins          $NEW_DIR/_admin/
cp -R $OLD_DIR/_admin/process_notes    $NEW_DIR/_admin/
cp -R $OLD_DIR/_admin/search           $NEW_DIR/_admin/
cp -R $OLD_DIR/_admin/shared           $NEW_DIR/_admin/
cp -R $OLD_DIR/server/archived-process $NEW_DIR/server/
cp -R $OLD_DIR/server/msg              $NEW_DIR/server/

# Step 10
cp -R $OLD_DIR/mysql $NEW_DIR

# Step not found in original Update Guide
cp -R $OLD_DIR/data-server $NEW_DIR

# Adding a file that will later be used to check for migration when starting containers
mkdir -p ./data/check-migration/
touch ./data/check-migration/run-migration.txt

echo ""
echo "Files copied from \"$OLD_DIR\" to \"$NEW_DIR.\""
echo "It is expected that some of the directories may be missing. Not all directories will be present in all Appian instances."
echo "(If all of the directories are missing, check the name of the data backup directory that you entered.)"
echo ""
echo "If there are more than 3 Process-Execution engines, delete their analytics dirs and copy their kdbs manually."
echo "See Step 6 of the Appian Update Guide for more information."
