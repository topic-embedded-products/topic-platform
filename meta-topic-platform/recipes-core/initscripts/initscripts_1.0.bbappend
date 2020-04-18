FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Reduced sleep during shutdown routine
do_configure:append() {
    sed -i -e "s:sleep 5:sleep 1:g" ${WORKDIR}/sendsigs
}
