#!/bin/bash
until `which init-env`; do sleep 1; done;

source /usr/lib/git-core/git-sh-prompt
export GIT_PS1_SHOWDIRTYSTATE=yes
export PS1="\n\[\e[35m\]\$(__git_ps1) \[\e[33m\]\w\[\e[0m\]\n\$ "