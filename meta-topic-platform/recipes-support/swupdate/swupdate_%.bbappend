FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# To get and set active boot partition:
RDEPENDS:${PN} += "get-bootable-mbr-partition"
# Scripts to prepare various filesystems
RDEPENDS:${PN} += "filesystem-prepare-scripts"

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

FILES:${PN}-usb += "${sbindir}/swu-hotplug.sh"

# swupdate recipe does not take fragments into account, only defconfig
DEPENDS += "${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', '', d)}"

CONFFILES:${PN} += "${sysconfdir}/swu-transfer-list"

do_install:append() {
	install -m 644 ${UNPACKDIR}/20-swupdate-arguments ${D}${libdir}/swupdate/conf.d/

	install -d ${D}${sysconfdir}
	install -m 644 ${UNPACKDIR}/swupdate.config ${D}${sysconfdir}/swupdate.cfg
	install -m 0644 ${UNPACKDIR}/swu-transfer-list ${D}${sysconfdir}/swu-transfer-list

	install -d ${D}${sbindir}
	install -m 0755 ${UNPACKDIR}/switch_mmc_boot_partition ${D}${sbindir}
	install -m 0755 ${UNPACKDIR}/create_mmc_links ${D}${sbindir}
	install -m 0755 ${UNPACKDIR}/swu-transfer-settings.sh ${D}${sbindir}/swu-transfer-settings

	install -m 0755 ${UNPACKDIR}/swu-hotplug.sh ${D}${sbindir}/

	# Replace 1MB image with something more modest
	install -m 644 ${UNPACKDIR}/background.jpg ${D}/www/images/background.jpg
	# Remove unneeded font files (they're only used for some icons)
	rm ${D}/www/webfonts/fa-solid-900.woff*
}

# Avoid error until upstream properly fixes this:
# ERROR: swupdate-2026.05.1-r0 do_package_qa: QA Issue: File /usr/bin/swupdate in package swupdate contains reference to TMPDIR [buildpaths]
INSANE_SKIP += "buildpaths"
