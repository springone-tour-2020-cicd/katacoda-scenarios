#!/bin/bash

PATH=/root/init-env/bin:$PATH
until `which init-background`; do sleep 1; done;
