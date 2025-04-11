
# providers
PREFERRED_PROVIDER_libcrypto = "openssl"
PREFERRED_PROVIDER_libssl = "openssl"
PREFERRED_PROVIDER_jpeg = "libjpeg-turbo"
PREFERRED_PROVIDER_jpeg-native = "libjpeg-turbo-native"

# Pick the init manager (see conf/distro/defaultsetup.conf)

INIT_MANAGER = "systemd"

# Clean up features
DISTRO_FEATURES_BACKFILL_CONSIDERED:append = " pulseaudio"
DISTRO_FEATURES_DEFAULT = "ipv4 usbgadget usbhost largefile wifi bluetooth"

# For SWUpdate
PREFERRED_PROVIDER_u-boot-fw-utils = "libubootenv"

# do not install a syslog daemon (defaults to busybox-syslog)
VIRTUAL-RUNTIME_base-utils-syslog = ""

# build some core libs with heavier compiler optimization
O3_OPT = "-O3 -pipe ${DEBUG_FLAGS}"
FULL_OPTIMIZATION:pn-libgcrypt = "${O3_OPT}"
FULL_OPTIMIZATION:pn-zlib = "${O3_OPT}"

# Allow licenses for gstreamer components (consult your legal department...)
LICENSE_FLAGS_ACCEPTED ?= "commercial xilinx"
COMMERCIAL_AUDIO_PLUGINS ?= "gst-plugins-ugly-mad gst-plugins-ugly-mpegaudioparse"
COMMERCIAL_VIDEO_PLUGINS ?= "gst-plugins-ugly-mpeg2dec gst-plugins-ugly-mpegstream gst-plugins-bad-mpegvideoparse"
