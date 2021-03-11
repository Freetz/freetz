# 7170 firmware on 3170 hardware
isFreetzType 3170_7170 || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi
echo1 "adapt firmware for 3170"

echo2 "copying 3170 files"
cp -a "${DIR}/.tk/original/filesystem/lib/modules/microvoip_isdn_top.bit" "${FILESYSTEM_MOD_DIR}/lib/modules"

echo2 "deleting obsolete files"
rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/microvoip_isdn_top.bit1"
for i in \
  bin/reinit_jffs2 etc/init.d/rc.voip etc/minid \
  lib/libmscodex* lib/libphone* lib/libspeex* \
  lib/libavmaudio* lib/libconverttopdf* lib/libmedia* \
  lib/modules/2.6.13.1-ohio/kernel/drivers/char/audio \
  lib/modules/2.6.13.1-ohio/kernel/drivers/net/rfcntl \
  lib/modules/2.6.13.1-ohio/kernel/fs/jffs2 \
  lib/modules/2.6.13.1-ohio/kernel/fs/isofs \
  usr/bin/faxd usr/bin/resettam \
  usr/share/tam usr/share/telefon usr/share/ctlmgr/libtamconf.so \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$i"
done

echo2 "patching webmenu"
isFreetzType LANG_DE && modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/cond/intro_bar_middle_alien_7170.patch"

echo2 "moving default config dir"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_717* ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_3170

echo2 "patching rc.S and rc.conf"
SCRIPTPATCHER="${TOOLS_DIR}/scriptpatcher.sh"
RC_S_FILE="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

${SCRIPTPATCHER} -fdi ${RC_S_FILE} -s "copy_telefonie_defaults" -o ${RC_S_FILE}
${SCRIPTPATCHER} -fdi ${RC_S_FILE} -s "link_telefonie_defaults" -o ${RC_S_FILE}

if isFreetzType LANG_DE; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/rc.S/rc.S-3170_7170_de_Annex_B.patch" || exit 2
elif isFreetzType LANG_EN ANNEX_B; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/rc.S/rc.S-3170_7170_en_Annex_B.patch" || exit 2
elif isFreetzType LANG_A_CH || isFreetzType LANG_EN ANNEX_A; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/rc.S/rc.S-3170_7170_Annex_A.patch" || exit 2
fi

modsed "s/piglet_bitfile_offset=0/piglet_bitfile_offset=0x4b/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

modsed "s/CONFIG_HOSTNAME=.*$/CONFIG_HOSTNAME=\"fritz.box\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

modsed "s/CONFIG_FON=.*$/CONFIG_FON=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_FONGUI2=.*$/CONFIG_FONGUI2=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_FON_IPPHONE=.*$/CONFIG_FON_IPPHONE=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_FONQUALITY=.*$/CONFIG_FONQUALITY=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_FONBOOK2=.*$/CONFIG_FONBOOK2=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_T38=.*$/CONFIG_T38=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_AUDIO=.*$/CONFIG_AUDIO=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_CAPI_POTS=.*$/CONFIG_CAPI_POTS=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_CAPI_TE=.*$/CONFIG_CAPI_TE=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_FAXSUPPORT=.*$/CONFIG_FAXSUPPORT=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_JFFS2=.*$/CONFIG_JFFS2=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_FAX2MAIL=.*$/CONFIG_FAX2MAIL=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_FON_HD=.*$/CONFIG_FON_HD=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_TAM=.*$/CONFIG_TAM=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_TAM_MODE=.*$/CONFIG_TAM_MODE=\"0\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_CAPI=.*$/CONFIG_CAPI=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_ROMSIZE=.*$/CONFIG_ROMSIZE=\"4\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_MINI=.*$/CONFIG_MINI=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_AB_COUNT=.*$/CONFIG_AB_COUNT=\"0\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_CAPI_NT=.*$/CONFIG_CAPI_NT=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"49\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box WLAN 3170\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_3170\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"ar7_4MB_4eth_wlan_avm_usb_host_28881\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/HWRevision_ATA=0$/HWRevision_ATA=1/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

#modsed "s/CONFIG_TR064=.*$/CONFIG_TR064=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed "s/CONFIG_VPN=.*$/CONFIG_VPN=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"


# patch install script to accept firmware from 7170
echo1 "applying install patch"
if isFreetzType LANG_DE || isFreetzType ANNEX_B; then
	modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/install/install-3170_7170.patch" || exit 2
else
	modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/install/install-3170_7170_a_ch.patch" || exit 2
fi

