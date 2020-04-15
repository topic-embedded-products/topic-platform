#!/bin/sh -e
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

BLOCK_DEV=`busybox blkid /dev/mmcblk[0-9]p2 | sed -n "s@^\(/dev/mmcblk[0-9]\)p2.*LABEL=\"rootfs\".*@\1@p"`

if [ ! -z "$BLOCK_DEV" ]
then
	echo "Resizing existing WIC partition and creating new partitions"
	parted --align optimal --script ${BLOCK_DEV} -- \
		resizepart 2 25% \
		mkpart primary ext4 25% 50% \
		mkpart primary ext4 50% -1s

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

	mkfs.ext4 -m 0 -L "sd-rootfs-b" -O sparse_super,dir_index ${BLOCK_DEV}p3

	# Format the Linux data part, optimize for large files
	mkfs.ext4 -m 0 -L "data" -O large_file,sparse_super,dir_index ${BLOCK_DEV}p4

	resize2fs ${BLOCK_DEV}p2
	tune2fs -L "sd-rootfs-a" ${BLOCK_DEV}p2
	echo "Done"
fi
