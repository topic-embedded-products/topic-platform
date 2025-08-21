DESCRIPTION = "x11 graphical desktop image"

require my-image.bb

IMAGE_FEATURES += "splash x11-base x11-sato hwcodecs"

# Image will be too large for QSPI, so no ubifs
IMAGE_FSTYPES = "ext4.gz wic wic.bmap"

MY_THINGS += "${@bb.utils.contains('MACHINE_FEATURES', 'mali400', 'mesa-demos', '', d)}"

IMAGE_OVERHEAD_FACTOR="1.2"

MY_THINGS += "crispydoom"

MY_WAYLAND = "${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'wayland', '', d)}"

MY_THINGS += "${MY_WAYLAND}"
