# 7570 firmware on Alice IAD 7570 hardware
isFreetzType 7570_IAD || return 0

echo1 "adapt firmware for 7570 IAD"

mv "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7570" "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7570_HN"

modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"Alice IAD 7570 vDSL\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_7570_HN\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"ur8_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_mimo_usb_host_dect_multiannex_hansenet_60170\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"75\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/ur8_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_mimo_usb_host_dect_multiannex_13589/ur8_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_mimo_usb_host_dect_multiannex_hansenet_60170/g" "${FIRMWARE_MOD_DIR}/var/install"

modsed 's/kernel_start=0x90020000/kernel_start=0x90040000/' "${FIRMWARE_MOD_DIR}/var/install"
modsed 's/urlader_size=131072/urlader_size=262144/' "${FIRMWARE_MOD_DIR}/var/install"

if [ "$FREETZ_REPLACE_KERNEL" == "y" -o "$FREETZ_TYPE_7570_7270" == "y" ]; then
	# set mtd1 to 16 MB (244 * 64KB)
	modsed 's/kernel_size=16121856/kernel_size=15990784/' "${FIRMWARE_MOD_DIR}/var/install"
	if isFreetzType 7570_7270; then
		warn "(TODO): New install-7570_HN.patch required?"
	else
		modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_COND_DIR}/install-7570_HN.patch"
	fi
else
	# use only 8 MB (122 * 64 KB)
	modsed 's/kernel_size=16121856/kernel_size=7995392/' "${FIRMWARE_MOD_DIR}/var/install"
fi
