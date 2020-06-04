# Simple initramfs image artifact generation for self-updaging flash image.
# This expects the rootfs to be appended (in cpio format) to the cpio archive
DESCRIPTION = "Update image for flash device"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

VIRTUAL-RUNTIME_dev_manager = "busybox-mdev"

PACKAGE_INSTALL = "\
	packagegroup-core-boot \
	${VIRTUAL-RUNTIME_base-utils} \
	${VIRTUAL-RUNTIME_dev_manager} \
	base-passwd \
	${ROOTFS_BOOTSTRAP_INSTALL} \
	swu-ubi-scripts \
	"

# Do not pollute the initrd image with rootfs features
# Add debug-tweaks if you want to allow root login
IMAGE_FEATURES = ""

IMAGE_LINGUAS = ""

# don't actually generate an image, just the artifacts needed for one
IMAGE_FSTYPES = "cpio"

inherit core-image

IMAGE_ROOTFS_SIZE = "8192"
IMAGE_ROOTFS_EXTRA_SPACE = "0"

rootfsaddimagetoflash() {
	# Kill the automounter so nothing gets mounted by hotplug
	echo "#" > ${IMAGE_ROOTFS}/etc/mdev/mdev-mount.sh

	# remove getty and auto-start the update routine
	grep -v getty ${IMAGE_ROOTFS}${sysconfdir}/inittab > ${IMAGE_ROOTFS}${sysconfdir}/inittab.new
	echo "up1:345:wait:${bindir}/run-qspi-update.sh" >> ${IMAGE_ROOTFS}${sysconfdir}/inittab.new
	echo "up2:345:once:/sbin/reboot" >> ${IMAGE_ROOTFS}${sysconfdir}/inittab.new
	rm ${IMAGE_ROOTFS}${sysconfdir}/inittab
	mv ${IMAGE_ROOTFS}${sysconfdir}/inittab.new ${IMAGE_ROOTFS}${sysconfdir}/inittab
}

IMAGE_PREPROCESS_COMMAND += "rootfsaddimagetoflash;"

# cd /tmp/
# 
# echo qspi-rootfs.ubifs | cpio -H newc -v -o >> update-initramfs-image-tdkzu6.cpio
# kexec --load /boot/Image --dtb /boot/system.dtb --initrd /tmp/update-initramfs-image-tdkzu6.cpio --command-line "clk_ignore_unused coherent_pool=512k root=/dev/ram0" && echo okay && kexec -e
