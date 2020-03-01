#!/bin/bash
exec &>> environment-prepared-log

printf "" > /root/environment-prepared
echo "$(date)"

echo "### Installing kpack logs CLI"
curl -L https://github.com/pivotal/kpack/releases/download/v0.0.6/logs-v0.0.6-linux.tgz | tar zx && \
    chmod +x logs && \
    mv logs /usr/local/bin/logs
echo "### Finished installing kpack logs CLI"

echo "### Configuring git global settings"
git config --global credential.helper cache
git config --global user.email "guest@example.com"
git config --global user.name "Guest User"
echo "### Finished configuring git global settings"

########## NO CHANGES BELOW THIS LINE ##########
# The following must be the last line
echo "done" >> /root/environment-prepared