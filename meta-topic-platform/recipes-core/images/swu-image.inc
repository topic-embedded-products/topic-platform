require swu-revision.inc

SUMMARY ?= "Image for SWUpdate"
SECTION = ""
LICENSE = "CLOSED"

# The version as stored in the sw-description file.
# sw-description is created by including swu.inc in the image
python () {
    import subprocess
    d.setVar('IMAGEVERSION', subprocess.check_output(['git', 'rev-parse', '--verify', 'HEAD']).decode('ascii').rstrip())
}

# Add all local files to be added to the SWU.
# sw-description must always be in the list.
# It can be extended with wathever file is
# needed during the swupdate
SRC_URI = " \
    file://sw-description \
    file://update.sh \
    "

inherit swupdate

# Fix problems with missing manifests for noexec tasks such as
# package_write{deb,ipk,rpm} by removing those tasks entirely.
# Therefore bitbake skips generating dependencies for those
# tasks.
deltask do_package_write_deb
deltask do_package_write_ipk
deltask do_package_write_rpm
deltask do_packagedata
