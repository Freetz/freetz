isFreetzType W920V_7570 || isFreetzType SPEEDPORT_W920V_LED_MODULE || return 0

if isFreetzType W920V_7570; then
	echo1 "adapt firmware for W920V"
	echo2 "moving default config dir"
	mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7570 ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_DECT_W920V

	echo2 "patching rc.conf"
	modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Fon Speedport W 920V\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
	modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_DECT_W920V\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
	modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"ur8_8MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_mimo_usb_host_dect_40456\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
	modsed "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"65\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
fi

if isFreetzType SPEEDPORT_W920V_LED_MODULE; then
	echo1 "changing LED semantics to W920V"
	cp -a "${DIR}/.tk/original/filesystem/lib/modules/2.6.19.2/kernel/drivers/char/led_module.ko" "${FILESYSTEM_MOD_DIR}/lib/modules/2.6.19.2/kernel/drivers/char/led_module.ko"
fi
