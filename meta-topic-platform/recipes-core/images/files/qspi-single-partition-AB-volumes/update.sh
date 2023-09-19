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
	ubiattach -m 1 /dev/ubi_ctrl || true
elif [ "$CMD" = "postinst" ]
then
	if [ -s /etc/swu-transfer-list ]
	then
		rmdir /tmp/UPDATE-MOUNT 2> /dev/null || true
		if mkdir /tmp/UPDATE-MOUNT && mount -t ubifs ubi0:qspi-rootfs /tmp/UPDATE-MOUNT
		then
			swu-transfer-settings /tmp/UPDATE-MOUNT || true
			umount /tmp/UPDATE-MOUNT
			rmdir /tmp/UPDATE-MOUNT || true
		else
			echo "Cannot transfer settings"
		fi
	fi
	reboot
else
	echo "Invalid command"
	exit 1
fi
