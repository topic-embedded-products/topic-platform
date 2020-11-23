SWU_BOARD ?= "${MACHINE}"
SWU_HWREVISION ?= "0"
SWU_BOARD_HWREVISION ?= "${SWU_BOARD} ${SWU_HWREVISION}"

# The version as stored in the sw-description file.
# sw-description is created by including swu.inc in the image
python () {
    import subprocess
    d.setVar('IMAGEVERSION', subprocess.check_output(['git', 'rev-parse', '--verify', 'HEAD']).decode('ascii').rstrip())
}
