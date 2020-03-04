#!/bin/bash
exec &>> environment-prepared-log

printf "" > /root/environment-prepared
echo "$(date)"

echo "### Installing pack CLI" 
curl -L https://github.com/buildpacks/pack/releases/download/v0.9.0/pack-v0.9.0-linux.tgz | tar zx && \
    chmod +x pack && \
    mv pack /usr/local/bin/pack
echo "### Finished installing pack CLI"

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

########## NO CHANGES BELOW THIS LINE ##########
# The following must be the last line
echo "done" >> /root/environment-prepared