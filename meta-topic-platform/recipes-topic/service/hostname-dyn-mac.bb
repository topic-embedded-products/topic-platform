SUMMARY = "Dynamic MAC address based on hostname (systemd only)"
LICENSE = "CLOSED"

SRC_URI = "file://${BPN}.service file://${BPN}.sh"
UNPACKDIR ??= "${WORKDIR}"
S = "${UNPACKDIR}"

inherit allarch systemd

SYSTEMD_SERVICE:${PN} = "${BPN}.service"

do_compile[noexec] = "1"

do_install() {
    install -m 0755 -d ${D}${systemd_unitdir}/system
    install -m 0644 ${S}/${BPN}.service ${D}${systemd_unitdir}/system/
    install -m 0755 -d ${D}${bindir}
    install -m 0755 ${S}/${BPN}.sh ${D}${bindir}/
}
