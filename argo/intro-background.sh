#!/bin/bash
exec &>> environment-prepared-log

printf "" > /root/environment-prepared
echo "$(date)"

echo "### Installing argocd CLI"
wget https://github.com/argoproj/argo-cd/releases/download/v1.4.2/argocd-linux-amd64
chmod +x argocd-linux-amd64
mv argocd-linux-amd64 /usr/local/bin/argocd
echo "### Finished installing argocd CLI"

echo "### Configuring git global settings"
git config --global credential.helper cache
git config --global user.email "guest@example.com"
git config --global user.name "Guest User"
echo "### Finished configuring git global settings"

########## NO CHANGES BELOW THIS LINE ##########
# The following must be the last line