#!/bin/sh
set -e
if [ ! -z "$1" ]
then
  BUILDDIR="$1"
else
  BUILDDIR=build
fi
if [ `readlink /bin/sh` = dash ]
then
	echo "Your shell is set to 'dash', this will cause lots of troubles. See:"
	echo "http://www.openembedded.org/wiki/OEandYourDistro"
	echo "Please run this and answer 'No' when asked to set dash as the default shell:"
	echo "sudo dpkg-reconfigure dash"
	exit 1
fi
if [ ! -d oe-core ]
then
	echo "Please run this as './scripts/init-oe.sh' from the top directory."
	exit 1
fi
if [ ! -e oe-core/.git ]
then
	git submodule init
	git submodule update --init --recursive
fi
if [ ! -d ${BUILDDIR}/conf ]
then
	mkdir -p ${BUILDDIR}/conf
fi
# local.conf must be a symbolic link
if [ ! -h ${BUILDDIR}/conf/local.conf ]
then
	# Remove existing links, if any
	rm -f ${BUILDDIR}/conf/bblayers.conf ${BUILDDIR}/profile ${BUILDDIR}/conf/local.conf
	# Make symlinks so they are under version control
	ln -s ../../scripts/templates/build/conf/bblayers.conf ${BUILDDIR}/conf/bblayers.conf
	ln -s ../scripts/templates/build/profile ${BUILDDIR}/profile
	ln -s ../../scripts/templates/build/conf/local.conf ${BUILDDIR}/conf/local.conf
fi
cd oe-core
source ./oe-init-build-env ../${BUILDDIR} ../bitbake

echo "-------------------------------------------------------------"
echo "You might need to install extra packages, if you haven't"
echo "already done so. Please see the manual."
echo "-------------------------------------------------------------"
echo "Initialization complete!"
echo ""
echo "First, EDIT build/conf/local.conf to match your system."
echo "See the manual on how to build an image."
