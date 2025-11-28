#!/bin/bash

# Initialize Docker Swarm
docker swarm init

# Get the current Swarm Node ID
NODE_ID=$(docker info -f '{{.Swarm.NodeID}}')

# Add label for Traefik public certificates to the current node
docker node update --label-add traefik-public.traefik-public-certificates=true $NODE_ID

# Generate a hashed password and export it as an environment variable
echo "Please enter a password for Traefik"
export HASHED_PASSWORD=$(openssl passwd -apr1)

# Deploy the Traefik stack
docker stack deploy -c ./compose/traefik-host.yml traefik

# Add label for Portainer data to the current node
docker node update --label-add portainer.portainer-data=true $NODE_ID

# Deploy the Portainer stack
docker stack deploy -c ./compose/portainer.yml portainer

echo "Go to portainer.docker.localhost and setup your admin user immediately before continuing."
