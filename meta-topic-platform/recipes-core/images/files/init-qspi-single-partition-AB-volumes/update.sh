 #!/bin/sh -e
CMD=$1
if [ $# -ne 1 ]
then
	echo "Usage: $0 command"
	exit 1
fi

if [ "$CMD" = "preinst" ]
then
	init_ubi
elif [ "$CMD" = "postinst" ]
then
	# A reboot is unnecessary, but the swupdate ui is stating that the system is rebooting
	reboot
else
	echo "Invalid command"
	exit 1
fi
