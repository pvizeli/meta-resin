DESCRIPTION = "RESIN Host os UPdater"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${RESIN_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = "file://resinhup"
S = "${WORKDIR}"

inherit allarch

FILES_${PN} = "${bindir}"

RDEPENDS_${PN} = " \
    bash \
    busybox \
    coreutils \
    docker \
    e2fsprogs-tune2fs \
    jq \
    systemd \
    "

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/resinhup ${D}${bindir}

    sed -i -e 's:@MACHINE@:${HASSIO_MACHINE}:g' ${D}${bindir}/resinhup
    sed -i -e 's:@RESINOS_HASSIO_VERSION@:${RESINOS_HASSIO_VERSION}:g' ${D}${bindir}/resinhup
}
