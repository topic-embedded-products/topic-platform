SECTION = "base"
DESCRIPTION = "SWUpdate UBI scripts"
LICENSE = "GPL-2.0-or-later"
LIC_FILES_CHKSUM = "file://run-qspi-update.sh;beginline=2;endline=2;md5=3b6e5b2caf81c241a5956ed7691327ab"
SRC_URI = "file://run-qspi-update.sh"
PV = "0"

S = "${WORKDIR}"

inherit allarch

do_compile () {
}

do_install () {
	install -d ${D}${bindir}
	install -m 0755 ${WORKDIR}/*.sh ${D}${bindir}
}

do_compile[noexec] = "1"
do_configure[noexec] = "1"
