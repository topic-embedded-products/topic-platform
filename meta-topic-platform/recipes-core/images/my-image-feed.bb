SUMMARY = "Recipe to create a feed in addition to the images"

# Trick: We want to create the package index, and we don't actually
# package anything, so we "inherit" the package indexer recipe.
require recipes-core/meta/package-index.bb

# The images to build
DEPENDS = "my-image"

IMAGES_QSPI = "init-qspi-swu my-image-swu-qspi"
IMAGES_EMMC = "init-emmc-swu my-image-swu-emmc"
IMAGES_SD = "my-image-swu-sd"

EXTRA_IMAGES ?= ""
EXTRA_IMAGES_topic-miami = "${IMAGES_QSPI} ${IMAGES_SD}"
EXTRA_IMAGES_topic-miamimp = "${IMAGES_QSPI} ${IMAGES_SD} ${IMAGES_EMMC}"
EXTRA_IMAGES_xdpzu7 = "${IMAGES_QSPI} ${IMAGES_EMMC}"

DEPENDS += "${EXTRA_IMAGES}"

# List of packages that we want to build but not deploy on target. In alphabetical
# order for easy maintenance...
OPTIONAL_PACKAGES = "strace v4l-utils"

DEPENDS += "${OPTIONAL_PACKAGES}"
