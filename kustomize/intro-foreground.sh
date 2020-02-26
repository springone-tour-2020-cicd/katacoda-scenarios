#!/bin/bash
# wait until background tasks complete
until `which init-env`; do sleep 1; done;

# needed to set JAVA_HOME here instead of in background
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# config command line prompt to show git branch status
source /usr/lib/git-core/git-sh-prompt
export GIT_PS1_SHOWDIRTYSTATE=yes
export PS1="\n\[\e[35m\]\$(__git_ps1) \[\e[33m\]\w\[\e[0m\]\n\$ "

# enable bash completion
source /etc/bash_completion

# clear screen
clear
