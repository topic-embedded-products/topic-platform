DESCRIPTION = "Scripts to prepare filesystems on UBI and MMC"
LICENSE = "CLOSED"

# To create partition tables and ext4 filesystems:
RDEPENDS:${PN} += "parted e2fsprogs-mke2fs"
# To create ubi structures
RDEPENDS:${PN} += "mtd-utils-ubifs"

SRC_URI = "\
	file://prepare_filesystem \
	file://init_ubi \
	file://partition_sd_card.sh \
	"

do_install() {
	install -d ${D}${sbindir}
	install -m 0755 ${WORKDIR}/prepare_filesystem ${D}${sbindir}
	install -m 0755 ${WORKDIR}/init_ubi ${D}${sbindir}
	install -m 0755 ${WORKDIR}/partition_sd_card.sh ${D}${sbindir}/partition_sd_card
}
