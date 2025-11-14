#!/bin/bash

# Exit the script if any command fails
set -e

# Pull Docker images
docker pull mariadb:10.6
docker pull ghcr.io/lmnaslimited/lensdocker/$(grep IMAGE variable.env | cut -d '=' -f2):$(grep VERSION variable.env | cut -d '=' -f2)
docker pull redis:6.2-alpine

# Export environment variables from variable.env and generate mariadb_sub.yml
export $(cat variable.env | xargs)
# create a sub yml file for the mariadb.yml file
envsubst < ./compose/mariadb.yml > mariadb_sub.yml

#To get the portainer key from the varaiable.env
PORTAINER_API_KEY=$(grep 'PORTAINER_API_KEY=' variable.env | sed 's/^PORTAINER_API_KEY=//')

# Deploy mariadb stack to Portainer

http --verify=no --form POST https://portainer.docker.localhost/api/stacks \
  X-API-Key:$PORTAINER_API_KEY \
  type=1 \
  method=file \
  file@./mariadb_sub.yml \
  endpointId=1 \
  SwarmID="$(http --verify=no GET https://portainer.docker.localhost/api/endpoints/1/docker/swarm \
    X-API-Key:$PORTAINER_API_KEY | grep -oP '"ID"\s*:\s*"\K[^"]+')" \
  Name="$(grep MARIADB_NETWORK variable.env | cut -d '=' -f2)"

rm -f *_sub.yml

# Process and deploy bench stack to portainer 

sed -i 's/\$\$/__DOLLAR_SIGN__/g' ./compose/erpnext.yml
export $(cat variable.env | xargs)
envsubst < ./compose/erpnext.yml > erpnext_sub.yml #create a sub yml file for the erpnext.yml file
sed -i 's/__DOLLAR_SIGN__/$$/g' ./compose/erpnext.yml erpnext_sub.yml

http --verify=no --form POST https://portainer.docker.localhost/api/stacks \
  X-API-Key:$PORTAINER_API_KEY \
  type=1 \
  method=file \
  file@./erpnext_sub.yml \
  endpointId=1 \
  SwarmID="$(http --verify=no GET https://portainer.docker.localhost/api/endpoints/1/docker/swarm \
    X-API-Key:$PORTAINER_API_KEY | grep -oP '"ID"\s*:\s*"\K[^"]+')" \
  Name="$(grep BENCH_NAME variable.env | cut -d '=' -f2)"

rm -f *_sub.yml

# Process and deploy configure-bench stack to portainer

sed -i 's/\$\$/__DOLLAR_SIGN__/g' ./compose/configure-erpnext.yml
export $(cat variable.env | xargs)
envsubst < ./compose/configure-erpnext.yml > configure-erpnext_sub.yml #create a sub yml file for the config.yml file
sed -i 's/__DOLLAR_SIGN__/$$/g' ./compose/configure-erpnext.yml configure-erpnext_sub.yml

http --verify=no --form POST https://portainer.docker.localhost/api/stacks \
  X-API-Key:$PORTAINER_API_KEY \
  type=1 \
  method=file \
  file@./configure-erpnext_sub.yml \
  endpointId=1 \
  SwarmID="$(http --verify=no GET https://portainer.docker.localhost/api/endpoints/1/docker/swarm \
    X-API-Key:$PORTAINER_API_KEY  | grep -oP '"ID"\s*:\s*"\K[^"]+')" \
  Name="$(grep BENCH_NAME variable.env | cut -d '=' -f2)-configure"

rm -f *_sub.yml

# Process and deploy create-site stack to portainer

sed -i 's/\$\$/__DOLLAR_SIGN__/g' ./compose/create-site.yml
export $(cat variable.env | xargs)
envsubst < ./compose/create-site.yml > create-site_sub.yml #create a sub yml file for the create -site.yml file
sed -i 's/__DOLLAR_SIGN__/$$/g' ./compose/create-site.yml create-site_sub.yml

http --verify=no --form POST https://portainer.docker.localhost/api/stacks \
  X-API-Key:$PORTAINER_API_KEY \
  type=1 \
  method=file \
  file@./create-site_sub.yml \
  endpointId=1 \
  SwarmID="$(http --verify=no GET https://portainer.docker.localhost/api/endpoints/1/docker/swarm \
    X-API-Key:$PORTAINER_API_KEY  | grep -oP '"ID"\s*:\s*"\K[^"]+')" \
  Name="$(grep BENCH_NAME variable.env | cut -d '=' -f2)-site"
  
# Cleanup: Delete all files that end with _sub.yml
rm -f *_sub.yml
