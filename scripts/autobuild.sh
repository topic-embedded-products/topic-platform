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
for machine in tdkz15 tdkz30 tdkz10 tdkzu6 tdkzu9 tdkzu15 xdpzu7 ttpzu9 tdpzu9
do
  export MACHINE=$machine
  nice bitbake -k my-image-feed
  nice xz -6 < tmp-glibc/deploy/images/${MACHINE}/my-image-${MACHINE}.wic > artefacts-nv/my-image-${MACHINE}.wic.xz &
  cp tmp-glibc/deploy/images/$MACHINE/*-$MACHINE.swu artefacts-nv/
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
