require swu-image.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/files/sd-AB-partitions:"

# Define the dependencies of this image without using IMAGE_DEPENDS to avoid
# issues with nested images (see 009593f0c35213f6b4c4dc299d8e46b2033887de)
do_swuimage[depends] = "${IMAGENAME}:do_image_complete"

# Only one @@...@@ per line gets replaced, so combine them here
ROOTFSNAME = "${IMAGENAME}-${MACHINE}${IMAGE_NAME_SUFFIX}.tar.gz"

# images and files that will be included in the .swu image
SWUPDATE_IMAGES = "${ROOTFSNAME}"
