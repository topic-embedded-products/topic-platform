FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Only patch parted for the target, so it doesn't ask silly questions while in script mode
SRC_URI:append:class-target = " file://0001-parted-Don-t-warn-partition-busy-in-script-mode.patch"

