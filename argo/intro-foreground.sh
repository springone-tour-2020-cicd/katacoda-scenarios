#!/bin/bash
export PS1="\[\033[0m\]\w\$ " JAVA_HOME=/usr/lib/jvm/default-java/jre
until `which init-env`; do sleep 1; done;