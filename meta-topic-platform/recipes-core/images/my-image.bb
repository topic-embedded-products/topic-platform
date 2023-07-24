DESCRIPTION = "An image"

DISTRO_EXTRA_DEPENDS ?= ""
MACHINE_EXTRA_DEPENDS ?= ""
DEPENDS += "${DISTRO_EXTRA_DEPENDS} ${MACHINE_EXTRA_DEPENDS}"

IMAGE_FEATURES[validitems] += "swupdate"
IMAGE_FEATURES += "package-management ssh-server-dropbear swupdate"

IMAGE_FSTYPES = "ext4.gz tar.gz wic ubifs"

inherit core-image

# For ext4 images, they're resized to >1GB so use settings appropriate for that
# In particular, use at least 4k blocks, and reduce reserved blocks to 0%
EXTRA_IMAGECMD:ext4 += "-b -4096 -m 0"

UBI_SUPPORT = "${@ 'true' if bb.utils.contains("IMAGE_FSTYPES", "ubi", True, False, d) or bb.utils.contains("IMAGE_FSTYPES", "ubifs", True, False, d) else 'false'}"
WIC_SUPPORT = "${@ 'true' if bb.utils.contains("IMAGE_FSTYPES", "wic", True, False, d) or bb.utils.contains("IMAGE_FSTYPES", "wic.gz", True, False, d) else 'false'}"

require ${@bb.utils.contains("IMAGE_FEATURES", "swupdate", "swu.inc", "", d)}

# USB gadget ethernet works best when you have a DHCP server. Not suited for systemd though.
DHCPSERVERCONFIG = "${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '', 'udhcpd-iface-config', d)}"

MY_THINGS = "\
	kernel-image \
	${@bb.utils.contains('VIRTUAL-RUNTIME_dev_manager', 'busybox-mdev', 'modutils-loadscript', '', d)} \
	${@ 'mtd-utils-ubifs' if d.getVar('UBI_SUPPORT') == 'true' else ''} \
	${@ 'expand-wic-partition' if d.getVar('WIC_SUPPORT') == 'true' else ''} \
	${@bb.utils.contains("IMAGE_FEATURES", "swupdate", d.getVar('SWUPDATE_THINGS'), "", d)} \
	${@bb.utils.contains('MACHINE_FEATURES', 'usbgadget', d.getVar('DHCPSERVERCONFIG'), '', d)} \
	${@bb.utils.contains("IMAGE_FEATURES", "package-management", "distro-feed-configs avahi-daemon", "", d)} \
	${@bb.utils.contains('MACHINE_FEATURES', 'wifi', 'packagegroup-base-wifi', '', d)} \
	"

# Skip packagegroup-base to reduce the number of packages built. Thus, we need
# to include the MACHINE_EXTRA_ stuff ourselves.
IMAGE_INSTALL_MACHINE_EXTRAS ?= "packagegroup-machine-base"

# libgcc added to avoid errors like "libgcc_s.so.1 must be installed for pthread_exit to work"
IMAGE_INSTALL = "\
	packagegroup-core-boot \
	${@bb.utils.contains("IMAGE_FEATURES", "ssh-server-dropbear", "packagegroup-core-ssh-dropbear", "", d)} \
	packagegroup-distro-base \
	bootscript \
	libgcc \
	${IMAGE_INSTALL_MACHINE_EXTRAS} \
	${MY_THINGS} \
	"

# Reduce dropbear host key size to reduce boot time by about 5 seconds
DROPBEAR_RSAKEY_SIZE="1024"

DEVICETREELINKS ??= "system.dtb ${DEVICETREE}"

# Postprocessing to reduce the amount of work to be done
# by configuration scripts
myimage_rootfs_postprocess() {
	# Run populate-volatile.sh at rootfs time to set up basic files
	# and directories to support read-only rootfs.
	if [ -x ${IMAGE_ROOTFS}/etc/init.d/populate-volatile.sh ]; then
		echo "Running populate-volatile.sh"
		${IMAGE_ROOTFS}/etc/init.d/populate-volatile.sh
	fi
	# For sysvinit and similar, set up links. For systemd, no changes.
	if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'false', 'true', d)}
	then
		rm -rf ${IMAGE_ROOTFS}/media/* ${IMAGE_ROOTFS}/mnt
		ln -f -s media ${IMAGE_ROOTFS}/mnt
		rm -rf ${IMAGE_ROOTFS}/tmp
		ln -s var/volatile/tmp ${IMAGE_ROOTFS}/tmp
		rm -f ${IMAGE_ROOTFS}/etc/resolv.conf
		ln -s ../var/run/resolv.conf ${IMAGE_ROOTFS}/etc/resolv.conf
		rm -rf ${IMAGE_ROOTFS}/dev/*
		# Make links relative
		rm -f ${IMAGE_ROOTFS}/var/run ${IMAGE_ROOTFS}/var/tmp ${IMAGE_ROOTFS}/var/log
		ln -s volatile/tmp ${IMAGE_ROOTFS}/var/tmp
		ln -s volatile/log ${IMAGE_ROOTFS}/var/log
		ln -s ../run ${IMAGE_ROOTFS}/var/run
	fi

	echo -e "${DEVICETREELINKS}" | while read LINK TARGET
	do
		if [ -n "${TARGET}" ]
		then
			echo "DT: ${LINK}->${TARGET}"
			ln -s ${TARGET} ${IMAGE_ROOTFS}/boot/${LINK}
		fi
	done

	echo 'DROPBEAR_RSAKEY_ARGS="-s ${DROPBEAR_RSAKEY_SIZE}"' >> ${IMAGE_ROOTFS}${sysconfdir}/default/dropbear
}
ROOTFS_POSTPROCESS_COMMAND += "myimage_rootfs_postprocess ; "
