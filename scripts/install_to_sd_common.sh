#!/bin/bash -e
# parse commandline
DO_UNMOUNT=true
DO_ROOTFS=true
while [ ! -z "$1" ]
do
	if [ "$1" == "-n" ]
	then
		DO_UNMOUNT=false
	elif [ "$1" == "-b" ]
	then
		DO_ROOTFS=false
	elif [ "$1" == "-d" ]
	then
		shift
		BLOCK_DEV="$1"
	else
		echo "Usage: $0 [-n] [-b] [-d device]"
		echo "-b  Write boot partition only, don't write the rootfs"
		echo "-n  Do not unmount media after writing"
		echo "-d  Device to upgrade, e.g. /dev/sdb"
		exit 1
	fi
	shift
done

if [ -z "${MACHINE}" ]
then
	echo "MACHINE environment is not set. Set it before calling this"
	echo "script. Note that 'sudo' will not pass your environment"
	echo "along."
	exit 1
fi

if [ -z "${IMAGE_ROOT}" ]
then
	IMAGE_ROOT=tmp-glibc/deploy/images/${MACHINE}
fi

# Ubuntu <14 uses /media for mounts, Ubuntu 14 uses /media/$USER
if [ -z "${SUDO_USER}" ]
then
	SUDO_USER="${USER}"
fi

if [ -d /media/${SUDO_USER} ]
then
	MEDIA=/media/${SUDO_USER}
else
    # Fedora/Arch/other systemd distro's use /var/run/media for mounts.
    if [ -d /var/run/media/${SUDO_USER} ]
    then
        MEDIA=/var/run/media/${SUDO_USER}
    else
        MEDIA=/media
    fi
fi

if $DO_ROOTFS
then
	if [ -z "$BLOCK_DEV" ]
	then
		BLOCK_DEV=$(sed -n "s@^\(/dev/sd\w\+\|/dev/mmcblk[0-9]\+\)p*[0-9] ${MEDIA}/sd-rootfs-[a-b] .*\$@\1@p" /proc/mounts | uniq -d)
	fi
	if [ -z "$BLOCK_DEV" ]
	then
		echo "${MEDIA}/sd-rootfs-* not found, and no target specified."
		echo "Insert media or specify target device using -d"
		exit 1
	fi

	BOOTABLE_PART=$(fdisk -l ${BLOCK_DEV} | sed -n 's@^/dev/\(sd[a-z]\|mmcblk[0-9]\+p\)\([0-9]\)\s\+\*\(.*\)$@\2@p')
	if [ "${BOOTABLE_PART}" = "2" ]
	then
		ROOTLABEL=sd-rootfs-a
	elif [ "${BOOTABLE_PART}" = "3" ]
	then
		ROOTLABEL=sd-rootfs-b
	else
		echo "Setting sd-rootfs-a as bootable partition"
		parted ${BLOCK_DEV} set 2 boot on
		ROOTLABEL=sd-rootfs-a
		BOOTABLE_PART=2
	fi
	ROOTFS=${MEDIA}/${ROOTLABEL}
	BLOCK_DEV_ROOT="${BLOCK_DEV}${BOOTABLE_PART}"

	if [ -z "${IMAGE}" ]
	then
		echo "IMAGE environment is not set. Set it before calling this"
		echo "script. Note that 'sudo' will not pass your environment"
		echo "along."
		exit 1
	fi

	if [ ! -w ${BLOCK_DEV_ROOT} ]
	then
		echo "${BLOCK_DEV_ROOT} is not accesible. Are you root (sudo me),"
		echo "is the SD card inserted, and did you partition and"
		echo "format it with partition_sd_card.sh?"
		exit 1
	fi

	# Can either set ROOTFSTYPE or ROOTFSTYPES
	if [ -n "${ROOTFSTYPE}" ]
	then
		ROOTFSTYPES="${ROOTFSTYPE}"
	fi
	if [ -z "${ROOTFSTYPES}" ]
	then
		ROOTFSTYPES="ext4.gz tar.gz"
	fi

	for rfstype in ${ROOTFSTYPES}
	do
		# Support having ".rootfs" in the filename
		for IMAGE_NAME_SUFFIX in '.rootfs' ''
		do
			if [ -f ${IMAGE_ROOT}/${IMAGE}-${MACHINE}${IMAGE_NAME_SUFFIX}.${rfstype} ]
			then
				ROOTFSTYPE=${rfstype}
				break 2
			fi
		done
	done

	echo "root: ${IMAGE_ROOT}/${IMAGE}-${MACHINE}${IMAGE_NAME_SUFFIX}.${ROOTFSTYPE}"
	if [ ! -f ${IMAGE_ROOT}/${IMAGE}-${MACHINE}${IMAGE_NAME_SUFFIX}.${ROOTFSTYPE} ]
	then
		echo "Image '${IMAGE}' does not exist, cannot flash it."
		echo ${IMAGE_ROOT}/${IMAGE}-${MACHINE}.${ROOTFSTYPE}
		exit 1
	fi
fi

if [ ! -w ${MEDIA}/boot ]
then
    # Some distros mount vfat systems with CASE characters.
    if [ ! -w ${MEDIA}/BOOT ]
    then
        echo "${MEDIA}/boot is not accesible. Are you root (sudo me),"
        echo "is the SD card inserted, and did you partition and"
        echo "format it with partition_sd_card.sh?"
        exit 1
    else
        MEDIA_BOOT=${MEDIA}/BOOT
    fi
else
    MEDIA_BOOT=${MEDIA}/boot
fi

set -e
if [ -d ${MEDIA}/data ]
then
	MEDIA_DATA=${MEDIA}/data
else
	MEDIA_DATA=${MEDIA_BOOT}
fi

echo "Writing boot..."
rm -f ${MEDIA_BOOT}/*.ubi ${MEDIA_BOOT}/*.squashfs-lzo

if [ -e ${IMAGE_ROOT}/BOOT.bin ]
then
	BOOT_BIN=BOOT.bin
else
	BOOT_BIN=boot.bin
fi

if [ -e ${IMAGE_ROOT}/${BOOT_BIN} ]
then
	cp ${IMAGE_ROOT}/${BOOT_BIN} ${MEDIA_BOOT}/BOOT.BIN
	for fn in u-boot.img u-boot.itb
	do
		if [ -e ${IMAGE_ROOT}/${fn} ]
		then
			cp ${IMAGE_ROOT}/${fn} ${MEDIA_BOOT}
		fi
	done
else
	echo "${IMAGE_ROOT}/${BOOT_BIN} not found, attempt to use boot.tar.gz"
	tar xaf ${IMAGE_ROOT}/boot.tar.gz --no-same-owner -C ${MEDIA_BOOT}
fi

if $DO_ROOTFS
then
	RESIZE_ROOTFS=true
	REMOUNT=true
	FIXUP_ROOTFS=false
	echo "Writing ${ROOTFS}..."
	if [ -f dropbear_rsa_host_key ]
	then
		FIXUP_ROOTFS=true
	else
		if [  -f ${ROOTFS}/etc/dropbear/dropbear_rsa_host_key ]
		then
			cp ${ROOTFS}/etc/dropbear/dropbear_rsa_host_key .
			chmod 666 dropbear_rsa_host_key
			FIXUP_ROOTFS=true
		fi
	fi
	case ${ROOTFSTYPE} in
		tar*)
			rm -rf ${ROOTFS}/*
			tar xaf ${IMAGE_ROOT}/${IMAGE}-${MACHINE}${IMAGE_NAME_SUFFIX}.${ROOTFSTYPE} -C ${ROOTFS}
			REMOUNT=false
			RESIZE_ROOTFS=false
			;;
		*.gz)
			umount ${ROOTFS} 2> /dev/null || umount ${BLOCK_DEV_ROOT}
			zcat ${IMAGE_ROOT}/${IMAGE}-${MACHINE}${IMAGE_NAME_SUFFIX}.${ROOTFSTYPE} | dd of=${BLOCK_DEV_ROOT} bs=1M
			;;
		*.xz)
			umount ${ROOTFS} 2> /dev/null || umount ${BLOCK_DEV_ROOT}
			xzcat ${IMAGE_ROOT}/${IMAGE}-${MACHINE}${IMAGE_NAME_SUFFIX}.${ROOTFSTYPE} | dd of=${BLOCK_DEV_ROOT} bs=1M
			;;
		squashfs*)
			umount ${ROOTFS} 2> /dev/null || umount ${BLOCK_DEV_ROOT}
			dd if=${IMAGE_ROOT}/${IMAGE}-${MACHINE}${IMAGE_NAME_SUFFIX}.${ROOTFSTYPE} of=${BLOCK_DEV_ROOT} bs=1M
			REMOUNT=false
			FIXUP_ROOTFS=false
			RESIZE_ROOTFS=false
			;;
		*)
			umount ${ROOTFS} 2> /dev/null || umount ${BLOCK_DEV_ROOT}
			dd if=${IMAGE_ROOT}/${IMAGE}-${MACHINE}${IMAGE_NAME_SUFFIX}.${ROOTFSTYPE} of=${BLOCK_DEV_ROOT} bs=1M
			;;
	esac

	if ${RESIZE_ROOTFS}
	then
		# Attempt to use e2fsprogs from Yocto/OE as the build host may have old versions...
		RESIZE2FS=resize2fs
		if [ -x tmp-glibc/sysroots-components/x86_64/e2fsprogs-native/sbin/resize2fs ]
		then
			RESIZE2FS=tmp-glibc/sysroots-components/x86_64/e2fsprogs-native/sbin/resize2fs
		fi
		TUNE2FS=tune2fs
		if [ -x tmp-glibc/sysroots-components/x86_64/e2fsprogs-native/sbin/tune2fs ]
		then
			TUNE2FS=tmp-glibc/sysroots-components/x86_64/e2fsprogs-native/sbin/tune2fs
		fi
		${TUNE2FS} -L ${ROOTLABEL} ${BLOCK_DEV_ROOT} || echo "Could not set label"
		${RESIZE2FS} ${BLOCK_DEV_ROOT} || echo "could not resize filesystem"
	fi

	if ${REMOUNT} && ${FIXUP_ROOTFS}
	then
		test -d ${ROOTFS} || mkdir ${ROOTFS}
		mount -t auto ${BLOCK_DEV_ROOT} ${ROOTFS} || FIXUP_ROOTFS=false
	fi

	if ${FIXUP_ROOTFS}
	then
		if [ -f dropbear_rsa_host_key ]
		then
			install -d ${ROOTFS}/etc/dropbear
			install -m 600 dropbear_rsa_host_key ${ROOTFS}/etc/dropbear/dropbear_rsa_host_key
		fi
	fi
fi

if $DO_UNMOUNT
then
	sleep 1
	echo -n "Unmounting"
	for p in ${MEDIA_BOOT} ${MEDIA}/sd-rootfs-a ${MEDIA}/sd-rootfs-b ${MEDIA}/data
	do
		if [ -d $p ]
		then
			echo -n " $p..."
			umount $p
			if [ -d $p ]
			then
				rmdir $p 2>/dev/null || true
			fi
		fi
	done
	echo ""
fi
echo "done."
