#!/bin/sh
# Licensed under GPLv2
# Load kernel modules for hotpluggable devices

# Probe all modules so that drivers load automatically
find /sys/devices/ -name modalias -print0 | xargs -0 grep -h ':' | while read m
do
	modprobe $m > /dev/null 2> /dev/null
done

exit 0
