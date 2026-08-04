DESCRIPTION = "Scripts to prepare filesystems on UBI and MMC"
LICENSE = "CLOSED"

# To create partition tables and ext4 filesystems:
RDEPENDS_${PN} += "parted e2fsprogs-mke2fs"
# To create ubi structures
RDEPENDS:${PN} += "mtd-utils-ubifs"
# to be able to update a live rootfs
RDEPENDS:${PN} += "kexec"

SRC_URI = "\
	file://prepare_filesystem \
	file://init_ubi \
	file://partition_sd_card.sh \
	"

S = "${UNPACKDIR}"

do_install() {
	install -d ${D}${sbindir}
	install -m 0755 ${S}/prepare_filesystem ${D}${sbindir}
	install -m 0755 ${S}/init_ubi ${D}${sbindir}
	install -m 0755 ${S}/partition_sd_card.sh ${D}${sbindir}/partition_sd_card
}
