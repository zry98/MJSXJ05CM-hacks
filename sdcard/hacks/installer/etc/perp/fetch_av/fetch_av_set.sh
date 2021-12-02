#!/bin/sh
#
ulimit -s 256
[ -f /mnt/data/etc/init.sh ] && /mnt/data/etc/init.sh &
