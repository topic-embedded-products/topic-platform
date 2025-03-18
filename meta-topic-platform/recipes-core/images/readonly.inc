# Make image use a read-only squashfs for fast booting and high availability
IMAGE_FSTYPES_WIC = "${@ 'wic wic.bmap' if d.getVar('WKS_FILE_RO') else ''}"
IMAGE_FSTYPES = "squashfs-lz4 ${IMAGE_FSTYPES_WIC}"
EXTRA_IMAGECMD:squashfs-lz4 = "-Xhc"
IMAGE_FEATURES += "read-only-rootfs"
IMAGE_FEATURES:remove = "package-management"
# If the board defines a WKS_FILE_RO variable, we'll create a WIC image
WKS_FILE = "${WKS_FILE_RO}"
