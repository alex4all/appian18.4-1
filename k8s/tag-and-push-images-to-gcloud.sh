#!/bin/bash

GCR_HOSTNAME=gcr.io
GCP_PROJECT_ID=$1

tag_for_gcloud () {
  echo Tagging $1
  docker tag $1 $GCR_HOSTNAME/$GCP_PROJECT_ID/$1
}

push_to_gcloud () {
  echo Pushing $1 to $GCR_HOSTNAME/$GCP_PROJECT_ID
  docker push $GCR_HOSTNAME/$GCP_PROJECT_ID/$1
}


tag_for_gcloud appian-search-server
tag_for_gcloud appian-data-server
tag_for_gcloud appian-service-manager
tag_for_gcloud appian-rdbms
tag_for_gcloud appian-web-application

push_to_gcloud appian-search-server
push_to_gcloud appian-data-server
push_to_gcloud appian-service-manager
push_to_gcloud appian-web-application
push_to_gcloud appian-rdbms
