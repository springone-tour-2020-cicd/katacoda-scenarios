#!/bin/bash
exec &>> environment-prepared-log

printf "" > /root/environment-prepared
echo "$(date)"

echo "### Cloning sample Spring Boot app"
git clone https://github.com/springone-tour-2020-cicd/spring-sample-app.git
echo "### Finished cloning sample Spring Boot app"

########## NO CHANGES BELOW THIS LINE ##########
# The following must be the last line
echo "done" >> /root/environment-prepared