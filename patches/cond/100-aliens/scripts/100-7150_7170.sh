isFreetzType 7150_7170 || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi
echo1 "adapt firmware for 7150"

echo2 "deleting obsolete files"
rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/microvoip_isdn_top.bit*"

echo2 "copying 7150 files"
cp -a "${FILESYSTEM_TK_DIR}/lib/modules/microvoip_top.bit" "${FILESYSTEM_MOD_DIR}/lib/modules"
cp -a "${FILESYSTEM_TK_DIR}/etc/led.conf" "${FILESYSTEM_MOD_DIR}/etc"
cp -a "${FILESYSTEM_TK_DIR}/lib/modules/pm_info.in" "${FILESYSTEM_MOD_DIR}/lib/modules"

if [ "$FREETZ_REMOVE_TR069" != "y" ]; then
	cp -a "${FILESYSTEM_TK_DIR}/sbin/tr069discover" "${FILESYSTEM_MOD_DIR}/sbin"
fi

if [ "$FREETZ_REMOVE_DECT" != "y" ]; then
	cp -a "${FILESYSTEM_TK_DIR}/bin/dectwe" "${FILESYSTEM_MOD_DIR}/bin"
	cp -a "${FILESYSTEM_TK_DIR}/usr/bin/dect_update" "${FILESYSTEM_MOD_DIR}/usr/bin"
	cp -a "${FILESYSTEM_TK_DIR}/usr/share/ctlmgr/libdect.so" "${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr"
	cp -p ${FILESYSTEM_TK_DIR}/usr/www/avm/html/de/home/dect.* "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/fon"
	cp -p ${FILESYSTEM_TK_DIR}/usr/www/avm/html/de/home/fon1Dect.* "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/fon"
	cp -p ${FILESYSTEM_TK_DIR}/usr/www/avm/html/de/fon/dectmsn.* "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/fon"
	cp -p ${FILESYSTEM_TK_DIR}/usr/www/avm/html/de/fon_config/* "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/fon_config"
fi

echo2 "patching webmenu"
isFreetzType LANG_DE && modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/cond/intro_bar_middle_alien_7170.patch"

if [ isFreetzType LANG_DE -a "$FREETZ_REMOVE_DECT" != "y" ]; then
	echo2 "Add dect sites to webmenu"
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/cond/add_dect1_7170-alien.patch"
fi
isFreetzType LANG_DE && modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/cond/remove_infoled_7170-alien.patch"

echo2 "moving default config dir"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_717* ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7150

echo2 "patching rc.S and rc.conf"

modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Fon 7150\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_7150\"\nexport CONFIG_LED_NO_INFO_LED_KONFIG=\"y\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"ar7_8MB_xilinx_1eth_0ab_pots_isdn_te_usb_host_wlan_dect_57042\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"38\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_HOSTNAME=.*$/CONFIG_HOSTNAME=\"fritz.fon\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_LED_NO_DSL_LED=.*$/CONFIG_LED_NO_DSL_LED=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

modsed "s/CONFIG_ETH_COUNT=.*$/CONFIG_ETH_COUNT=\"1\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/HWRevision_ATA=.*$/HWRevision_ATA=\"1\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_AB_COUNT=.*$/CONFIG_AB_COUNT=\"0\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_DECT=.*$/CONFIG_DECT=\"y\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_FON_HD=.*$/CONFIG_FON_HD=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed "s/CONFIG_CAPI_NT=.*$/CONFIG_CAPI_NT=\"n\"/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

modsed "s/microvoip_isdn_top.bit/microvoip_top.bit/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
modsed "s/isdn_params=\"\"/isdn_params=\"dect_hw=3\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
modsed "s/## DECT/## DECT\nmknod \/var\/flash\/dect_misc c \$tffs_major \$\(\(0xB0\)\)\n\/usr\/bin\/dect_update -g/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

echo1 "patching install script"
if isFreetzType LANG_A_CH ANNEX_A; then
	modsed "s/Fritz_Box_7170_AnnexA/Fritz_Box_7150/g" "${FIRMWARE_MOD_DIR}/var/install"
else
	modsed "s/Fritz_Box_7170/Fritz_Box_7150/g" "${FIRMWARE_MOD_DIR}/var/install"
fi
modsed "s/ar7_8MB_xilinx_4eth_3ab_isdn_nt_te_pots_wlan_usb_host_25762/ar7_8MB_xilinx_1eth_0ab_pots_isdn_te_usb_host_wlan_dect_57042/g" "${FIRMWARE_MOD_DIR}/var/install"
