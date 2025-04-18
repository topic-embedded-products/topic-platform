SUMMARY = "Prevent connman handling USB ethernet gadget"
LICENSE = "CLOSED"

inherit allarch

SRC_URI = "file://main.conf"

do_compile() {
    true
}

do_install() {
    install -d ${D}${sysconfdir}/connman
    install -m 0644 ${WORKDIR}/main.conf ${D}${sysconfdir}/connman/
}

FILES:${PN} = "${sysconfdir}/connman"
