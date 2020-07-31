FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

# To get and set active boot partition:
RDEPENDS_${PN} += "get-bootable-mbr-partition"
# Scripts to prepare various filesystems
RDEPENDS_${PN} += "filesystem-prepare-scripts"

# Using "swupdate.config" because ".cfg" would trigger merge_config
SRC_URI += "\
	${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'file://enable-systemd.cfg', '', d)} \
	file://20-swupdate-arguments \
	file://background.jpg \
	file://swupdate.config \
	file://switch_mmc_boot_partition \
	file://create_mmc_links \
	file://swu-hotplug.sh \
	file://swu-transfer-settings.sh \
	file://swu-transfer-list \
"

FILES_${PN}-usb += "${sbindir}/swu-hotplug.sh"

# swupdate recipe does not take fragments into account, only defconfig
DEPENDS += "${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', '', d)}"

CONFFILES_${PN} += "${sysconfdir}/swu-transfer-list"

do_install_append() {
	install -m 644 ${WORKDIR}/20-swupdate-arguments ${D}${libdir}/swupdate/conf.d/

	install -d ${D}${sysconfdir}
	install -m 644 ${WORKDIR}/swupdate.config ${D}${sysconfdir}/swupdate.cfg
	install -m 0644 ${WORKDIR}/swu-transfer-list ${D}${sysconfdir}/swu-transfer-list

	install -d ${D}${sbindir}
	install -m 0755 ${WORKDIR}/switch_mmc_boot_partition ${D}${sbindir}
	install -m 0755 ${WORKDIR}/create_mmc_links ${D}${sbindir}
	install -m 0755 ${WORKDIR}/swu-transfer-settings.sh ${D}${sbindir}/swu-transfer-settings

	install -m 0755 ${WORKDIR}/swu-hotplug.sh ${D}${sbindir}/

	# Replace 1MB image with something more modest
	install -m 644 ${WORKDIR}/background.jpg ${D}/www/images/background.jpg
	# Remove unneeded font files (they're only used for some icons)
	rm ${D}/www/webfonts/fa-solid-900.woff*
}
