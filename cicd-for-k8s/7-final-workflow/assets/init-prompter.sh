#!/bin/bash

# Get user input

echo ""
read -p "Enter your GitHub username: " GITHUB_USERNAME
read -s -p "Enter your GitHub auth token: " GITHUB_TOKEN
echo ""
read -p "Enter your GitHub org name [${GITHUB_USERNAME}]: " GITHUB_NS
GITHUB_NS=${GITHUB_NS:-$GITHUB_USERNAME}

echo ""
read -p "Enter your Docker Hub username: " DOCKERHUB_USERNAME
read -s -p "Enter your Docker Hub auth token: " DOCKERHUB_TOKEN
echo ""
read -p "Enter your Docker Hub org name [${DOCKERHUB_USERNAME}]: " IMG_NS
IMG_NS=${IMG_NS:-$DOCKERHUB_USERNAME}

# Replace placeholders with user input
#sed -i "s/DOCKERHUB_USERNAME_PLACEHOLDER/${DOCKERHUB_USERNAME}/g" ~/kpack-config/kpack-config.yaml
#sed -i "s/DOCKERHUB_TOKEN_PLACEHOLDER/${DOCKERHUB_TOKEN}/g" ~/kpack-config/kpack-config.yaml
#sed -i "s/IMG_NS_PLACEHOLDER/${IMG_NS}/g" ~/kpack-config/kpack-config.yaml
