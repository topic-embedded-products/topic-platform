#!/bin/sh -e
cfgdir="/sys/kernel/config/usb_gadget"
# One of: ncm ecm eem rndis
ethmode=ncm
# mass storage
MSDEV=/dev/nvme0n1
FIOCONTROL="fd_dev_name=${MSDEV},fd_buffered_io=1"

instance=0
# Loop through the USB udc candidates and create gadgets for all of them
for f in `ls /sys/class/udc`
do

g1="$cfgdir/$f"
if [ -d "$g1" ]
then
	echo "Removing existing $g1"
	rm -f $g1/configs/c1.1/*.${f} || true
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
# Configuration
mkdir $g1/configs/c1.1
# Ethernet
mkdir $g1/functions/${ethmode}.${f}
ln -s $g1/functions/${ethmode}.${f} $g1/configs/c1.1/${ethmode}.${f}
# Mass storage
mkdir $g1/functions/mass_storage.${f}
lun=0
mkdir $g1/functions/mass_storage.${f}/lun.${lun} || true
if [ -d $g1/functions/mass_storage.${f}/lun.${lun} ]
then
	echo "16" >  $g1/functions/mass_storage.${f}/num_buffers || true
	echo "1" > $g1/functions/mass_storage.${f}/lun.${lun}/removable
	echo "1" > $g1/functions/mass_storage.${f}/lun.${lun}/ro
	echo "MS${instance}${lun}" > $g1/functions/mass_storage.${f}/lun.${lun}/inquiry_string
	echo "${MSDEV}" > $g1/functions/mass_storage.${f}/lun.${lun}/file
	ln -s $g1/functions/mass_storage.${f} $g1/configs/c1.1/mass_storage.${f}
fi
# ACM serial
if mkdir $g1/functions/acm.${f}
then
	ln -s $g1/functions/acm.${f} $g1/configs/c1.1/acm.${f}
else
	echo "Failed to enable ACM mode for $f"
fi
# Attach to UDC
echo $f > $g1/UDC

instance=$((instance + 1))
done
