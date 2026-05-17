# SPDX-FileCopyrightText: 2026 Mark Jonas <toertel@gmail.com>
#
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-cmake-always-install-SDL2_net.pc.patch"
