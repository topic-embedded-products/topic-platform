SWU_BOARD ?= "${MACHINE}"
SWU_HWREVISION ?= "0"
SWU_BOARD_HWREVISION ?= "${SWU_BOARD} ${SWU_HWREVISION}"

# The version as stored in the sw-description file. To make SWU detect what image
# has been installed, swu.inc will have created this file. This makes it so that
# every rootfs rebuild changes the version number.
IMAGEVERSION="${@open('${DEPLOY_DIR_IMAGE}/${BASENAME}-image-melodic.swrevision').read().strip()}"
