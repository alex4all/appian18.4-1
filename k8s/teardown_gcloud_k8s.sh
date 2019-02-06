#!/bin/bash

teardown () {
  echo "Deleting Kubernetes cluster 'appiank8s'..."
  # delete k8s cluster
  gcloud container clusters delete appiank8s
  echo "Deleted Kubernetes cluster 'appiank8s'"

  # release static IP address
  echo "Releasing static IP address..."
  gcloud compute addresses delete appian-ha-static-ip --region=us-east1
  echo "Released static IP address"

  # delete persistent disk
  echo "Deleting persistent disk..."
  gcloud compute disks delete --zone=us-east1-b appian-nfs-disk
  echo "Deleted persistent disk"
}

read -p "Are you sure you want to teardown the cluster (y/n)? " yn
case ${yn:0:1} in
    y|Y )
        teardown
    ;;
    * )
        exit 0
    ;;
esac
