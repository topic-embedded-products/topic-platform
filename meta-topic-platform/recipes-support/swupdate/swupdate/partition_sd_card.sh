#!/bin/sh -e
if [ -z "$1" ] || [ ! -b "$1" ]
then
	echo "Usage: $0 [device]"
	echo "no device found."
	exit 1
else
	DEV=$1
fi

DEVB=`basename ${DEV}`
PARTPREFIX=sd
# DEVP is the base name for partitions. On some block devices an
# additional "p" is needed.
if [ "${DEVB:0:6}" = "mmcblk" ]
then
	DEVD=`dirname ${DEV}`
	DEVP=${DEVD}/${DEVB}p
	# Detect if this is an eMMC device, they have extra "boot" devices
	if [ -e "${DEV}boot0" ]
	then
		PARTPREFIX=emmc
	fi
else
	DEVP=${DEV}
fi

# umount all and wipe 8K of all partitions and block device.
# Start with the partitions first because on newer
# Ubuntu systems the partition table will be reloaded when writing to a block device
# The partitions are wiped because the kernel otherwise tries to remount them after the
# new partition table is written to the device
DEVN="$(ls ${DEVP}[0-9] | sort -r) ${DEV}"
for n in ${DEVN}
do
	echo "Wiping ${n}"
	umount $n 2>/dev/null || true
	dd if=/dev/zero of=$n bs=8192 count=1 2>/dev/null
done

# Wait until kernel reloaded partition table
echo -n "Waiting for partition table to reload "
sync ${DEVN}
partprobe ${DEV}
while [ -e "${DEVP}1" ] || [ -e "${DEVP}2" ] || [ -e "${DEVP}3" ]
do
	echo -n "."
	sleep 0.1
done
echo ""

# Partition the disk, as 64M FAT16, 2xroot and the rest data
parted --align optimal --script ${DEV} -- \
	mklabel msdos \
	mkpart primary fat16 1MiB 64MiB \
	mkpart primary ext4 64MiB 40% \
	mkpart primary ext4 40% 80% \
	mkpart primary ext4 80% -1s \
	set 2 boot on

# Wait until kernel reloaded partition table
# The system is removing & adding the devices several times, therefore sleep for 1 second
sleep 1
echo -n "Waiting for partition table to reload "
while [ ! -e "${DEVP}1" ] || [ ! -e "${DEVP}2" ] || [ ! -e "${DEVP}3" ]
do
	echo -n "."
	sleep 0.1
done
echo ""

# format the DOS part
mkfs.vfat -n "boot" ${DEVP}1

# Format the Linux rootfs part
mkfs.ext4 -m 0 -L "${PARTPREFIX}-rootfs-a" -O sparse_super,dir_index ${DEVP}2
mkfs.ext4 -m 0 -L "${PARTPREFIX}-rootfs-b" -O sparse_super,dir_index ${DEVP}3

# Format the Linux data part, optimize for large files
mkfs.ext4 -m 0 -L "data" -O large_file,sparse_super,dir_index ${DEVP}4

