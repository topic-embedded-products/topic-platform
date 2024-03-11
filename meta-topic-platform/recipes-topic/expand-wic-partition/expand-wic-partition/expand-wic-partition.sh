#!/bin/sh -e
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

BLOCK_DEV=`busybox blkid /dev/mmcblk[0-9]p2 | sed -n "s@^\(/dev/mmcblk[0-9]\)p2.*LABEL=\"rootfs\".*@\1@p"`

if [ ! -z "$BLOCK_DEV" ]
then
	echo "Resizing existing WIC partition and creating new partitions"

	# Tell mdev not to attempt to mount anything yet
	DEV_BASE=`basename ${BLOCK_DEV}`
	touch /dev/nomount.${DEV_BASE}

	SIZE=`cat /sys/block/${DEV_BASE}/size`
	if [ "${SIZE}" -lt 10000000 ]
	then
		# Smaller than 5GB, use percentages
		SIZEA='40%'
		SIZEB='80%'
	else
		# Larger, use 2GB for rootfs partitions
		SIZEA='2056MiB'
		SIZEB='4GiB'
	fi
	parted --align optimal --script ${BLOCK_DEV} -- resizepart 2 "${SIZEA}"
	parted --align optimal --script ${BLOCK_DEV} -- mkpart primary ext4 "${SIZEA}" "${SIZEB}" mkpart primary ext4 "${SIZEB}" '-1s'

	# Wait until kernel reloaded partition table
	# The system is removing & adding the devices several times, therefore sleep for 2 seconds
	sleep 2
	echo -n "Waiting for partition table to reload "
	while [ ! -e "${BLOCK_DEV}p1" ] || [ ! -e "${BLOCK_DEV}p2" ] || [ ! -e "${BLOCK_DEV}p3" ] || [ ! -e "${BLOCK_DEV}p4" ]
	do
		echo -n "."
		sleep 1
	done
	echo ""

	dd if=/dev/zero of=${BLOCK_DEV}p3 bs=8k count=1
	mkfs.ext4 -m 0 -L "sd-rootfs-b" -O sparse_super,dir_index ${BLOCK_DEV}p3

	# Format the Linux data part, optimize for large files
	dd if=/dev/zero of=${BLOCK_DEV}p4 bs=8k count=1
	mkfs.ext4 -m 0 -L "data" -O large_file,sparse_super,dir_index ${BLOCK_DEV}p4

	rm /dev/nomount.${DEV_BASE}

	resize2fs ${BLOCK_DEV}p2
	tune2fs -L "sd-rootfs-a" ${BLOCK_DEV}p2
	echo "Done"
fi
