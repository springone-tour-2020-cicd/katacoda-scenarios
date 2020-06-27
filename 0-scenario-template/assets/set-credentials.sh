#!/bin/bash

# Get user input

# Set GitHub credentialing for git and hub CLIs so that user is not prompted multiple times to log in
# Do not change the names of the GITHUB env vars
# hub CLI uses GITHUB_USERNAME and GITHUB_TOKEN env vara
# init-foreground and init-background are also using these to configure git CLI
# token
echo -n "Enter your GitHub auth token: " && read -s GITHUB_TOKEN || { stty -echo; read GITHUB_TOKEN; stty echo; }
export GITHUB_TOKEN
echo

# Set docker/Docker Hub credentialing in a simple way consistent with GitHub user experience above
echo
echo "You will use your Docker Hub account to push images"
echo "Please enter your Docker Hub username, org name, and auth token at the prompts"
echo 
# username
echo -n "Enter your Docker Hub username [${GITHUB_USERNAME}]: " && read DOCKERHUB_USERNAME
DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:-$GITHUB_USERNAME}"
export DOCKERHUB_USERNAME
# org
echo -n "Enter your Docker Hub org name [${DOCKERHUB_USERNAME}]: " && read IMG_NS
IMG_NS="${IMG_NS:-$DOCKERHUB_USERNAME}"
export IMG_NS
# token
echo "Please log in to docker CLI at the prompt"
echo "(docker prompts for password - we recommend using an auth token instead)"
echo "docker login -u ${DOCKERHUB_USERNAME}"
docker login -u "${DOCKERHUB_USERNAME}"
echo


