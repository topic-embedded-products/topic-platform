SUMMARY = "Power off when user presses POWER button"
LICENSE = "CLOSED"

PV = "0"
SRC_URI = "file://${BPN}.c file://init.sh"
S = "${WORKDIR}"

inherit update-rc.d

INITSCRIPT_NAME = "${BPN}.sh"
INITSCRIPT_PARAMS = "start 88 S . "

do_compile() {
	${CC} ${CFLAGS} ${LDFLAGS} -o ${B}/${BPN} ${S}/${BPN}.c
}

do_install() {
	install -d ${D}${bindir}
	install -m 755 ${B}/${BPN} ${D}${bindir}
	install -d ${D}${sysconfdir}/init.d
	install -m 755 ${S}/init.sh ${D}${sysconfdir}/init.d/${BPN}.sh
}
