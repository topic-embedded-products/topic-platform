#!/bin/sh -e
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
if [ ! -e /dev/ubi0_0 ]
then
  echo "Attempting to attach ubi"
  if ! ubiattach -m 1 /dev/ubi_ctrl
  then
    echo "Failed to attach ubi, try formatting"
    ubiformat -y /dev/mtd1
  fi
fi
