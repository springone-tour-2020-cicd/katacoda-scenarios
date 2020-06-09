#!/bin/bash
export PS1="\n\[\033[0m\]\w\$ " JAVA_HOME=/usr/lib/jvm/default-java/jre MY_GITHUB_ORG=springone-tour-2020-cicd
until `which init-env`; do sleep 1; done;