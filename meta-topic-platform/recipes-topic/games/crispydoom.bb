# Copied from https://github.com/geoffrey-vl/meta-doom/
DESCRIPTION = "A Doom Clone based on SDL"
SECTION = "games"
DEPENDS = "virtual/libsdl2 libsdl2-mixer libsdl2-net fluidsynth libsamplerate0 libpng pkgconfig"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING.md;md5=60d644347832d2dd9534761f6919e2a6"

RRECOMMENDS:${PN} = "freedoom"

PV = "7.0.0"
SRC_URI = "git://github.com/fabiangreffrath/crispy-doom;protocol=https;branch=master"
SRCREV = "74c68060785e46e35120e20182b01cf4bf08da71"

inherit autotools gettext pkgconfig

S = "${WORKDIR}/git"

FILES:${PN} += "${datadir}"
