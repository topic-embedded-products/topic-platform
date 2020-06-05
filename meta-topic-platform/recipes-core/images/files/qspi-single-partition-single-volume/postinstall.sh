#!/bin/sh -e
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
cd /tmp/
# Attempt to just write the new volume. This fails if it's mounted already.
if ! ubiupdatevol /dev/ubi0_0 /tmp/qspi-rootfs.ubifs
then
  echo qspi-rootfs.ubifs | cpio -H newc -v -o >> update-initramfs-image.cpio
  kexec --load /boot/Image --dtb /boot/system.dtb --initrd /tmp/update-initramfs-image.cpio --command-line "quiet root=/dev/ram0"
  echo "kexec primed, launching new kernel"
  systemctl kexec || reboot
fi
echo "UBI volume update complete"
