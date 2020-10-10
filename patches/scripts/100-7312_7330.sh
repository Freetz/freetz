isFreetzType 7312_7330 || return 0
echo1 "adapt firmware for 7312"

echo2 "moving default config dir"
isFreetzType 7312_7330_XL && defdir=7322
isFreetzType 7312_7330_SL && defdir=HW188
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_${defdir} \
   ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_HW189

echo2 "patching rc.S and rc.conf"
modsed 's/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE="mips34_16MB_dect441_1eth_1ab_wlan11n_40508"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT="Fritz_Box_HW189"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME="FRITZ!Box 7312"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR="117"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_ETH_COUNT=.*$/CONFIG_ETH_COUNT="1"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# patch install script to accept firmware from 7330
echo2 "applying install patch"
isFreetzType 7312_7330_XL && modsed "s/mips34_16MB_dect441_1eth_1geth_1ab_pots_2usb_host_wlan11n_41167/mips34_16MB_dect441_1eth_1ab_wlan11n_40508/g" "${FIRMWARE_MOD_DIR}/var/install"
isFreetzType 7312_7330_SL && modsed "s/mips34_16MB_dect441_1eth_1geth_1ab_2usb_host_wlan11n_01118/mips34_16MB_dect441_1eth_1ab_wlan11n_40508/g" "${FIRMWARE_MOD_DIR}/var/install"
