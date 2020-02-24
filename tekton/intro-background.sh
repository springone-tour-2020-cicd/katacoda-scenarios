#!/bin/bash
exec &>> environment-prepared-log
printf "" > /root/environment-prepared
echo "$(date)"

### CHANGES BELOW THIS LINE ### 

git clone https://github.com/springone-tour-2020-cicd/tekton-labs.git
curl -LO https://github.com/tektoncd/cli/releases/download/v0.7.1/tkn_0.7.1_Linux_x86_64.tar.gz
sudo tar xvzf tkn_0.7.1_Linux_x86_64.tar.gz -C /usr/local/bin/ tkn
minikube start

### NO CHANGES BELOW THIS LINE ###
# The following must be the last line
echo "done" >> /root/environment-prepared