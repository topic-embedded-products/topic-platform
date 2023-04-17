# Enable Python support/bindings
PACKAGECONFIG += "libiio-python3"

# We need version 0.24 for 'label' support
SRCREV = "e598e4b9be84dc299c5ab9fb0da4d3cc29182030"
PV = "0.24+git${SRCPV}"
SRC_URI = "git://github.com/analogdevicesinc/libiio.git;protocol=https;branch=master"
