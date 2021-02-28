isFreetzType 7520_7530 || return 0
echo1 "adapt firmware for 7520"


echo2 "moving default config dir"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_HW236 \
   ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_HW247

echo2 "patching rc.S and rc.conf"
#modsed 's/CONFIG_USB_XHCI=.*$/CONFIG_USB_XHCI="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf" #	USB3?
modsed 's/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE="arm_128MB_cortexa9_2geth_usb_host_2wlan11n_dect_vdsl_02249"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT="Fritz_Box_HW247"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME="FRITZ!Box 7520"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR="175"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# patch install script to accept firmware from 7530
echo2 "applying install patch"
modsed "s/arm_32MB_cortexa9_plc_1geth_wlan11n_Dect_vdsl_63849/arm_128MB_cortexa9_2geth_usb_host_2wlan11n_dect_vdsl_02249/g" "${FIRMWARE_MOD_DIR}/var/install"

