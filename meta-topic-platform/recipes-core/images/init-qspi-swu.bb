require swu-revision.inc

SUMMARY ?= "QSPI Bootloader & partition init package for SWUpdate"
SECTION = ""
LICENSE = "CLOSED"

FILESEXTRAPATHS_prepend := "${THISDIR}/files/init-qspi-single-partition-AB-volumes:${THISDIR}/../../recipes-topic/filesystem-prepare-scripts/filesystem-prepare-scripts:"

# Add all local files to be added to the SWU
# sw-description must always be in the list.
# You can extend with scripts or wahtever you need
SRC_URI = " \
    file://sw-description \
    file://init_ubi \
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
