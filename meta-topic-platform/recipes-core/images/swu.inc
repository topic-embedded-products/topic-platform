require swu-revision.inc

LICENSE = "CLOSED"

SWUPDATE_THINGS = "\
   swupdate \
   swupdate-www \
   ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'swupdate-usb swupdate-progress', '', d)} \
   "

# We require access to the git repository here, so we must run outside fakeroot
do_swumetadata() {
   # Hardware revision for SWUpdate
   echo "${SWU_BOARD_HWREVISION}" > ${IMAGE_ROOTFS}${sysconfdir}/hwrevision
   v=`git rev-parse --verify HEAD`
   echo $v > ${IMAGE_ROOTFS}${sysconfdir}/swrevision
   echo $v > ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}.swrevision
}
addtask do_swumetadata before do_image after do_rootfs

# Resolve manifest error in case this image gets included in another image
deltask do_packagedata
