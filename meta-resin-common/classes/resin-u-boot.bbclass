FILESEXTRAPATHS_append := ":${RESIN_COREBASE}/recipes-bsp/u-boot/patches"

INTEGRATION_KCONFIG_PATCH = "file://resin-specific-env-integration-kconfig.patch"
INTEGRATION_NON_KCONFIG_PATCH = "file://resin-specific-env-integration-non-kconfig.patch"

# Machine independent patches
SRC_URI_append = " \
    file://resin-specific-env-configuration.patch \
    ${@bb.utils.contains('UBOOT_KCONFIG_SUPPORT', '1', '${INTEGRATION_KCONFIG_PATCH}', '${INTEGRATION_NON_KCONFIG_PATCH}', d)} \
    "

python __anonymous() {
    # Use different integration patch based on u-boot Kconfig support
    kconfig_support = d.getVar('UBOOT_KCONFIG_SUPPORT', True)
    if not kconfig_support or (kconfig_support != '0' and kconfig_support != '1'):
        bb.error("UBOOT_KCONFIG_SUPPORT not defined or wrong value. Should be 0 or 1.")
}

RESIN_BOOT_PART = "1"
RESIN_DEFAULT_ROOT_PART = "2"
RESIN_FLASHER_EXTERNAL_FLAG_FILE = ".resin-image-flasher"
RESIN_ENV_FILE = "resinOS_uEnv.txt"

do_generate_resin_uboot_configuration () {
    # RESIN_INTERNAL_MMC is mandatory
    if [ -z "${RESIN_INTERNAL_MMC}" ]; then
        bbfatal "RESIN_INTERNAL_MMC is a mandatory variable. Please define."
    fi

    cat > ${S}/include/config_resin.h <<EOF
#define RESIN_INTERNAL_MMC ${RESIN_INTERNAL_MMC}
#define RESIN_EXTERNAL_MMC ${RESIN_EXTERNAL_MMC}
#define RESIN_BOOT_PART ${RESIN_BOOT_PART}
#define RESIN_DEFAULT_ROOT_PART ${RESIN_DEFAULT_ROOT_PART}
#define RESIN_FLASHER_EXTERNAL_FLAG_FILE ${RESIN_FLASHER_EXTERNAL_FLAG_FILE}
#define RESIN_ENV_FILE ${RESIN_ENV_FILE}
EOF
}
addtask do_generate_resin_uboot_configuration after do_patch before do_configure

do_deploy_append () {
    echo "DO NOT REMOVE THIS FILE" > ${DEPLOYDIR}/${RESIN_FLASHER_EXTERNAL_FLAG_FILE}
}
