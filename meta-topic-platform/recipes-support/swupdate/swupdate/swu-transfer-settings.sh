#!/bin/sh -e
if [ $# -ne 1 ] || [ ! -e $1 ]
then
	echo "Usage: $0 mount_directory"
	echo "Transfer system settings to updated partition"
	exit 1
fi
UPDATE_MOUNT="$1"

# Copy all files from the list. One entry per line, must be absolute paths.
if [ -e /etc/swu-transfer-list ]
then
  while read f
  do
    if [ -e "$f" -a "${f:0:1}" = "/" ]
    then
      d=`dirname "$f"`
      if [ ! -e "${UPDATE_MOUNT}$d" ]
      then
        mkdir -p "${UPDATE_MOUNT}$d"
      fi
      cp -rp $f "${UPDATE_MOUNT}$d" || echo "Failed to copy: $f"
    fi
  done < /etc/swu-transfer-list
fi
