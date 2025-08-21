#!/bin/sh -e
git submodule update --init --recursive
if [ ! -d build ]
then
  echo "First time build - creating folders"
  scripts/init-oe.sh
fi
VERSION=`git rev-parse --short HEAD`
cd build
source ./profile
rm -rf artefacts artefacts-nv
mkdir artefacts
mkdir artefacts-nv
for machine in tdkz15 tdkz30 tepzu9 tdpzu9 ttpzu9 tdkzu6 tdkzu9 tdkzu15
do
  export MACHINE=$machine
  nice bitbake -k my-image-feed
  nice xz -6 < tmp-glibc/deploy/images/${MACHINE}/my-image-${MACHINE}.rootfs.wic > artefacts-nv/my-image-${MACHINE}.wic.xz &
  cp -l tmp-glibc/deploy/images/${MACHINE}/*-${MACHINE}.rootfs.swu artefacts-nv/
done

# wait for XZ compressors
wait

for ext in wic.xz swu
do
  for a in artefacts-nv/*.${ext}
  do
    b=`basename "${a}" .${ext}`
    ln "${a}" "artefacts/${b}+${VERSION}.${ext}"
  done
done
cd ..

if [ ! -d build-x11 ]
then
  echo "First time build - creating folders"
  scripts/init-oe.sh build-x11
fi
cd build-x11
# Configure for X11
echo 'DISTRO = "topic-x11"' > conf/site.conf
rm -rf artefacts artefacts-nv
ln -s ../build/artefacts artefacts
mkdir artefacts-nv
for machine in tdkz15 tdkz30 tepzu9 tdkzu6 tdkzu9 tdkzu15
do
  export MACHINE=$machine
  nice bitbake -k my-image-sato-ro-swu-mmcblk0
  cp -l tmp-glibc/deploy/images/${MACHINE}/*-${MACHINE}.rootfs.swu artefacts-nv/
done

for ext in swu
do
  for a in artefacts-nv/*.${ext}
  do
    b=`basename "${a}" .${ext}`
    ln "${a}" "artefacts/${b}+${VERSION}.${ext}"
  done
done
cd ..

# Only build wayland for machines that have a GPU. This is only done to fill
# the sstate-cache
if [ ! -d build-wayland ]
then
  echo "First time build - creating folders"
  scripts/init-oe.sh build-wayland
fi
cd build-wayland
# Configure for wayland
echo 'DISTRO = "topic-wayland"' > conf/site.conf
rm -rf artefacts artefacts-nv
ln -s ../build/artefacts artefacts
mkdir artefacts-nv
for machine in tepzu9 tdkzu9
do
  export MACHINE=$machine
  nice bitbake -k my-image-sato-ro-swu-mmcblk0 weston wayland
done
cd ..
