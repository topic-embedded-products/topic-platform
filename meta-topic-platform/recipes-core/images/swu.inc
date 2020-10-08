require swu-revision.inc

LICENSE = "CLOSED"

SWUPDATE_THINGS = "\
   swupdate \
   swupdate-www \
   ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'swupdate-usb swupdate-progress', '', d)} \
   "

rootfs_add_swu_metadata() {
   # Hardware revision for SWUpdate
   echo "${SWU_BOARD_HWREVISION}" > ${IMAGE_ROOTFS}${sysconfdir}/hwrevision
   v=`git rev-parse --verify HEAD`
   echo $v > ${IMAGE_ROOTFS}${sysconfdir}/swrevision
   echo $v > ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}.swrevision
}

ROOTFS_POSTPROCESS_COMMAND += "rootfs_add_swu_metadata;"
