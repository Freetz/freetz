# 7270_v2 firmware on 7270_v1 hardware
isFreetzType 7270_7270 || return 0

echo1 "adapt firmware for 7270v1"

echo2 "moving default config dir"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7270_16 ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7270

modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Fon WLAN 7270 v1\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_7270\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_ROM_SIZE=.*$/CONFIG_ROM_SIZE=\"8\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"ur8_8MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_usb_host_dect_05265\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# patch install script to accept firmware from 7270 v2
echo2 "applying install patch"
modsed "s/ur8_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_usb_host_dect_61056/ur8_8MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_usb_host_dect_05265/g" "${FIRMWARE_MOD_DIR}/var/install"
modsed 's/kernel_start=0x90020000/kernel_start=0x90010000/' "${FIRMWARE_MOD_DIR}/var/install"
modsed 's/kernel_size=16121856/kernel_size=7798784/' "${FIRMWARE_MOD_DIR}/var/install"
modsed 's/urlader_size=131072/urlader_size=65536/' "${FIRMWARE_MOD_DIR}/var/install"
