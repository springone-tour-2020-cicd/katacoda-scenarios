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

echo "### Configuring git global settings"
git config --global hub.protocol https
#git config --global credential.helper cache
#git config --global user.email "guest@example.com"
#git config --global user.name "Guest User"
echo "### Finished configuring git global settings"

########## NO CHANGES BELOW THIS LINE ##########
# The following must be the last line
echo "done" >> /root/environment-prepared
