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
if [ -d project-spec ]
then
	echo "Setting up for petalinux"
	for LAYER in meta-swupdate meta-topic meta-topic-platform
	do
		if ! grep -q "\${proot}/topic-platform/${LAYER}" "project-spec/configs/config"
		then
			echo "${LAYER} not setup"		
			echo "Please add topic platform to petalinux repos in 'project-spec/configs/config': "
			echo "CONFIG_USER_LAYER_0=\"\${proot}/project-spec/meta-user\""
			echo "CONFIG_USER_LAYER_1=\"\${proot}/topic-platform/meta-swupdate\""
			echo "CONFIG_USER_LAYER_2=\"\${proot}/topic-platform/meta-topic\""
			echo "CONFIG_USER_LAYER_3=\"\${proot}/topic-platform/meta-topic-platform\""
      echo "CONFIG_USER_LAYER_4=\"\${proot}/topic-platform/meta-xilinx/meta-xilinx-standalone\""
			echo "CONFIG_USER_LAYER_5=\"\""
			exit 1
		fi
	done
	echo "Run petalinux-build to build your design"
	exit 0
fi
if [ ! -d oe-core ]
then
	echo "Please run this as './scripts/init-oe.sh' from the top directory."
	echo "or if petalinux run this as './topic-platform/scripts/init-oe.sh' from the top directory."
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
if [ ! -f ${BUILDDIR}/conf/local.conf ]
then
	cp -rp scripts/templates/build/* ${BUILDDIR}/
	# Make bblayers.conf a symlink so it's under version control
	rm ${BUILDDIR}/conf/bblayers.conf
	ln -s ../../scripts/templates/build/conf/bblayers.conf ${BUILDDIR}/conf/bblayers.conf
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
