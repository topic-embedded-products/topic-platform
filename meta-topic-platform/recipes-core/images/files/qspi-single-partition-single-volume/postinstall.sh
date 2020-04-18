#!/bin/sh -e
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
cd /tmp/
# Attempt to just write the new volume. This fails if it's mounted already.
if ! ubiupdatevol /dev/ubi0_0 /tmp/qspi-rootfs.ubifs 2> /dev/null
then
  echo "Cannot directly update - prepare for kexec"
  echo qspi-rootfs.ubifs | cpio -H newc -v -o >> update-initramfs-image.cpio
  KIMAGE=/boot/Image
  if [ -e /boot/Image ]
  then
    KARG="--load /boot/Image"
  else
    KARG="--type=uImage --load /boot/uImage"
  fi
  kexec ${KARG} --dtb /boot/system.dtb --initrd /tmp/update-initramfs-image.cpio --command-line "quiet console=ttyPS0,115200 root=/dev/ram0"
  echo "kexec primed, launching new kernel"
  systemctl kexec || reboot
fi
echo "UBI volume update complete"
