require swu-image.inc

FILESEXTRAPATHS_prepend := "${THISDIR}/files/qspi-multiple-partitions:"

# Strip away "-swu-qspi" suffix to get default image name
IMAGENAME ?= "${@'${PN}'[:-9]}"
# images to build before building swupdate image
IMAGE_DEPENDS = "${IMAGENAME}-squashfs virtual/kernel"

# Only one @@...@@ per line gets replaced, som combine them here
ROOTFSNAME = "${IMAGENAME}-squashfs-${MACHINE}"

# images and files that will be included in the .swu image
SWUPDATE_KERNEL = "${KERNEL_IMAGETYPE}-${MACHINE}.bin"
SWUPDATE_IMAGES = "${ROOTFSNAME} ${SWUPDATE_KERNEL} ${DEVICETREE}"

python () {
    # SWUPDATE_IMAGES_FSTYPES[${ROOTFSNAME}] = ".rootfs.squashfs-lzo"
    d.setVarFlag("SWUPDATE_IMAGES_FSTYPES", d.getVar("ROOTFSNAME"), ".rootfs.squashfs-lzo")

    # SWUPDATE_IMAGES_NOAPPEND_MACHINE[${DEVICETREE}] = "1"
    d.setVarFlag("SWUPDATE_IMAGES_NOAPPEND_MACHINE", d.getVar("DEVICETREE"), "1")

    if len(d.getVar("KERNEL_IMAGETYPES").split(' ')) > 1:
        bb.fatal("Only one kernel type allowed, multiple kernel types provided: " + str(d.getVar("SWUPDATE_KERNEL")))

    if 'uImage' in d.getVar("SWUPDATE_KERNEL"):
        # SWUPDATE_IMAGES_FSTYPES[uImage] = ".bin"
        d.setVarFlag("SWUPDATE_IMAGES_FSTYPES", "uImage", ".bin")
}
