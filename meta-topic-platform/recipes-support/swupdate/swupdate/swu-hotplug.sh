#!/bin/sh
if [ $# -lt 1 ] || [ $# -gt 2 ] ||[ ! -e "$1" ]
then
	echo "Usage: $0 /dev/sda1 [/dev/xxx]"
	echo "Install SWU image from /dev/sda1 when /dev/xxx exists"
	exit 2
fi

# Check if condition file exists
if [ $# -eq 2 ] && [ ! -e "$2" ]
then
	echo "$2 not found, aborting"
	exit 1
fi

# Check for at least 5 seconds uptime
UPTIME=`cat /proc/uptime | cut -d '.' -f 1`
if [ $UPTIME -lt 10 ]
then
	echo "Uptime $UPTIME seconds, aborting"
	exit 1
fi

mkdir /run/mnt-$$
mount -o ro "$1" /run/mnt-$$ || exit $?
swupdate-client -v /run/mnt-$$/*.swu
umount /run/mnt-$$
rmdir /run/mnt-$$
