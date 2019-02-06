#!/bin/bash

sedfunction () {
  pattern=$1
  file=$2
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo $pattern
    sed -i "" $pattern $file
  else
    sed -i $pattern $file
  fi
}

if [[ -z "$1" ]]
  then
    echo "Usage: ./update_k8s_configuration.sh <GCP project id>"
    exit 1
fi

if [[ ! -f ../k3.lic ]]; then
  echo "k3.lic not found, must be present in base directory"
  exit 1
fi

if [[ ! -f ../k4.lic ]]; then
  echo "k4.lic not found, must be present in base directory"
  exit 1
fi

PROJECT_ID="$1"
DOCKER_REGISTRY_URL="gcr.io\/$PROJECT_ID"
STATIC_IP_ADDR=$(gcloud compute addresses list | grep appian-ha-static-ip | tr -s " " | cut -d " " -f 3)

# update static IP address in custom.properties
sedfunction "s/{{STATIC_IP_ADDRESS}}/$STATIC_IP_ADDR/g" webapp/custom-properties.yaml

# update static IP address for the load balancer
sedfunction "s/{{STATIC_IP_ADDRESS}}/$STATIC_IP_ADDR/g" webapp/service.yaml

# update k3 license
ESCAPED_K3_LIC=$(echo $(base64 ../k3.lic) | sed 's/[=+/]/\\&/g')
sedfunction "s/{{K3_LIC}}/$ESCAPED_K3_LIC/g" service_manager/k3lic.yaml

# update k4 license
ESCAPED_K4_LIC=$(echo $(base64 ../k4.lic) | sed 's/[=+/]/\\&/g')
sedfunction "s/{{K4_LIC}}/$ESCAPED_K4_LIC/g" data_server/k4lic.yaml

# update Docker registry URL
sedfunction "s/{{DOCKER_REGISTRY}}/$DOCKER_REGISTRY_URL/g" webapp/statefulset.yaml
sedfunction "s/{{DOCKER_REGISTRY}}/$DOCKER_REGISTRY_URL/g" service_manager/statefulset.yaml
sedfunction "s/{{DOCKER_REGISTRY}}/$DOCKER_REGISTRY_URL/g" data_server/deployment.yaml
sedfunction "s/{{DOCKER_REGISTRY}}/$DOCKER_REGISTRY_URL/g" search_server/statefulset.yaml
sedfunction "s/{{DOCKER_REGISTRY}}/$DOCKER_REGISTRY_URL/g" mysql/deployment.yaml
