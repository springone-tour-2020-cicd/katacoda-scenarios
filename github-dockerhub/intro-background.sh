#!/bin/bash
exec &>> environment-prepared-log
printf "" > /root/environment-prepared
echo "$(date)"

### CHANGES BELOW THIS LINE ### 

# git
git config --global credential.helper cache
git config --global user.email "guest@example.com"
git config --global user.name "Guest User"

# shell prompt
source /usr/lib/git-core/git-sh-prompt
export GIT_PS1_SHOWDIRTYSTATE=yes
export PS1="\n\[\e[35m\]\$(__git_ps1) \[\e[33m\]\w\[\e[0m\]\n\$ "

### NO CHANGES BELOW THIS LINE ###
# The following must be the last line
echo "done" >> /root/environment-prepared