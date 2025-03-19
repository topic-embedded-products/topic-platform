SUMMARY = "USB in ethernet gadget mode"
LICENSE = "CLOSED"

# Creates a USB multiconfig gadgets for every USB port found. Defaults to
# ethernet gadget only, but as a multiconfig device it could also do mass storage,
# serial, and whatnot by adding a few lines to gadget_config.sh

SRC_URI = "\
    file://gadget_config.sh \
    file://10-usb0.network \
    file://10-usb1.network \
    file://topic-usb-gadget.service \
    file://init \
    "
S = "${WORKDIR}"

inherit allarch systemd update-rc.d

SYSTEMD_SERVICE:${PN} = "topic-usb-gadget.service"

INITSCRIPT_NAME = "${BPN}.sh"
INITSCRIPT_PARAMS = "start 20 S ."

FILES:${PN} = "${sbindir} ${sysconfdir} ${systemd_unitdir}/system"

do_install() {
    install -d ${D}${sbindir}
    install -m 755 ${S}/gadget_config.sh ${D}${sbindir}
    install -m 0755 -d ${D}${sysconfdir}/systemd/network
    install -m 0644 ${WORKDIR}/10-usb*.network ${D}${sysconfdir}/systemd/network
    install -m 0755 -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/topic-usb-gadget.service ${D}${systemd_unitdir}/system/
    install -d ${D}${sysconfdir}/init.d
    install -m 755 ${WORKDIR}/init ${D}${sysconfdir}/init.d/${BPN}.sh
}
