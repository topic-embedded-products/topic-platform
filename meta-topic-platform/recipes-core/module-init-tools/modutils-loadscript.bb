SECTION = "base"
DESCRIPTION = "modutils configuration files"
LICENSE = "GPL-2.0-or-later"
LIC_FILES_CHKSUM = "file://modload.sh;beginline=2;endline=2;md5=3b6e5b2caf81c241a5956ed7691327ab"
SRC_URI = "file://modload.sh"
PV = "3"

INITSCRIPT_NAME = "modload.sh"
INITSCRIPT_PARAMS = "start 5 S ."

S = "${WORKDIR}"

inherit allarch update-rc.d

do_compile () {
}

do_install () {
	install -d ${D}${sysconfdir}/init.d/
	install -m 0755 ${WORKDIR}/modload.sh ${D}${sysconfdir}/init.d/
}

do_compile[noexec] = "1"
do_configure[noexec] = "1"
