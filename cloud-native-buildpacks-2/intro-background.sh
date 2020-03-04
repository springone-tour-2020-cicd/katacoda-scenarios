#!/bin/bash
exec &>> environment-prepared-log

printf "" > /root/environment-prepared
echo "$(date)"

echo "### Installing pack CLI" 
curl -L https://github.com/buildpacks/pack/releases/download/v0.9.0/pack-v0.9.0-linux.tgz | tar zx && \
    chmod +x pack && \
    mv pack /usr/local/bin/pack
echo "### Finished installing pack CLI"

echo "### Installing kpack logs CLI"
curl -L https://github.com/pivotal/kpack/releases/download/v0.0.6/logs-v0.0.6-linux.tgz | tar zx && \
    chmod +x logs && \
    mv logs /usr/local/bin/logs
echo "### Finished installing kpack logs CLI"

echo "### Cloning sample Spring Boot app"
git clone https://github.com/springone-tour-2020-cicd/spring-sample-app.git
echo "### Finished cloning sample Spring Boot app"

echo "### Cloning buildpacks samples"
git clone https://github.com/buildpacks/samples.git
echo "### Finished cloning buildpacks samples"

echo "### Configuring hello-world sample buildpack"
echo "" >> samples/buildpacks/hello-world/buildpack.toml
echo "[[stacks]]" >> samples/buildpacks/hello-world/buildpack.toml
echo "id = \"io.buildpacks.stacks.bionic\"" >> samples/buildpacks/hello-world/buildpack.toml
echo "### Finished configuring hello-world sample buildpack"

echo "### Configuring git global settings"
git config --global credential.helper cache
git config --global user.email "guest@example.com"
git config --global user.name "Guest User"
echo "### Finished configuring git global settings"

########## NO CHANGES BELOW THIS LINE ##########
# The following must be the last line
echo "done" >> /root/environment-prepared