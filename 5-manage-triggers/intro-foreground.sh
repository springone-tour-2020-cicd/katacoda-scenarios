#!/bin/bash +x
PATH=/root/init-env/bin:$PATH; until `which init-controller`; do sleep 1; done; source init-foreground; echo "Environment ready!"
