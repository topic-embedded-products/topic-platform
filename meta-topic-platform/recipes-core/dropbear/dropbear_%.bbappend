FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Enable X11 forwarding when X11 is enabled
PACKAGECONFIG += "${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'enable-x11-forwarding', '', d)}"

