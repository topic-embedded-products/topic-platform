require swu-image.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/../../recipes-topic/filesystem-prepare-scripts/filesystem-prepare-scripts:"

SECTION = ""
LICENSE = "CLOSED"

SWU_BOOT_TYPE ?= "${@bb.utils.contains('PREFERRED_PROVIDER_virtual/boot-bin', 'xilinx-bootbin', 'fsbl', 'spl', d)}"

# Define the dependencies of this image without using IMAGE_DEPENDS to avoid
# issues with nested images (see 009593f0c35213f6b4c4dc299d8e46b2033887de)
do_swuimage[depends] = "virtual/boot-bin:do_deploy"

# images and files that will be included in the .swu image. When using SPL, there are two files
SWUPDATE_IMAGES = "${@bb.utils.contains('SWU_BOOT_TYPE', 'spl', 'boot u-boot', 'boot', d)}"

# Only one @@...@@ per line gets replaced, so combine them here
UBOOTNAME = "u-boot-${MACHINE}.${UBOOT_SUFFIX}"

# a deployable image can have multiple format, choose one
SWUPDATE_IMAGES_FSTYPES[boot] = ".bin"
SWUPDATE_IMAGES_NOAPPEND_MACHINE[boot] = "1"
SWUPDATE_IMAGES_FSTYPES[u-boot] = ".${UBOOT_SUFFIX}"
