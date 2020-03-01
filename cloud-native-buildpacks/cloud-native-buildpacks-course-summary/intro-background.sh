#!/bin/bash
exec &>> environment-prepared-log

printf "" > /root/environment-prepared
echo "$(date)"

########## NO CHANGES BELOW THIS LINE ##########
# The following must be the last line
echo "done" >> /root/environment-prepared