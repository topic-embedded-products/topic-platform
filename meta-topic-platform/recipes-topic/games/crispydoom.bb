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

PACKAGES =+ "crispy-doom crispy-heretic crispy-hexen crispy-strife crispy-server crispy-common"
RDEPENDS:${PN} = "crispy-doom crispy-heretic crispy-hexen crispy-strife crispy-server"

FILES:crispy-doom = "\
	${bindir}/*doom* \
	${datadir}/applications/*Doom* \
	${datadir}/doc/crispy-doom \
	${datadir}/icons/hicolor/*/apps/*doom* \
	${datadir}/metainfo/*Doom* \
	"
RDEPENDS:crispy-doom += "crispy-common"

FILES:crispy-heretic = "\
	${bindir}/*heretic* \
	${datadir}/applications/*Heretic* \
	${datadir}/doc/crispy-heretic \
	${datadir}/icons/hicolor/*/apps/*heretic* \
	${datadir}/metainfo/*Heretic* \
	"
RDEPENDS:crispy-heretic += "crispy-common"

FILES:crispy-hexen = "\
	${bindir}/*hexen* \
	${datadir}/applications/*Hexen* \
	${datadir}/doc/crispy-hexen \
	${datadir}/icons/hicolor/*/apps/*hexen* \
	${datadir}/metainfo/*Hexen* \
	"
RDEPENDS:crispy-hexen += "crispy-common"

FILES:crispy-strife = "\
	${bindir}/*strife* \
	${datadir}/applications/*Strife* \
	${datadir}/doc/crispy-strife \
	${datadir}/icons/hicolor/*/apps/*strife* \
	${datadir}/metainfo/*Strife* \
	"
RDEPENDS:crispy-strife += "crispy-common"

FILES:crispy-server = "${bindir}/crispy-server*"
FILES:crispy-common = "${datadir}/icons/hicolor/*/apps/*setup*"
