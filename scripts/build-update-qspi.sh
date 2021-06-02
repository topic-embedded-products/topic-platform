#!/bin/sh -e
#
# Utility script to build a new image and send it to a board to
# update the eMMC using HTTP based SWUpdate.
#
# Run this from the build directory, after sourcing "profile"
#
# MACHINE environment should be set, HOST defaults to $MACHINE.local
# IMAGE defaults to my-image
#
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
	HOST="${MACHINE}.local"
fi
nice bitbake ${IMAGE}-swu-qspi
echo "Sending ${IMAGE}-swu-qspi-${MACHINE}.swu to ${HOST}"
curl -F "file=@tmp-glibc/deploy/images/${MACHINE}/${IMAGE}-swu-qspi-${MACHINE}.swu" "http://${HOST}:8080/upload"
