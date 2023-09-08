DESCRIPTION = "MTD utilities for Python"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=030cb33d2af49ccebca74d0588b84a21"

SRCREV = "09fcf770bf8dd9b05df05a6cd566783395accb29"

inherit setuptools3 gitpkgv

PV = "0+${SRCPV}"
PKGV = "0+${GITPKGV}"
S = "${WORKDIR}/git"

SRC_URI = "git://github.com/topic-embedded-products/${BPN};protocol=https;branch=master"
