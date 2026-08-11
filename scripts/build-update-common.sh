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
	echo "HOST not set. Looking for candidates on the local network"
	candidates=`avahi-browse --ignore-local --terminate _workstation._tcp -p -k | cut -d ';' -f 4 | cut -d '\' -f 1 | grep '^tep' | sort -u`
	if [ -z "${candidates}" ]
	then
		echo "No boards found. Please set HOST manually"
		c="${MACHINE}"
	else
		echo "Please set HOST to one of these:"
		for c in ${candidates}
		do
			echo "HOST=${c}.local:8080"
		done
	fi
	echo "For example, run as:"
	echo "HOST=${c}.local:8080 $0"
	exit 2
fi
nice bitbake ${IMAGE}-swu-${DEVICE}
# Support having ".rootfs" in the filename
for IMAGE_NAME_SUFFIX in '.rootfs' ''
do
	if [ -e "tmp/deploy/images/${MACHINE}/${IMAGE}-swu-${DEVICE}-${MACHINE}${IMAGE_NAME_SUFFIX}.swu" ]
	then
		break
	fi
done
echo "Sending ${IMAGE}-swu-${DEVICE}-${MACHINE}${IMAGE_NAME_SUFFIX}.swu to ${HOST}"
curl -F "file=@tmp/deploy/images/${MACHINE}/${IMAGE}-swu-${DEVICE}-${MACHINE}${IMAGE_NAME_SUFFIX}.swu" "http://${HOST}/upload"
