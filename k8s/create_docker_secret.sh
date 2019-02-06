#!/bin/bash

if [ -z $1 ]; then
	echo "Expected namespace argument"
	exit 1
fi
gcloud auth print-access-token | xargs -I% kubectl -n $1 create secret docker-registry docker-registry --docker-server=gcr.io --docker-username=oauth2accesstoken --docker-password=% --docker-email=email
