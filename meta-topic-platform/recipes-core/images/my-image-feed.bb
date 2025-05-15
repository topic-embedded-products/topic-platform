SUMMARY = "Recipe to create a feed in addition to the images"

# Trick: We want to create the package index, and we don't actually
# package anything, so we "inherit" the package indexer recipe.
require recipes-core/meta/package-index.bb

# The images to build
DEPENDS = "my-image my-image-ro"

IMAGES_QSPI = "init-qspi-swu my-image-swu-qspi"
IMAGES_EMMC = "init-emmc-swu"
IMAGES_MMC0 = "my-image-swu-mmcblk0 my-image-ro-swu-mmcblk0"
IMAGES_MMC1 = "my-image-swu-mmcblk1 my-image-ro-swu-mmcblk1"

EXTRA_IMAGES ?= ""
EXTRA_IMAGES:topic-miami = "${IMAGES_QSPI} ${IMAGES_MMC0}"
EXTRA_IMAGES:topic-miamimp = "${IMAGES_QSPI} ${IMAGES_MMC0} ${IMAGES_MMC1} ${IMAGES_EMMC}"

DEPENDS += "${EXTRA_IMAGES}"

# List of packages that we want to build but not deploy on target. In alphabetical
# order for easy maintenance...
OPTIONAL_PACKAGES = "iperf3 strace"

DEPENDS += "${OPTIONAL_PACKAGES}"
