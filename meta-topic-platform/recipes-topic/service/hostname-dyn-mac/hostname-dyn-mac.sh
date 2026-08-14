#!/bin/sh -e
exec hostnamectl --transient set-hostname "tep$(tr -d : < /sys/class/net/eth0/address | cut -c 9-)"
