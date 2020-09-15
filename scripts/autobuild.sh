#!/bin/sh -e
if [ ! -d build ]
then
  echo "First time build - creating folders"
  scripts/init-oe.sh
fi
cd build
source ./profile
rm -rf artefacts
mkdir artefacts
for machine in tdkz15 tdkz30 tdkzu6 tdkzu9 tdkzu15 xdpzu7 ttpzu9 tdpzu9
do
  export MACHINE=$machine
  nice bitbake -k my-image-feed
  nice xz -6 < tmp-glibc/deploy/images/${MACHINE}/my-image-${MACHINE}.wic > artefacts/my-image-${MACHINE}.wic.xz &
  cp tmp-glibc/deploy/images/$MACHINE/*-$MACHINE.swu artefacts/
done

# wait for XZ compressors
wait
