DESCRIPTION = "An image"

DISTRO_EXTRA_DEPENDS ?= ""
MACHINE_EXTRA_DEPENDS ?= ""
DEPENDS += "${DISTRO_EXTRA_DEPENDS} ${MACHINE_EXTRA_DEPENDS}"

IMAGE_FEATURES[validitems] += "swupdate"
IMAGE_FEATURES += "package-management ssh-server-dropbear swupdate"

IMAGE_FSTYPES = "ext4.gz wic wic.bmap"

inherit core-image

# For ext4 images, they're resized to >1GB so use settings appropriate for that
# In particular, use at least 4k blocks, and reduce reserved blocks to 0%
EXTRA_IMAGECMD:ext4 += "-b -4096 -m 0"

UBI_SUPPORT = "${@ 'true' if bb.utils.contains("IMAGE_FSTYPES", "ubi", True, False, d) or bb.utils.contains("IMAGE_FSTYPES", "ubifs", True, False, d) else 'false'}"
WIC_SUPPORT = "${@ 'true' if bb.utils.contains("IMAGE_FSTYPES", "wic", True, False, d) or bb.utils.contains("IMAGE_FSTYPES", "wic.gz", True, False, d) else 'false'}"

require ${@bb.utils.contains("IMAGE_FEATURES", "swupdate", "swu.inc", "", d)}

# USB gadget ethernet works best when you have a DHCP server.
DHCPSERVERCONFIG = "${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'topic-usb-cfg', 'topic-usb-cfg udhcpd-iface-config', d)}"

# The poweroff-key is not needed when running systemd
POWERKEY_PROGRAM = "${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '', 'poweroff-key', d)}"

# Use a dynamically generated hostname when running systemd
HOSTNAME_PROVIDER ?= "${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'hostname-dyn-mac', '', d)}"

# Be able to find the machine on the network
MDNS_PROVIDER ?= "avahi-daemon"

MY_THINGS = "\
	kernel-image \
	${@bb.utils.contains('VIRTUAL-RUNTIME_dev_manager', 'busybox-mdev', 'modutils-loadscript', '', d)} \
	${@ 'mtd-utils-ubifs' if d.getVar('UBI_SUPPORT') == 'true' else ''} \
	${@ 'expand-wic-partition' if d.getVar('WIC_SUPPORT') == 'true' else ''} \
	${@bb.utils.contains("IMAGE_FEATURES", "swupdate", d.getVar('SWUPDATE_THINGS'), "", d)} \
	${@bb.utils.contains('MACHINE_FEATURES', 'usbgadget', d.getVar('DHCPSERVERCONFIG'), '', d)} \
	${@bb.utils.contains("IMAGE_FEATURES", "package-management", "distro-feed-configs", "", d)} \
	${@bb.utils.contains('MACHINE_FEATURES', 'wifi', 'packagegroup-base-wifi', '', d)} \
	${@bb.utils.contains('MACHINE_FEATURES', 'powerkey', d.getVar('POWERKEY_PROGRAM'), '', d)} \
	${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd-net-config', '', d)} \
	${MDNS_PROVIDER} \
	${HOSTNAME_PROVIDER} \
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
DROPBEAR_RSAKEY_SIZE = "1024"

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

	if [ -n "${HOSTNAME_PROVIDER}" ]
	then
		rm -f ${IMAGE_ROOTFS}${sysconfdir}/hostname
	fi

	# Remove OSC3008 support (same as removing osc-context from systemd
	# PACKAGECONFIG, but less intrusive)
	rm -f ${IMAGE_ROOTFS}${sysconfdir}/profile.d/80-systemd-osc-context.sh
	rm -f ${IMAGE_ROOTFS}${nonarch_libdir}/tmpfiles.d/20-systemd-osc-context.conf

	echo 'DROPBEAR_RSAKEY_ARGS="-s ${DROPBEAR_RSAKEY_SIZE}"' >> ${IMAGE_ROOTFS}${sysconfdir}/default/dropbear
}

# For read-only rootfs, fix that systemd-timesyncd and systemd-networkd-persistent-storage
# won't start
myimage_read_only_rootfs_hook() {
	for f in systemd-timesyncd systemd-networkd-persistent-storage
	do
		if [ -e ${IMAGE_ROOTFS}/usr/lib/systemd/system/$f.service ]
		then
			sed -i "/After=/i After=var-volatile-lib.service" ${IMAGE_ROOTFS}/usr/lib/systemd/system/$f.service
		fi
	done
}

# We require access to the git repository here, so we must run outside fakeroot
# Store the git hash into /etc/revision
# On read-only filesystems, create a fixed machine-id (using the git hash)
do_addrevisioninfo() {
	git rev-parse --verify --short=32 HEAD >> ${IMAGE_ROOTFS}${sysconfdir}/revision
	if ${@bb.utils.contains("IMAGE_FEATURES", "read-only-rootfs", "true", "false",d)}
	then
		cut -b 1-32 ${IMAGE_ROOTFS}${sysconfdir}/revision > ${IMAGE_ROOTFS}${sysconfdir}/machine-id
	fi
}

addtask do_addrevisioninfo before do_image after do_rootfs

ROOTFS_POSTPROCESS_COMMAND += "myimage_rootfs_postprocess ; "
ROOTFS_POSTPROCESS_COMMAND += '${@bb.utils.contains("IMAGE_FEATURES", "read-only-rootfs", "myimage_read_only_rootfs_hook ", "",d)}'
