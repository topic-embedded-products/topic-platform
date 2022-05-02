SRC_URI += "\
	file://inetd file://inetd.conf \
	file://mdev file://mdev.conf file://mdev-defaults \
	"

do_install:append() {
	if grep -q "CONFIG_CRONTAB=y" ${WORKDIR}/defconfig; then
		install -d ${D}${sysconfdir}/cron/crontabs
	fi
	install -d ${D}${sysconfdir}/default
	install -m 644 ${WORKDIR}/mdev-defaults ${D}${sysconfdir}/default/mdev
}

FILES:${PN}-mdev += "${sysconfdir}/default/mdev"
# Some packages recommend udev-hwdb to be installed. To prevent them actually
# installing, just claim we already provide it and conflict with its default
# provider.
RPROVIDES:${PN}-mdev += "udev udev-hwdb"
RCONFLICTS:${PN}-mdev += "eudev eudev-hwdb"

# use our own defconfig
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
