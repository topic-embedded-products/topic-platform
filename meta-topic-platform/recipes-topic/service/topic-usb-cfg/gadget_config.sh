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
	rm -f $g1/configs/c1.1/${ethmode}.usb0
	rmdir $g1/configs/c1.1 || true
	rmdir $g1/functions/* || true
	rmdir $g1/strings/* || true
	rmdir $g1 || exit 1
fi
mkdir $g1
mkdir $g1/strings/0x409 # US English, others rarely seen
echo "TOPIC" > $g1/strings/0x409/manufacturer
echo "Network+Serial gadget" > $g1/strings/0x409/product
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
# Serial
mkdir $g1/functions/acm.0

# Configuration
mkdir $g1/configs/c1.1
ln -s $g1/functions/${ethmode}.usb0 $g1/configs/c1.1/${ethmode}.usb0
ln -s $g1/functions/acm.0 $g1/configs/c1.1/acm.0

# Attach to UDC
echo $f > $g1/UDC

done
