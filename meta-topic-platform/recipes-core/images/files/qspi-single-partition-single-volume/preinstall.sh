#!/bin/sh -e
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
if [ ! -e /dev/ubi0_0 ]
then
  echo "Attempting to attach ubi"
  if ! ubiattach -m 3 /dev/ubi_ctrl
  then
    echo "Failed to attach ubi, try formatting"
    ubiformat -y /dev/mtd3
  fi
fi
