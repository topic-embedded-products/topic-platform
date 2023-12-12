#!/bin/sh
#
# start/stop KEY_POWER handler

case "$1" in
    start)
	start-stop-daemon -S -b -x /usr/bin/poweroff-key
	;;
    stop)
	start-stop-daemon -K -x /usr/bin/poweroff-key
	;;
    *)
	echo "Usage: $0 {start|stop}"
	exit 1
	;;
esac
