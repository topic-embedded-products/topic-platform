#!/bin/sh -e
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
ubiattach -m 3 /dev/ubi_ctrl || true
