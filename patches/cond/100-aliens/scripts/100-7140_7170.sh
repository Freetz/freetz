# 7170 firmware on 7140 hardware
isFreetzType 7140_7170 || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

echo1 "adapt firmware for 7140"

echo2 "copying 7140 files"
cp -a "${DIR}/.tk/original/filesystem/lib/modules/microvoip_isdn_top.bit" "${FILESYSTEM_MOD_DIR}/lib/modules"

echo2 "deleting obsolete files"
rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/microvoip_isdn_top.bit1"

echo2 "patching webmenu"
isFreetzType LANG_DE && \
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/cond/intro_bar_middle_alien_7170.patch"
#modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/install/install-7140_7170.patch"

echo2 "moving default config dir"
if isFreetzType ANNEX_A; then
	mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_717* "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7140_AnnexA" || exit 2
else
	mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_717* "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7140" || exit 2
fi

echo2 "patching rc.S and rc.conf"

modsed "s/piglet_bitfile_offset=0/piglet_bitfile_offset=0x4d/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

modsed "s/CONFIG_AB_COUNT=.*$/CONFIG_AB_COUNT=\"2\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_CAPI_NT=.*$/CONFIG_CAPI_NT=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"ar7_8MB_xilinx_4eth_2ab_isdn_te_pots_wlan_usb_host_62068\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

if isFreetzType ANNEX_A; then
	modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Fon WLAN 7140 Annex A\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
	modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_7140_AnnexA\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
	modsed "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"39\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
	modsed "s/HWRevision_ATA=.$/HWRevision_ATA=0/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
else
	modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Fon WLAN 7140\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
	modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_7140\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
	modsed "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"30\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
	modsed "s/HWRevision_ATA=0$/HWRevision_ATA=1/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
fi
#modsed "s/CONFIG_TR064=.*$/CONFIG_TR064=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed "s/CONFIG_VPN=.*$/CONFIG_VPN=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# patch install script to accept firmware from 7170
echo1 "applying install patch"
if isFreetzType ANNEX_A; then
	modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/install/install-7140_7170_Annex_A.patch" || exit 2
else
	modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/install/install-7140_7170.patch" || exit 2
fi

