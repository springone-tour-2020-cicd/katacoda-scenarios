#!/bin/bash +x

PATH=/root/init-env/bin:$PATH
until `which init-controller`; do sleep 1; done;
until `which init-foreground`; do sleep 1; done;

echo "Environment ready!"