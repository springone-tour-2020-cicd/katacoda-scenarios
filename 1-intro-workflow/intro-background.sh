#!/bin/bash
exec &>> environment-prepared-log

printf "" > /root/environment-prepared
echo "$(date)"

echo "### Installing hub CLI"
HUB_VERSION=2.14.2
curl -L https://github.com/github/hub/releases/download/v$HUB_VERSION/hub-linux-amd64-$HUB_VERSION.tgz | tar zx && \
     ./hub-linux-amd64-$HUB_VERSION/install && \
     rm -rf hub-linux-amd64-$HUB_VERSION
echo "### Finished installing hub CLI"

echo "### Installing pack CLI" 
PACK_VERSION=0.11.1
curl -L https://github.com/buildpacks/pack/releases/download/v$PACK_VERSION/pack-v$PACK_VERSION-linux.tgz | tar zx && \
    chmod +x pack && \
    mv pack /usr/local/bin/pack
echo "### Finished installing pack CLI"

echo "### Downloading builder"
pack set-default-builder gcr.io/paketo-buildpacks/builder:base
docker pull gcr.io/paketo-buildpacks/builder:base
echo "### Finished downloading builder"

echo "### Configuring git global settings"
git config --global hub.protocol https
#git config --global credential.helper cache
#git config --global user.email "guest@example.com"
#git config --global user.name "Guest User"
echo "### Finished configuring git global settings"

echo "### Create a workspace directory and cd into it"
mkdir workspace
cd workspace
echo "### Create setting up workspace directory"

########## NO CHANGES BELOW THIS LINE ##########
# The following must be the last line
echo "done" >> /root/environment-prepared
