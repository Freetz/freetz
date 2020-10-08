isFreetzType 3390_3490 || return 0
echo1 "adapt firmware for 3390"


echo2 "moving default config dir"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_HW212 \
   ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_HW193

echo2 "patching rc.S and rc.conf"
modsed 's/CONFIG_USB_XHCI=.*$/CONFIG_USB_XHCI="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE="mips34_128MB_vdsl_4geth_2usb_host_wlan11n_30877"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT="Fritz_Box_HW193"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME="FRITZ!Box 3390"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR="121"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# patch install script to accept firmware from 3490
echo2 "applying install patch"
modsed "s/mips34_512MB_vdsl_4geth_2usb_host_offloadwlan11n_17525/mips34_128MB_vdsl_4geth_2usb_host_wlan11n_30877/g" "${FIRMWARE_MOD_DIR}/var/install"

