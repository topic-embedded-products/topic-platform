#!/bin/sh

# Hotplug script for network devices

i="${MDEV}"

case "$ACTION" in
	add|"")
		export i
		(
			flock -n 9 || exit 0
			if [ ! -e /run/ifplugd.$i.run ]
			then
				if [ -x /etc/ifplugd.$i ]
				then
					IFACE=$i /etc/ifplugd.$i start
				fi
				if [ -e /etc/ifplugd.auto ]
				then
					ifplugd -i $i -r /etc/ifplugd.auto
				fi
			fi
		) 9> /run/ifplugd.$i.lock
		;;
	remove)
		if [ -e /run/ifplugd.$i.pid ]
		then
			ifplugd -i $i -k
			if [ -x /etc/ifplugd.$i ]
			then
				IFACE=$i /etc/ifplugd.$i stop
			fi
		fi
		rm -f /run/ifplugd.$i.run
		;;
	*)
		# Unexpected keyword
		exit 1
		;;
esac
