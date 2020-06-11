#!/bin/bash
export PS1="\n\[\033[0m\]\w\$ "
until `which init-env`; do sleep 1; done;