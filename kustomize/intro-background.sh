#!/bin/bash
exec &>> environment-prepared-log
printf "" > /root/environment-prepared
echo "$(date)"

### CHANGES BELOW THIS LINE ### 

git clone https://github.com/springone-tour-2020-cicd/kustomize-labs.git
minikube start

### NO CHANGES BELOW THIS LINE ###
# The following must be the last line
echo "done" >> /root/environment-prepared