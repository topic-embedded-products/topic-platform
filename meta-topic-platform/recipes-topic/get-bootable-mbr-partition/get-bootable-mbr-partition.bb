DESCRIPTION = "Tool to extract bootable partition from MBR"
LICENSE = "CLOSED"

inherit gitpkgv
PKGV = "${GITPKGVTAG}"

SRCREV = "6ced184ba3c21afd225eab70106e25bc5917c147"
SRC_URI = "git://github.com/topic-embedded-products/${BPN}"

S = "${WORKDIR}/git"

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 ${B}/${PN} ${D}${sbindir}
}
