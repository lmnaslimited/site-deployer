#!/bin/bash

# Define script paths
SETUP_SCRIPT="./setup.sh"
DEPLOY_SCRIPT="./deploy.sh"
BACKUP_SCRIPT="./restore_backup.sh"

# Check if both scripts exist
if [ ! -f "$SETUP_SCRIPT" ]; then
  echo "❌ Error: setup.sh not found in the current directory."
  exit 1
fi

if [ ! -f "$DEPLOY_SCRIPT" ]; then
  echo "❌ Error: deploy.sh not found in the current directory."
  exit 1
fi

echo "Does Portainer exist in your system?"
read -rp "Enter your choice (y/n): " choice

# Normalize input (to lowercase)
choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

# Run Portainer Spin up Script
if [ "$choice" = "n" ]; then
  echo "🛠 Running Portainer setup..."
  bash "$SETUP_SCRIPT"
  echo "Does Admin User setup finished in portainer.docker.localhost?"
  read -rp "Please enter (y) after finishing " setted
  setted=$(echo "$setted" | tr '[:upper:]' '[:lower:]')

  # Run the Site Creation script only when we give the Portainer access token
  if [ "$setted" = "y" ]; then
    echo "Do you have the Portainer Access Token. If not follow the steps in README file:"
    read -rp "Did you update the Portainer Token in the variable.env file? (y): " present
    present=$(echo "$present" | tr '[:upper:]' '[:lower:]')
    if [ "$present" = "y" ]; then
      echo "🚀 Running Site deployment..."
      bash "$DEPLOY_SCRIPT"
    else
      echo "❌ Invalid option. Choose y after completed what is asked."
      exit 1
    fi
  else
    echo "❌ Invalid option. Choose y after completed what is asked."
    exit 1
  fi

# When Portainer Already present, spin up the site creation automatically
elif [ "$choice" = "y" ]; then
  echo "Do you have the Portainer Access Token. If not follow the step in README file:"
  read -rp "Did you update the Portainer Token in the variable.env file? (y): " present
  present=$(echo "$present" | tr '[:upper:]' '[:lower:]')
  if [ "$present" = "y" ]; then
    echo "🚀 Running Site deployment..."
    bash "$DEPLOY_SCRIPT"
  else
    echo "❌ Invalid option. Choose y after completed what is asked."
    exit 1
  fi

else
  echo "❌ Invalid option. Choose y or n."
  exit 1
fi

# Backup Restoration part
echo "Confirm whether site stack is completed in the portainer. If not wait for few minutes to proceed with backup ....."
echo "Do you want to restore your site?"
read -rp "Enter your choice (y/n): " confirm

confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]')

if [ "$confirm" = "y" ]; then
  echo "🛠 Running backup restore..."
  bash "$BACKUP_SCRIPT"
else
  echo "Invalid process"
  exit 1
fi
