# Simple initramfs image artifact generation for tiny images.
DESCRIPTION = "Tiny image capable of booting"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

# Which image to encase
BASENAME ?= "my"
IMAGE_TO_UPDATE ?= "${BASENAME}-image"

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

export IMAGE_BASENAME = "${IMAGE_TO_UPDATE}-update-initrd"
IMAGE_LINGUAS = ""

# don't actually generate an image, just the artifacts needed for one
IMAGE_FSTYPES = "cpio.gz"

inherit core-image

IMAGE_ROOTFS_SIZE = "8192"
IMAGE_ROOTFS_EXTRA_SPACE = "0"

DEPENDS += "${IMAGE_TO_UPDATE}"

do_rootfs[depends] += "${IMAGE_TO_UPDATE}:do_image_complete"
rootfsaddimagetoflash() {
	install -m 644 ${DEPLOY_DIR}/images/${MACHINE}/${IMAGE_TO_UPDATE}-${MACHINE}.ubifs ${IMAGE_ROOTFS}/qspi-rootfs.ubifs

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

# # to install (kexec has a habit of printing scary errors which apparently mean nothing):
# kexec --load /boot/Image --dtb /boot/system.dtb --initrd /tmp/my-image-update-initrd-tdkzu6.cpio.gz --command-line "clk_ignore_unused coherent_pool=512k root=/dev/ram0" && echo okay && kexec -e
