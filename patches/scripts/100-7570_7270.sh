# 7270-05 firmware on 7570 hardware
isFreetzType 7570_7270 || return 0
[ -z "$FIRMWARE2" ] && error 1 "no tk firmware"

echo1 "adapt firmware for 7570"

warn "(TODO) Copy DSL-firmwre etc?"
files="css/default/images/kopfbalken_mitte.gif"
files+=" html/de/images/kopfbalken.gif"
files+=" html/de/images/DectFBoxIcon.png"
for i in $files; do
	cp -a "${DIR}/.tk/original/filesystem/usr/www/avme/$i" "${FILESYSTEM_MOD_DIR}/usr/www/avme/$i"
done

echo2 "moving default config dir"
# directory name: "Fritz_Box_7270_16" or "Fritz_Box_7270plus"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7270* ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7570

echo2 "patching rc.S and rc.conf"
modsed 's/\(CONFIG_PRODUKT_NAME\)=.*$/\1="FRITZ!Box Fon WLAN 7570 vDSL"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/\(CONFIG_PRODUKT\)=.*$/\1="Fritz_Box_7570"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/\(CONFIG_INSTALL_TYPE\)=.*$/\1="ur8_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_mimo_usb_host_dect_multiannex_13589"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/\(CONFIG_VERSION_MAJOR\)=.*$/\1="75"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# patch install script to accept firmware from 7270 (international), "plus_55266" or "61056"
echo2 "applying install patch"
modsed "s/ur8_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_usb_host_dect_[a-z_0-9]*/ur8_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_mimo_usb_host_dect_multiannex_13589/g" "${FIRMWARE_MOD_DIR}/var/install"
