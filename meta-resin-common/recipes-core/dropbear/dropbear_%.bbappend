FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://dropbear.socket \
    file://ssh.service \
    file://dropbearkey.conf \
    file://sync-authorized-keys \
    file://sync-authorized-keys.service \
    "

# starting with dropbear version 2016.73, code indentation has been fixed thus making our current patch (use_atomic_key_generation_in_all_cases.patch) not work anymore
# we work around this by detecting the dropbear version and applying the right patch for it
python() {
    packageVersion = d.getVar('PV', True)
    srcURI = d.getVar('SRC_URI', True)
    if packageVersion >= '2016.73':
        d.setVar('SRC_URI', srcURI + ' ' + 'file://use_atomic_key_generation_in_all_cases_reworked.patch')
    else:
        d.setVar('SRC_URI', srcURI + ' ' + 'file://use_atomic_key_generation_in_all_cases.patch')
}

FILES_${PN} += " \
    /home \
    ${systemd_unitdir} \
    ${bindir} \
    "

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE_${PN} += " \
    dropbearkey.service \
    sync-authorized-keys.service \ 
    "

do_install_append() {
    # Disable password logins
    install -d ${D}${sysconfdir}/default
    echo 'DROPBEAR_EXTRA_ARGS="-s"' >> ${D}/etc/default/dropbear
    echo 'DROPBEAR_PORT="22222"' >> ${D}/etc/default/dropbear # Change default dropbear port to 22222

    # Advertise SSH service using an avahi service file
    mkdir -p ${D}/etc/avahi/services/
    install -m 0644 ${WORKDIR}/ssh.service ${D}/etc/avahi/services

    install -d ${D}/home/root/.ssh
    install -d ${D}${bindir}

    install -m 0755 ${WORKDIR}/sync-authorized-keys ${D}${bindir}

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${sysconfdir}/systemd/system/dropbearkey.service.d
        install -c -m 0644 ${WORKDIR}/dropbearkey.conf ${D}${sysconfdir}/systemd/system/dropbearkey.service.d

        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/sync-authorized-keys.service ${D}${systemd_unitdir}/system

        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
            -e 's,@SBINDIR@,${sbindir},g' \
            -e 's,@BINDIR@,${bindir},g' \
            ${D}${systemd_unitdir}/system/*.service
    fi

}
do_install[vardeps] += "DISTRO_FEATURES RESIN_CONNECTABLE_ENABLE_SERVICES"
