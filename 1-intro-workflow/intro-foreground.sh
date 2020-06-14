#!/bin/bash -ex
{ set +x; } 2>/dev/null

until `which init-controller`; do sleep 1; done;
until `which init-foreground`; do sleep 1; done;

echo "Environment ready!"