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
	create_mmc_links
	prepare_filesystem /dev/sd-rootfs-inactive /tmp/UPDATE-MOUNT
elif [ "$CMD" = "postinst" ]
then
	swu-transfer-settings /tmp/UPDATE-MOUNT || true
	switch_mmc_boot_partition /dev/sd-rootfs-inactive
	sync
	reboot
else
	echo "Invalid command"
	exit 1
fi
