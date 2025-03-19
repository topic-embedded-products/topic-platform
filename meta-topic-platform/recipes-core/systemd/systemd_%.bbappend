# Remove unwanted features: backlight saving and hibernation
PACKAGECONFIG:remove = "\
	backlight \
	hibernate \
	quotacheck \
	vconsole \
	"

# Enable network components
PACKAGECONFIG:append = "\
	resolved \
	networkd \
	"

# Disable the network renaming "feature" so that we keep "eth0"
do_install:append() {
	ln -s -f /dev/null ${D}${rootlibexecdir}/systemd/network/99-default.link
}
