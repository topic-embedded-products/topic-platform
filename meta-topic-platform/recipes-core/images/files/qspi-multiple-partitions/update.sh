#!/bin/sh -e
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
CMD=$1
if [ $# -ne 1 ]
then
	echo "Usage: $0 command"
	exit 1
fi

if [ "$CMD" = "preinst" ]
then
	ubiattach -m 1 /dev/ubi_ctrl
elif [ "$CMD" = "postinst" ]
then
	reboot
else
	echo "Invalid command"
	exit 1
fi
