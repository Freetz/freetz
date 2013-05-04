isFreetzType 7320_7330 || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

echo1 "adapt firmware for 7320"

files="css/default/images/kopfbalken_mitte.gif"
files+=" html/de/images/kopfbalken.gif"
files+=" html/de/images/DectFBoxIcon.png"
for i in $files; do
	cp -a "${DIR}/.tk/original/filesystem/usr/www/avm/$i" "${FILESYSTEM_MOD_DIR}/usr/www/avm/$i"
done

echo2 "moving default config dir"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7322 ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7320

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
modsed "s/mips34_16MB_dect441_1eth_1geth_1ab_pots_2usb_host_wlan11n_41167/mips34_16MB_dect441_2eth_1ab_2usb_host_wlan11n_37273/g" "${FIRMWARE_MOD_DIR}/var/install"
