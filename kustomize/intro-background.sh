#!/bin/bash
exec &>> environment-prepared-log
printf "" > /root/environment-prepared
echo "$(date)"

### CHANGES BELOW THIS LINE ### 

git clone https://github.com/springone-tour-2020-cicd/kustomize-labs.git
curl -LO https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv3.5.4/kustomize_v3.5.4_linux_amd64.tar.gz
sudo tar xvzf kustomize_v3.5.4_linux_amd64.tar.gz -C /usr/local/bin/ kustomize
minikube start

### NO CHANGES BELOW THIS LINE ###
# The following must be the last line
echo "done" >> /root/environment-prepared