require init-common-swu.inc

SUMMARY = "eMMC Bootloader & partition init package for SWUpdate"

# Only these machines have eMMC devices
COMPATIBLE_MACHINE = "^t[de][kp]zu|^xdp|^ttp"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/init-emmc-${SWU_BOOT_TYPE}:"

SRC_URI = " \
    file://sw-description \
    file://partition_sd_card.sh \
    "
