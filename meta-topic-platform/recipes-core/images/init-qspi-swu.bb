require init-common-swu.inc

SUMMARY = "QSPI Bootloader & partition init package for SWUpdate"

# Default to 2 volumes
SWU_QSPI_PARTITIONS ?= "1 2"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/init-qspi-single-partition-${SWU_BOOT_TYPE}:"

# Add all local files to be added to the SWU
# sw-description must always be in the list.
# You can extend with scripts or wahtever you need
SRC_URI = " \
    file://sw-description \
    file://init_ubi \
    "

UBOOTOFFSET ?= "0x60000"
UBOOTOFFSET:zynq = "0x20000"
UBOOTOFFSET:zynqmp = "0x60000"
