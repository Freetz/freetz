isFreetzType 7320_7330 || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

echo1 "adapt firmware for 7320"

files="css/default/images/kopfbalken_mitte.gif"
if [ "$FREETZ_AVM_HAS_ONLY_LUA" != "y" ]; then
	files+=" html/de/images/kopfbalken.gif"
	files+=" html/de/images/DectFBoxIcon.png"
fi
for i in $files; do
	cp -a "${FILESYSTEM_TK_DIR}/usr/www/avm/$i" "${HTML_LANG_MOD_DIR}/$i"
done

echo2 "moving default config dir"
isFreetzType 7320_7330_XL && defdir=7322
isFreetzType 7320_7330_SL && defdir=HW188
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_${defdir} \
   ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7320

echo2 "patching rc.S and rc.conf"
modsed "s/CONFIG_AUDIO=.*$/CONFIG_AUDIO=\"y\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_CAPI_POTS=.*$/CONFIG_CAPI_POTS=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_CODECS_IN_PCMROUTER=.*$/CONFIG_CODECS_IN_PCMROUTER=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_DSL_UR8=.*$/CONFIG_DSL_UR8=\"y\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_DSL_MULTI_ANNEX=.*$/CONFIG_DSL_MULTI_ANNEX=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"mips34_16MB_dect441_2eth_1ab_2usb_host_wlan11n_37273\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_MEDIACLI=.*$/CONFIG_MEDIACLI=\"y\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_7320\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Fon WLAN 7320\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"100\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/GCOV_PREFIX_STRIP=.*$/GCOV_PREFIX_STRIP=\"3\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# patch install script to accept firmware from 7330
echo2 "applying install patch"
isFreetzType 7320_7330_XL && modsed "s/mips34_16MB_dect441_1eth_1geth_1ab_pots_2usb_host_wlan11n_41167/mips34_16MB_dect441_2eth_1ab_2usb_host_wlan11n_37273/g" "${FIRMWARE_MOD_DIR}/var/install"
isFreetzType 7320_7330_SL && modsed "s/mips34_16MB_dect441_1eth_1geth_1ab_2usb_host_wlan11n_01118/mips34_16MB_dect441_2eth_1ab_2usb_host_wlan11n_37273/g" "${FIRMWARE_MOD_DIR}/var/install"
