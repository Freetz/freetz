[ "$FREETZ_TYPE_3170_7170" == "y" ] || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi
echo1 "adapt firmware for 3170"

echo2 "copying 3170 files"
cp "${DIR}/.tk/original/filesystem/lib/modules/microvoip_isdn_top.bit" "${FILESYSTEM_MOD_DIR}/lib/modules"

echo2 "deleting obsolete files"
rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/microvoip_isdn_top.bit1"
for i in bin/mini* bin/reinit_jffs2 bin/showvoipdstat bin/telephon.plugin bin/voip* etc/init.d/rc.voip etc/minid \
	lib/libcapi* lib/libfon* lib/libmscodex* lib/libosip* lib/libphone* lib/librtp* lib/libsip* lib/libspeex* \
	lib/libavmaudio* lib/libconverttopdf* lib/libavcodec* lib/libavformat* lib/libmedia* lib/libpop3* \
	lib/modules/2.6.13.1-ohio/kernel/drivers/char/audio lib/modules/2.6.13.1-ohio/kernel/drivers/isdn \
	lib/modules/2.6.13.1-ohio/kernel/drivers/net/rfcntl lib/modules/2.6.13.1-ohio/kernel/fs/jffs2 \
	lib/modules/2.6.13.1-ohio/kernel/fs/isofs  usr/bin/capiotcp_server usr/bin/faxd usr/bin/pbd usr/bin/resettam \
	usr/share/tam usr/share/telefon usr/share/ctlmgr/libfon.so usr/share/ctlmgr/libmini.so \
	usr/share/ctlmgr/libtamconf.so usr/share/ctlmgr/libtelcfg.so; do
	rm_files "${FILESYSTEM_MOD_DIR}/$i"
done

#echo2 "patching webmenu"
#modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/3170_7170.patch"

echo2 "moving default config dir, creating tcom and congstar symlinks"
mv "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7170" "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_3170"

echo2 "patching rc.S and rc.conf"

modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/rc.S-3170_7170.patch" || exit 2

sed -i -e "s/piglet_bitfile_offset=0/piglet_bitfile_offset=0x4b/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

sed -i -e "s/CONFIG_HOSTNAME=.*$/CONFIG_HOSTNAME=\"fritz.box\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

sed -i -e "s/CONFIG_FON=.*$/CONFIG_FON=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_FONBOOK2=.*$/CONFIG_FONBOOK2=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_T38=.*$/CONFIG_T38=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_AUDIO=.*$/CONFIG_AUDIO=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_CAPI_POTS=.*$/CONFIG_CAPI_POTS=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_CAPI_TE=.*$/CONFIG_CAPI_TE=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_FAXSUPPORT=.*$/CONFIG_FAXSUPPORT=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_JFFS2=.*$/CONFIG_JFFS2=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_FAX2MAIL=.*$/CONFIG_FAX2MAIL=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_FON_HD=.*$/CONFIG_FON_HD=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_TAM=.*$/CONFIG_TAM=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_TAM_MODE=.*$/CONFIG_TAM_MODE=\"0\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_CAPI=.*$/CONFIG_CAPI=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_ROMSIZE=.*$/CONFIG_ROMSIZE=\"4\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_MINI=.*$/CONFIG_MINI=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_AB_COUNT=.*$/CONFIG_AB_COUNT=\"0\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_CAPI_NT=.*$/CONFIG_CAPI_NT=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"49\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box WLAN 3170\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_3170\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"ar7_4MB_4eth_wlan_avm_usb_host_28881\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/HWRevision_ATA=0$/HWRevision_ATA=1/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

#sed -i -e "s/CONFIG_TR064=.*$/CONFIG_TR064=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#sed -i -e "s/CONFIG_VPN=.*$/CONFIG_VPN=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"


# patch install script to accept firmware from 7170
echo1 "applying install patch"
modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_DIR}/cond/install-3170_7170.patch" || exit 2
