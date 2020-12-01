
DISTRO_EXTRA_DEPENDS ?= ""
MACHINE_EXTRA_DEPENDS ?= ""
DEPENDS += "${DISTRO_EXTRA_DEPENDS} ${MACHINE_EXTRA_DEPENDS}"

IMAGE_FEATURES[validitems] += "swupdate"
IMAGE_FEATURES += "package-management ssh-server-dropbear swupdate"

IMAGE_FSTYPES += " wic "



require ${@bb.utils.contains("IMAGE_FEATURES", "swupdate", "swu.inc", "", d)}
#distro-feed-configs is not support by petalinux
IMAGE_INSTALL_append = "\
  packagegroup-base \
	bootscript \
	swupdate \
	busybox \
	xilinx-bootbin \
        packagegroup-core-boot \
        packagegroup-core-ssh-dropbear \
        packagegroup-distro-base \
	networkmanager \
	memtester \
	${MACHINE_EXTRA_RRECOMMENDS} \
	${IMAGE_INSTALL_MACHINE_EXTRAS} \
	${ROOTFS_PKGMANAGE} \
	${BOARD_PL_REFERENCE} \
	${@bb.utils.contains('VIRTUAL-RUNTIME_dev_manager', 'busybox-mdev', 'modutils-loadscript', '', d)} \
	${@ 'mtd-utils-ubifs' if d.getVar('UBI_SUPPORT') == 'true' else ''} \
	${@ 'expand-wic-partition' if d.getVar('WIC_SUPPORT') == 'true' else ''} \
	${@bb.utils.contains("IMAGE_FEATURES", "swupdate", d.getVar('SWUPDATE_THINGS'), "", d)} \
	${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '', 'udhcpd-iface-config', d)} \
	${@bb.utils.contains("IMAGE_FEATURES", "package-management", " avahi-daemon", "", d)} \
	${@bb.utils.contains('MACHINE_FEATURES', 'wifi', 'packagegroup-base-wifi', '', d)} \
	"



# Reduce dropbear host key size to reduce boot time by about 5 seconds
DROPBEAR_RSAKEY_SIZE="1024"

# Postprocessing to reduce the amount of work to be done
# by configuration scripts
petalinux_rootfs_postprocess() {
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
  cp ${DEPLOY_DIR_IMAGE}/Image ${IMAGE_ROOTFS}/boot/Image


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
ROOTFS_POSTPROCESS_COMMAND += "petalinux_rootfs_postprocess ; "




