FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

# Split out the x0vncserver binary
PACKAGES =+ "${PN}-server"
FILES:${PN}-server = "${bindir}/x0vncserver"

SRC_URI += "\
	file://0001-VNCSConnectionST-Release-mouse-button-s-on-close.patch \
	file://0001-x0vncserver-Add-support-for-systemd-socket-activatio.patch \
	file://0001-VNCServerST-Add-a-timeout-to-pointer-button-ownershi.patch \
	"
