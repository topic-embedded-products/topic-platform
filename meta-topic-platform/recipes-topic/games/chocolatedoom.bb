# Copied from https://github.com/geoffrey-vl/meta-doom/
DESCRIPTION = "A Doom Clone based on SDL"
SECTION = "games"
DEPENDS = "virtual/libsdl2 libsdl2-mixer libsdl2-net fluidsynth libsamplerate0 libpng pkgconfig"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING.md;md5=60d644347832d2dd9534761f6919e2a6"

RRECOMMENDS:${PN} = "freedoom"

PV = "3.1.0"
SRC_URI = "git://github.com/chocolate-doom/chocolate-doom.git;protocol=https;branch=master"
SRCREV = "a78ff2b9195bd686c8b2bad8ffc354e55646bef6"

inherit autotools gettext pkgconfig

S = "${WORKDIR}/git"

FILES:${PN} += "${datadir} ${bindir}"
