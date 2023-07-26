#!/bin/sh -e
#
# Utility script to build a new image and send it to a board to
# update it using HTTP based SWUpdate.
#
# Run this from the build directory, after sourcing "profile"
#
# Environments:
# MACHINE environment should be set,
# HOST defaults to $MACHINE.local:8080
# IMAGE defaults to "my-image"
#
# This script should be called "build-update-device.sh" where "device" is one
# of "mmcblk0", "qspi", "emmc", etc.
DEVICE=$(basename $0 .sh | cut -c 14-)
if [ -z "${MACHINE}" ]
then
	echo "MACHINE environment not set"
	exit 1
fi
if [ -z "${IMAGE}" ]
then
	IMAGE=my-image
fi
if [ -z "${HOST}" ]
then
	HOST="${MACHINE}.local:8080"
fi
nice bitbake ${IMAGE}-swu-${DEVICE}
echo "Sending ${IMAGE}-swu-${DEVICE}-${MACHINE}.swu to ${HOST}"
curl -F "file=@tmp-glibc/deploy/images/${MACHINE}/${IMAGE}-swu-${DEVICE}-${MACHINE}.swu" "http://${HOST}/upload"
