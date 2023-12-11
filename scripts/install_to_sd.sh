#!/bin/sh -e
if [ "$USER" = "root" ]
then
	echo "Do not run this script as root, it calls sudo."
	exit 1
fi
if [ -z "${MACHINE}" ]
then
	echo "MACHINE is not set, please set it"
fi
if [ -z "${IMAGE}" ]
then
	IMAGE=my-image
fi
sudo MACHINE="${MACHINE}" IMAGE="${IMAGE}" `dirname $0`/install_to_sd_common.sh
