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

# To build your BSP it is necessary to set the correct MACHINE environment variable. To do this change it in the
# "profile" script or just export the MACHINE environment before building. Refer to meta-topic/conf/machine for a list of values.

# Then build your first image and relax a bit:
source profile
nice bitbake my-image
````

Note that "my-image" was designed to be used with DISTRO=tiny. It
expects to run with busybox-mdev instead of udev.

# Update
This repository contains links to other repositories.
To bring your local copy of the repository up-to-date and fetch
all the sub-repositories along with it, run the following commands:

```
git pull
git submodule update
```



