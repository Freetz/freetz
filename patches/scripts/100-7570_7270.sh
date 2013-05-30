isFreetzType 7570_7270 7570_IAD W920V_7570 || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

echo1 "adapt firmware for 7570"

#TODO!!!
#files="css/default/images/kopfbalken_mitte.gif"
#files+=" html/de/images/kopfbalken.gif"
#files+=" html/de/images/DectFBoxIcon.png"
for i in $files; do
	cp -a "${DIR}/.tk/original/filesystem/usr/www/avme/$i" "${FILESYSTEM_MOD_DIR}/usr/www/avme/$i"
done

echo2 "moving default config dir"
#mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7270_16 ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7570
#mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7270plus ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7570
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7270* ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7570

echo2 "patching rc.S and rc.conf"
#TODO!!!
#modsed "s/CONFIG_AUDIO=.*$/CONFIG_AUDIO=\"y\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed "s/CONFIG_CAPI_POTS=.*$/CONFIG_CAPI_POTS=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed "s/CONFIG_CODECS_IN_PCMROUTER=.*$/CONFIG_CODECS_IN_PCMROUTER=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed "s/CONFIG_DSL_UR8=.*$/CONFIG_DSL_UR8=\"y\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed "s/CONFIG_DSL_MULTI_ANNEX=.*$/CONFIG_DSL_MULTI_ANNEX=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"mips34_16MB_dect441_2eth_1ab_2usb_host_wlan11n_37273\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed "s/CONFIG_MEDIACLI=.*$/CONFIG_MEDIACLI=\"y\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_7320\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Fon WLAN 7320\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"100\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed "s/GCOV_PREFIX_STRIP=.*$/GCOV_PREFIX_STRIP=\"3\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# patch install script to accept firmware from 7270 (international)
echo2 "applying install patch"
modsed "s/ur8_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_usb_host_dect_plus_55266/ur8_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_mimo_usb_host_dect_multiannex_13589/g" "${FIRMWARE_MOD_DIR}/var/install"
modsed "s/ur8_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_usb_host_dect_61056/ur8_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_mimo_usb_host_dect_multiannex_13589/g" "${FIRMWARE_MOD_DIR}/var/install"
