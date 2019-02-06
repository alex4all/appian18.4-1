#!/bin/bash

if [ -z "$1" ]
  then
    echo "Usage: ./setup_gcloud_k8s.sh <GCP project id>"
    exit 1
fi

PROJECT_ID=$1

gcloud config set project $PROJECT_ID
# set default region
gcloud config set compute/zone us-east1-b

# create a persistent disk.  This will be used to back the NFS mount
gcloud compute disks create --size=10GB --zone=us-east1-b appian-nfs-disk
echo ""

# reserve a static IP address.  The webapp will serve traffic on this address
gcloud compute addresses create appian-ha-static-ip --region=us-east1
STATIC_IP_ADDR=$(gcloud compute addresses list | grep appian-ha-static-ip | tr -s " " | cut -d " " -f 3)
echo "Reserved static IP address for Appian webapp: [$STATIC_IP_ADDR]"

# allow local pushes to GCP Docker registry
gcloud auth configure-docker --quiet

# push Appian Docker images to GCP Docker registry
./tag-and-push-images-to-gcloud.sh $PROJECT_ID

# create K8s cluster in GCP
gcloud container clusters create appiank8s --num-nodes=1 --machine-type=n1-standard-16
echo "Created 'appiank8s' Kubernetes cluster in GCP"

# install kubectl
if [[ "$OSTYPE" == "darwin"* ]]; then
  gcloud components install kubectl --quiet
else
  sudo apt-get install kubectl
  gcloud container clusters get-credentials appiank8s
fi
echo "Installed kubectl locally"

# create ae namespace in k8s
kubectl create namespace ae
echo "Created 'ae' namespace in Kubernetes"

# update templatized values in Kubernetes configuration
./update_k8s_configuration.sh $PROJECT_ID

# create Docker registry secret so that ae namespace can pull the images we've built
./create_docker_secret.sh ae

# initialize Appian
kubectl -n ae apply -f . -R
echo "Appian startup has been initiated"
echo "Run 'kubectl -n ae get pod -w' to monitor startup of Appian components"
echo "Appian will be serving traffic on $STATIC_IP_ADDR/suite"
