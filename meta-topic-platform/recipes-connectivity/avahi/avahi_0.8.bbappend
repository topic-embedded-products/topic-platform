# Make system visible on the network
do_install:append() {
    sed -i 's/publish-workstation=no/publish-workstation=yes/' ${D}${sysconfdir}/avahi/avahi-daemon.conf
}
