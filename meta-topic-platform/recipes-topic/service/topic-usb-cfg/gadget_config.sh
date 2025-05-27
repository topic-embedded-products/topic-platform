#!/bin/sh -e
cfgdir="/sys/kernel/config/usb_gadget"
# One of: ncm ecm eem rndis
ethmode=rndis
# Loop through the USB udc candidates and create gadgets for all of them
for f in `ls /sys/class/udc`
do

g1="$cfgdir/$f"
if [ -d "$g1" ]
then
	echo "Removing existing $g1"
	rm -f $g1/configs/c1.1/*0 || true
	rmdir $g1/configs/c1.1 || true
	rmdir $g1/functions/* || true
	rmdir $g1/strings/* || true
	rmdir $g1 || exit 1
fi

if [ "$1" = "stop" ]
then
	continue
fi

mkdir $g1
mkdir $g1/strings/0x409 # US English, others rarely seen
echo "TOPIC" > $g1/strings/0x409/manufacturer
echo "Network+UAS gadget" > $g1/strings/0x409/product
if [ -e /etc/swrevision ]
then
	cat /etc/swrevision > $g1/strings/0x409/serialnumber
fi
echo "64" > $g1/bMaxPacketSize0
echo "0x200" > $g1/bcdUSB
echo "0x100" > $g1/bcdDevice
# Linux Foundation
echo "0x1d6b" > $g1/idVendor
# Multifunction Composite Gadget
echo "0x0104" > $g1/idProduct
# Ethernet
mkdir $g1/functions/${ethmode}.usb0
# UAS
mkdir $g1/functions/tcm.usb0
dd if=/dev/zero of=/tmp/file.$f bs=1M count=128
mkdir -p /sys/kernel/config/target/core/fileio_0/fileio
echo "fd_dev_name=/tmp/file.$f,fd_dev_size=134217728" > /sys/kernel/config/target/core/fileio_0/fileio/control
echo 1 > /sys/kernel/config/target/core/fileio_0/fileio/enable
mkdir -p /sys/kernel/config/target/usb_gadget/naa.$f/tpgt_1
mkdir /sys/kernel/config/target/usb_gadget/naa.$f/tpgt_1/lun/lun_0
echo naa.$f > /sys/kernel/config/target/usb_gadget/naa.$f/tpgt_1/nexus
ln -s /sys/kernel/config/target/core/fileio_0/fileio /sys/kernel/config/target/usb_gadget/naa.$f/tpgt_1/lun/lun_0/virtual_scsi_port
echo 1 > /sys/kernel/config/target/usb_gadget/naa.$f/tpgt_1/enable

# Configuration
mkdir $g1/configs/c1.1
ln -s $g1/functions/${ethmode}.usb0 $g1/configs/c1.1/${ethmode}.usb0
ln -s $g1/functions/tcm.usb0 $g1/configs/c1.1/tcm.usb0

# Attach to UDC
echo $f > $g1/UDC

done
