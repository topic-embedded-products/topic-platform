SUMMARY = "Startup tiger VNC server through systemd service"
LICENSE = "CLOSED"
FILESEXTRAPATHS:prepend := "${THISDIR}/tigervnc-service:"

SERVICENAME = "x0vncserver"

inherit allarch systemd

SRC_URI = "file://${SERVICENAME}.service file://${SERVICENAME}.socket file://vncpasswd"

SYSTEMD_SERVICE:${PN} = "${SERVICENAME}.socket"

RDEPENDS:${PN} += "tigervnc-server"

do_compile() {
    :
}
do_compile[noexec] = "1"

FILES:${PN} += "${systemd_unitdir}/system"

VNC_USER ?= "root"

do_install() {
    install -m 0755 -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/${SERVICENAME}.service ${WORKDIR}/${SERVICENAME}.socket ${D}${systemd_unitdir}/system/
    sed -i 's/@USER@/${VNC_USER}/g' ${D}${systemd_unitdir}/system/${SERVICENAME}.service
    install -m 0755 -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/vncpasswd ${D}${sysconfdir}/
}
