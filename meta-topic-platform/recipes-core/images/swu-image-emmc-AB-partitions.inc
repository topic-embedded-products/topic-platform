require swu-revision.inc

SUMMARY ?= "Image for SWUpdate"
SECTION = ""
LICENSE = "CLOSED"

FILESEXTRAPATHS_prepend := "${THISDIR}/files/emmc-AB-partitions:"

# Add all local files to be added to the SWU
# sw-description must always be in the list.
# You can extend with scripts or wahtever you need
SRC_URI = " \
    file://sw-description \
    file://update.sh \
    "

# Strip away "-swu-emmc" suffix to get default image name
IMAGENAME ?= "${@'${PN}'[:-9]}"

IMAGE_DEPENDS = "${IMAGENAME} virtual/kernel"

# Only one @@...@@ per line gets replaced, so combine them here
ROOTFSNAME = "${IMAGENAME}-${MACHINE}.rootfs.tar.gz"
ROOTFSNAME_petalinux = "${IMAGENAME}-${MACHINE}.tar.gz"


# images and files that will be included in the .swu image
SWUPDATE_IMAGES = "${ROOTFSNAME}"

inherit swupdate
