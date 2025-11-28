#!/bin/bash

# Exit the script if any command fails
set -e

# Pull Docker images
docker pull mariadb:10.6
docker pull ghcr.io/lmnaslimited/lensdocker/$(grep IMAGE variable.env | cut -d '=' -f2):$(grep VERSION variable.env | cut -d '=' -f2)
docker pull redis:6.2-alpine

# Export environment variables from variable.env and generate mariadb_sub.yml
set -a
source variable.env
set +a
# create a sub yml file for the mariadb.yml file
envsubst < ./compose/mariadb.yml > mariadb_sub.yml

#To get the portainer key from the varaiable.env
PORTAINER_API_KEY=$(grep 'PORTAINER_API_KEY=' variable.env | sed 's/^PORTAINER_API_KEY=//')

# Get Swarm ID (converted to curl)
SWARM_ID=$(curl -sk -H "X-API-Key: $PORTAINER_API_KEY" https://portainer.docker.localhost/api/endpoints/1/docker/swarm | grep -oP '"ID"\s*:\s*"\K[^"]+')

# Deploy mariadb stack (curl version)
curl -sk -X POST "https://portainer.docker.localhost/api/stacks" \
  -H "X-API-Key: $PORTAINER_API_KEY" \
  -F "type=1" \
  -F "method=file" \
  -F "file=@./mariadb_sub.yml" \
  -F "endpointId=1" \
  -F "SwarmID=$SWARM_ID" \
  -F "Name=$(grep MARIADB_NETWORK variable.env | cut -d '=' -f2)"

rm -f *_sub.yml

# Process and deploy bench stack to portainer 

sed -i 's/\$\$/__DOLLAR_SIGN__/g' ./compose/erpnext.yml
set -a
source variable.env
set +a
envsubst < ./compose/erpnext.yml > erpnext_sub.yml #create a sub yml file for the erpnext.yml file
sed -i 's/__DOLLAR_SIGN__/$$/g' ./compose/erpnext.yml erpnext_sub.yml

curl -sk -X POST "https://portainer.docker.localhost/api/stacks" \
  -H "X-API-Key: $PORTAINER_API_KEY" \
  -F "type=1" \
  -F "method=file" \
  -F "file=@./erpnext_sub.yml" \
  -F "endpointId=1" \
  -F "SwarmID=$SWARM_ID" \
  -F "Name=$(grep BENCH_NAME variable.env | cut -d '=' -f2)"

rm -f *_sub.yml

# Process and deploy configure-bench stack to portainer

sed -i 's/\$\$/__DOLLAR_SIGN__/g' ./compose/configure-erpnext.yml
set -a
source variable.env
set +a
envsubst < ./compose/configure-erpnext.yml > configure-erpnext_sub.yml #create a sub yml file for the config.yml file
sed -i 's/__DOLLAR_SIGN__/$$/g' ./compose/configure-erpnext.yml configure-erpnext_sub.yml

curl -sk -X POST "https://portainer.docker.localhost/api/stacks" \
  -H "X-API-Key: $PORTAINER_API_KEY" \
  -F "type=1" \
  -F "method=file" \
  -F "file=@./configure-erpnext_sub.yml" \
  -F "endpointId=1" \
  -F "SwarmID=$SWARM_ID" \
  -F "Name=$(grep BENCH_NAME variable.env | cut -d '=' -f2)-configure"

rm -f *_sub.yml

# Process and deploy create-site stack to portainer

sed -i 's/\$\$/__DOLLAR_SIGN__/g' ./compose/create-site.yml
set -a
source variable.env
set +a
envsubst < ./compose/create-site.yml > create-site_sub.yml #create a sub yml file for the create -site.yml file
sed -i 's/__DOLLAR_SIGN__/$$/g' ./compose/create-site.yml create-site_sub.yml

curl -sk -X POST "https://portainer.docker.localhost/api/stacks" \
  -H "X-API-Key: $PORTAINER_API_KEY" \
  -F "type=1" \
  -F "method=file" \
  -F "file=@./create-site_sub.yml" \
  -F "endpointId=1" \
  -F "SwarmID=$SWARM_ID" \
  -F "Name=$(grep BENCH_NAME variable.env | cut -d '=' -f2)-site"
  
# Cleanup: Delete all files that end with _sub.yml
rm -f *_sub.yml
