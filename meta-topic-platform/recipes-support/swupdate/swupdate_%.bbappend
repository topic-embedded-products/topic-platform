FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

# To get and set active boot partition:
RDEPENDS_${PN} += "get-bootable-mbr-partition"
# To create ext4 filesystems:
RDEPENDS_${PN} += "e2fsprogs-mke2fs"
# To create ubi structures
RDEPENDS_${PN} += "mtd-utils-ubifs"
# To create partition tables
RDEPENDS_${PN} += "parted"

SRC_URI += " \
	file://20-swupdate-arguments \
	file://background.jpg \
	file://swupdate.cfg \
	file://switch_mmc_boot_partition \
	file://create_mmc_links \
	file://prepare_filesystem \
	file://init_ubi \
	file://partition_sd_card.sh \
	file://swu-transfer-settings.sh \
	file://swu-transfer-list \
"

CONFFILES_${PN} += "${sysconfdir}/swu-transfer-list"

do_install_append() {
	install -m 644 ${WORKDIR}/20-swupdate-arguments ${D}${libdir}/swupdate/conf.d/

	install -d ${D}${sysconfdir}
	install -m 644 ${WORKDIR}/swupdate.cfg ${D}${sysconfdir}/swupdate.cfg
	install -m 0644 ${WORKDIR}/swu-transfer-list ${D}${sysconfdir}/swu-transfer-list

	install -d ${D}${sbindir}
	install -m 0755 ${WORKDIR}/switch_mmc_boot_partition ${D}${sbindir}
	install -m 0755 ${WORKDIR}/create_mmc_links ${D}${sbindir}
	install -m 0755 ${WORKDIR}/prepare_filesystem ${D}${sbindir}
	install -m 0755 ${WORKDIR}/init_ubi ${D}${sbindir}
	install -m 0755 ${WORKDIR}/partition_sd_card.sh ${D}${sbindir}/partition_sd_card
	install -m 0755 ${WORKDIR}/swu-transfer-settings.sh ${D}${sbindir}/swu-transfer-settings

	# Replace 1MB image with something more modest
	install -m 644 ${WORKDIR}/background.jpg ${D}/www/images/background.jpg
}
