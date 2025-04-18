# If connman is used to manage the network, don't let it touch the usb ethernet gadget
RDEPENDS:${PN}-base += "${@bb.utils.contains('NETWORK_MANAGER', 'connman-gnome', 'connman-blacklist-usb', '', d)}"
