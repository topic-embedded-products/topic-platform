#!/bin/sh -e
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
CMD=$1
if [ $# -ne 2 ]
then
	echo "Usage: $0 command device"
	exit 1
fi

DEV="$2"
DEVP="${DEV}"
BLOCK="/dev/${DEV}"

if [ "$CMD" = "preinst" ]
then
	bootpart=$(get-bootable-mbr-partition ${BLOCK})
	if [ -e "${BLOCK}p${bootpart}" ]
	then
		DEVP="${DEV}p"
	fi
	BLOCKP="/dev/${DEVP}"
	if [ "${bootpart}" == 3 ]
	then
		updatepart=2
		LBL=rootfs-a
	else
		updatepart=3
		LBL=rootfs-b
	fi
	if [ "$(echo ${DEV} | cut -b 1-6)" == "mmcblk" ]
	then
		if [ -e "${BLOCK}boot0" ]
		then
			LBL="emmc-${LBL}"
		else
			LBL="sd-${LBL}"
		fi
	fi
	echo "Updating: ${DEVP}${updatepart} ${LBL}, active: ${DEVP}${bootpart}"
	ln -s -f "${DEVP}${updatepart}" /dev/block-rootfs-inactive
	ln -s -f "${DEVP}${bootpart}" /dev/block-rootfs-active
	umount "${BLOCKP}${updatepart}" 2> /dev/null || true
	echo "${updatepart}" > /tmp/UPDATE-PART
	echo "${LBL}" > /tmp/UPDATE-LBL
elif [ "$CMD" = "postinst" ]
then
	updatepart=$(cat /tmp/UPDATE-PART)
	rmdir /tmp/UPDATE-MOUNT 2> /dev/null || true
	if mkdir /tmp/UPDATE-MOUNT && mount /dev/block-rootfs-inactive /tmp/UPDATE-MOUNT -o rw,noatime
	then
		swu-transfer-settings /tmp/UPDATE-MOUNT || true
		umount /tmp/UPDATE-MOUNT
		rmdir /tmp/UPDATE-MOUNT || true
	else
		echo "Cannot transfer settings"
	fi
	if tune2fs -L $(cat /tmp/UPDATE-LBL) /dev/block-rootfs-inactive
	then
		echo "Resizing root filesystem..."
		# If we can set the label, then we can resize it too
		resize2fs /dev/block-rootfs-inactive || echo "resize failed"
	else
		echo "Skip resize, unsupported filesystem"
	fi
	get-bootable-mbr-partition ${BLOCK} -s $(cat /tmp/UPDATE-PART)
	reboot
else
	echo "Invalid command"
	exit 1
fi
