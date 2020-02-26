#!/bin/bash

# Get user input
echo ""
read -p "Enter your Docker Hub username: " MY_DOCKERHUB_USERNAME
read -s -p "Enter your Docker Hub password or auth token: " MY_DOCKERHUB_PASSWORD
echo ""
read -p "Enter your Docker Hub org name [${MY_DOCKERHUB_USERNAME}]: " MY_DOCKERHUB_ORG
MY_DOCKERHUB_ORG=${MY_DOCKERHUB_ORG:-$MY_DOCKERHUB_USERNAME}

# Replace placeholders with user input
sed -i "s/DOCKERHUB_USERNAME_PLACEHOLDER/${MY_DOCKERHUB_USERNAME}/g" ~/kpack-config/kpack-config.yaml
sed -i "s/DOCKERHUB_PASSWORD_PLACEHOLDER/${MY_DOCKERHUB_PASSWORD}/g" ~/kpack-config/kpack-config.yaml
sed -i "s/DOCKERHUB_ORG_PLACEHOLDER/${MY_DOCKERHUB_ORG}/g" ~/kpack-config/kpack-config.yaml
