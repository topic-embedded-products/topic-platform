SUMMARY = "Supplies interface-based startup of DHCP server udhcpd"
LICENSE = "GPL-2.0-or-later"
LIC_FILES_CHKSUM = "file://${META_ZYNQ_BASE}/COPYING;md5=751419260aa954499f7abaabaa882bbe"
inherit allarch
PACKAGE_ARCH = "${MACHINE_ARCH}"
PV = "5"

PACKAGES = "${PN}"
SRC_URI = "\
	file://udhcpd_up.sh file://udhcpd_down.sh \
	file://udhcpd.usb0.conf file://udhcpd.wlan1.conf \
	"
S = "${WORKDIR}"
FILES:${PN} = "${sysconfdir}"

# Don't install ifplugd-auto-net on systemd
RDEPENDS:${PN} = "${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '', 'ifplugd-auto-net', d)}"

do_compile() {
}

do_install() {
	install -d ${D}/${sysconfdir}/network/if-up.d
	install -d ${D}/${sysconfdir}/network/if-down.d
	install -m 644 udhcpd.*.conf ${D}/${sysconfdir}
	install -m 755 udhcpd_up.sh ${D}/${sysconfdir}/network/if-up.d/udhcpd
	install -m 755 udhcpd_down.sh ${D}/${sysconfdir}/network/if-down.d/udhcpd
}
