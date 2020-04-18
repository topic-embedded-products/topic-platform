#!/bin/sh -e
# Licensed under GPLv2
echo "Updating filesystem in UBI"
ubiattach -m 3 /dev/ubi_ctrl
if [ -e /dev/ubi0_1 ]
then
	echo "Removing existing A/B volumes and replacing with a single one"
	ubirmvol -n 1 /dev/ubi0
	ubirmvol -n 0 /dev/ubi0
	ubimkvol -N qspi-rootfs -m /dev/ubi0
fi
if [ ! -e /dev/ubi0_0 ]
then
	echo "Create new UBI volume qspi-rootfs"
	ubimkvol -N qspi-rootfs -m /dev/ubi0
fi
echo "Writing new image to UBI volume qspi-rootfs"
ubiupdatevol /dev/ubi0_0 /qspi-rootfs.ubifs
echo "DONE, sync filesystems"
sync
 echo "rebooting - be very patient, UBI needs time"
/sbin/reboot
