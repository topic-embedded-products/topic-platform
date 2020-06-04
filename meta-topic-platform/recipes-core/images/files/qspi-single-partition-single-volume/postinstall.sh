#!/bin/sh -e
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
cd /tmp/
echo qspi-rootfs.ubifs | cpio -H newc -v -o >> update-initramfs-image.cpio
kexec --load /boot/Image --dtb /boot/system.dtb --initrd /tmp/update-initramfs-image.cpio --command-line "root=/dev/ram0"
echo "kexec primed, launching new kernel"
systemctl kexec || reboot
