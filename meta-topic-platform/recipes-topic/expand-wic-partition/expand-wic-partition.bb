SUMMARY = "Grow and add WIC partitions at first boot"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://init file://${BPN}.service file://${BPN}.sh"
S = "${WORKDIR}"

RDEPENDS_${PN} += "\
	e2fsprogs-resize2fs \
	e2fsprogs-tune2fs \
	e2fsprogs-mke2fs \
	parted \
	"

inherit allarch update-rc.d systemd

INITSCRIPT_NAME = "${BPN}.sh"
INITSCRIPT_PARAMS = "start 08 S ."

SYSTEMD_SERVICE_${PN} = "${BPN}.service"

do_compile() {
	true
}

FILES_${PN} = "${bindir} ${sysconfdir} ${systemd_unitdir}"

do_install() {
	install -d ${D}${bindir}
	install -m 755 ${WORKDIR}/${BPN}.sh ${D}${bindir}/${PN}.sh
	install -d ${D}${sysconfdir}/init.d
	install -m 755 ${WORKDIR}/init ${D}${sysconfdir}/init.d/${BPN}.sh
	install -d ${D}${systemd_unitdir}/system
	install -m 0644 ${WORKDIR}/${BPN}.service ${D}${systemd_unitdir}/system/
	sed -i -e 's,@BINDIR@,${bindir},g' ${D}${systemd_unitdir}/system/${BPN}.service
}
