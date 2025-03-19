SUMMARY = "Default network configuration file"
LICENSE = "CLOSED"

inherit allarch

SRC_URI = "file://50-dhcp-mac.conf"

do_compile() {
    true
}

do_install() {
    install -d ${D}${systemd_unitdir}/networkd.conf.d
    install -m 0644 ${WORKDIR}/*.conf ${D}${systemd_unitdir}/networkd.conf.d/
}

FILES:${PN} = "${systemd_unitdir}"
