require swu-revision.inc

SUMMARY ?= "eMMC Bootloader & partition init package for SWUpdate"
SECTION = ""
LICENSE = "CLOSED"

# Only these machines have eMMC devices
COMPATIBLE_MACHINE = "^td[kp]zu|^xdp|^ttp"

FILESEXTRAPATHS_prepend := "${THISDIR}/files/petalinux-init-emmc-swu:${THISDIR}/../../recipes-topic/filesystem-prepare-scripts/filesystem-prepare-scripts:"

# Add all local files to be added to the SWU
# sw-description must always be in the list.
# You can extend with scripts or wahtever you need
SRC_URI = " \
    file://sw-description \
    file://partition_sd_card.sh \
    "

IMAGE_DEPENDS = "petalinux-image-minimal"

# images and files that will be included in the .swu image
SWUPDATE_IMAGES = "boot"

# Only one @@...@@ per line gets replaced, so combine them here
BOOTLOADNAME = "boot.bin"

# a deployable image can have multiple format, choose one
SWUPDATE_IMAGES_FSTYPES[boot] = ".bin"
SWUPDATE_IMAGES_NOAPPEND_MACHINE[boot] = "1"


inherit swupdate
