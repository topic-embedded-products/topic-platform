Topic Embedded Products BSP for the Miami and Florida boards on top of a Linux distribution. The Miami/Florida BSP is basically a lightweight OpenEmbedded based Linux Distribution, allowing you to easily run your applications on the Miami/Florida. It is based on the mainline Linux distribution as well as the Xilinx supported branch.

# Initial setup

```
git clone http://github.com/topic-embedded-products/topic-platform.git my-platform
cd my-platform
git submodule update --init

meta-topic/scripts/init-oe.sh

cd build

# Edit local.conf to match your setup.
vi conf/local.conf

# To build your BSP it is necessary to set the correct MACHINE environment variable. 
# To do this change it in the "profile" script or just export the MACHINE environment 
# before building. Refer to meta-topic/conf/machine for a list of values 
# (e.g. "topic-miami-florida-gen-xc7z030").

# Then build your first image and relax a bit:
source profile
nice bitbake my-image
````

Note that "my-image" was designed to be used with DISTRO=tiny. It
expects to run with busybox-mdev instead of udev.

# Copying to SD-card

The simplest way to boot the resulting image is to copy it onto an SD card. In case you have not yet formatted and partitioned your SD-card yet, execute the following script first. This script partitions and formats an SD card so it can be used directly. This is only required once.

```
sudo ../meta-topic/scripts/partition-sd-card.sh
```

The meta-topic/scripts/install-to-sd* scripts copy the required files to your SD card. You'll have to run these scripts as root, as they require low-level access to the SD card.

```
# Make sure you run the install script for your device (e.g. "install_to_sd_my-miami-7030.sh")
sudo ../meta-topic/scripts/install_to_sd_my-miami-7030.sh
```

# Update
This repository contains links to other repositories.
To bring your local copy of the repository up-to-date and fetch
all the sub-repositories along with it, run the following commands:

```
git pull
git submodule update
```



