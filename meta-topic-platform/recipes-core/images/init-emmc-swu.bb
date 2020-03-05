require swu-revision.inc

SUMMARY ?= "QSPI Bootloader & partition init package for SWUpdate"
SECTION = ""
LICENSE = "CLOSED"

# Only these machines have eMMC devices
COMPATIBLE_MACHINE = "^tdkzu|^xdp"

IMAGEVERSION ?= "0"

FILESEXTRAPATHS_prepend := "${THISDIR}/files/init-emmc-swu:${THISDIR}/../../recipes-support/swupdate/swupdate:"

# Add all local files to be added to the SWU
# sw-description must always be in the list.
# You can extend with scripts or wahtever you need
SRC_URI = " \
    file://sw-description \
    file://partition_sd_card.sh \
    "

IMAGE_DEPENDS = "virtual/bootloader"

# images and files that will be included in the .swu image
SWUPDATE_IMAGES = "boot u-boot"

# Only one @@...@@ per line gets replaced, so combine them here
UBOOTNAME = "u-boot-${MACHINE}.${UBOOT_SUFFIX}"

# a deployable image can have multiple format, choose one
SWUPDATE_IMAGES_FSTYPES[boot] = ".bin"
SWUPDATE_IMAGES_NOAPPEND_MACHINE[boot] = "1"
SWUPDATE_IMAGES_FSTYPES[u-boot] = ".${UBOOT_SUFFIX}"

inherit swupdate
