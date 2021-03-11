isFreetzType 1759_1750 || return 0
echo1 "adapt firmware for DVB-c"


echo2 "moving default config dir"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_HW206 \
   ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_HW205

echo2 "patching rc.S and rc.conf"
#modsed 's/CONFIG_USB_HOST_INTERNAL=.*$/CONFIG_USB_HOST_INTERNAL="y"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"  #USB?
#modsed 's/CONFIG_LINEARTV=.*$/CONFIG_LINEARTV="y"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"                    #DVB?
modsed 's/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE="mips74_16MB_1eth_wlan11n_repeater_dvbc_05417"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT="Fritz_Box_HW205"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME="FRITZ!WLAN Repeater DVB-C"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR="133"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# patch install script to accept firmware from 1750E
echo2 "applying install patch"
modsed "s/mips74_16MB_1eth_wlan11ac_repeater_24750/mips74_16MB_1eth_wlan11n_repeater_dvbc_05417/g" "${FIRMWARE_MOD_DIR}/var/install"

