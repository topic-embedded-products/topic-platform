# About this repository

This is a development branch for "zeus" test and integration.

## BSP

Topic Embedded Products BSP for the Miami and Florida boards on top of a Linux distribution. The Miami/Florida BSP is basically a lightweight OpenEmbedded based Linux Distribution, allowing you to easily run your applications on the Miami/Florida. It is based on the mainline Linux distribution as well as the Xilinx supported branch.

## New features

SWUpdate integration - install images directly into the device over network.

Dynamic loading of devicetree overlays. Inject DT fragments after loading the FPGA code, so drivers can be made built-in. Can detect carriers and expansion boards at runtime and load appropriate drivers and firmware.

# Initial setup

```
git clone http://github.com/topic-embedded-products/topic-platform.git
cd topic-platform
git submodule update --init

./scripts/init-oe.sh

cd build

# Edit local.conf to match your setup.
vi conf/local.conf

# To build your BSP it is necessary to set the correct MACHINE environment variable. 
# To do this change it in the "profile" script or just export the MACHINE environment 
# before building. Refer to meta-topic/conf/machine for a list of values 
# (e.g. "tdkz30" or "tdkzu9" for the Topic Development Kits).

# Then build your first image and relax a bit:
source profile
MACHINE=tdkz30 nice bitbake my-image
````

Note that "my-image" was designed to be used with DISTRO=tiny. It
expects to run with busybox-mdev instead of udev.

# For TOPIC employees

If you're in the office, and want to reduce the time it takes to build your
images, create a file `${HOME}/.bitbake-site.conf` with the following contents,
or something similar matching your preferences:
```
# Re-use the build server's hard labour
SSTATE_MIRRORS = "\
	file://.* http://fpga-server.local/share/sstate/PATH \n \
	"
SOURCE_MIRROR_URL = "http://fpga-server.local/sources/"
# Use one set of directories to store sstate-cache and downloads
SSTATE_DIR = "${HOME}/projects/sstate-cache"
DL_DIR = "${HOME}/projects/downloads"
```

# Copying to SD-card

The simplest way to boot the resulting image is to copy it onto an SD card. In case you have not yet formatted and partitioned your SD-card yet, execute the following script first. This script partitions and formats an SD card so it can be used directly. This is only required once.

```
cd ~/my-platform/build
sudo ../meta-topic/scripts/partition_sd_card.sh
```

The meta-topic/scripts/install-to-sd* scripts copy the required files to your SD card. You'll have to run these scripts as root, as they require low-level access to the SD card.

```
# Make sure you run the install script for your device (e.g. "install_to_sd_tdkz30.sh")
cd ~/my-platform/build
sudo ../meta-topic/scripts/install_to_sd_my-tdkz30.sh
```

Alternatively, you can use "dd" to install the WIC image to an SD card. The drawback is that the SD card will only have partitioned enough space to
hold the image and little more, and you cannot use SWUpdate to install new images.


# SWUpdate

The topic-platform based images can be upgraded or replaced with a different image using SWUpdate.

To install a new image, direct a browser to the board's address or name at port 8080, the hostname
defaults to the machine name, so something like this should work:
http://tdkzu9.local:8080/
Select or drag the "swu" image into the installation box to install a new image.

You can also copy the image to a USB stick for example, and install it from the
command line using `swupdate -i <filename>.swu`.

To build an image, build an image whose name matches the target. For example, to
build the swu image that installs itself into emmc, one would:
```bitbake my-image-swu-emmc```

To install images to QSPI, eMMC or SD, the media must be partitioned so that it can be
used for multiple images. The `partition_sd_card.sh` mentioned in the previous chapter already
does that, and it's available on the board itself as well for eMMC and SD.

For convenience, you can also build one of the "init" swu images. These aren't really
images, but they will re-partition and re-format the media and install the bootloader
on it. Bitbake and install "init-swu-qspi" to prepare the QSPI for swu images for example.

The partitioning (using scripts or init images) need only be done once on a device.


# Repository update
This repository contains links to other repositories.
To bring your local copy of the repository up-to-date and fetch
all the sub-repositories along with it, run the following commands:

```
git pull
git submodule update
```

# Development environment setup
Usually you'll be creating your own recipes and defining your new things. Here's
a reasonable cookbook recipe for that.

```
# Create a GIT repository
mkdir my-project
cd my-project
git init .
# Add topic-platform as a submodule
git submodule add http://github.com/topic-embedded-products/topic-platform.git
# Add other submodules, for example meta-dyplo
git submodule add http://github.com/topic-embedded-products/meta-dyplo.git
# Initialize and fetch everything
git submodule update --init --recursive
# Initialize the OE build environment
source topic-platform/oe-core/oe-init-build-env build topic-platform/bitbake
```

After that, you can start adding your own layer and really begin development...

