isFreetzType 7340_7390 || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

echo1 "adapt firmware for 7390"

echo2 "deleting obsolete files"
rm_files ${FILESYSTEM_MOD_DIR}/lib/modules/bitfile.bit

echo2 "copying 7340 files"
files="bitfile_isdn.bit bitfile_pots.bit"

for i in $files; do
	cp -a "${DIR}/.tk/original/filesystem/lib/modules/$i" "${FILESYSTEM_MOD_DIR}/lib/modules/$i"
done

files="css/default/images/kopfbalken_mitte.gif"
files+=" html/de/images/kopfbalken.gif"
files+=" html/de/images/DectFBoxIcon.png"
for i in $files; do
	cp -a "${DIR}/.tk/original/filesystem/usr/www/avme/$i" "${FILESYSTEM_MOD_DIR}/usr/www/avme/$i"
done

echo2 "moving default config dir"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7390 ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7340

echo2 "patching rc.conf"
modsed "s/CONFIG_ETH_COUNT=.*$/CONFIG_ETH_COUNT=\"2\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_JFFS2=.*$/CONFIG_JFFS2=\"y\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_NAND=.*$/CONFIG_NAND=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_YAFFS2=.*$/CONFIG_YAFFS2=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_CAPI_NT=.*$/CONFIG_CAPI_NT=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"iks_16MB_xilinx_2eth_2ab_isdn_te_pots_wlan_usb_host_dect_63350\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_7340\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Fon WLAN 7340\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"99\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# patch loading of bitfile
if isFreetzType LANG_EN; then
	modsed "s/bitfile.bit/bitfile_isdn.bit/" "${FILESYSTEM_MOD_DIR}/etc/init.d/S17-isdn"
	modsed 's#^\(modprobe Piglet_noemif.*\)#\1 piglet_potsbitfile=/lib/modules/bitfile_pots\.bit\${HWRevision_BitFileCount} piglet_bitfilemode=`/bin/testvalue /var/flash/telefon_misc 4 2638`#g' \
	  "${FILESYSTEM_MOD_DIR}/etc/init.d/S17-isdn"
fi

# patch install script to accept firmware from 7390
echo2 "applying install patch"
modsed "s/iks_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_usb_host_dect_64415/iks_16MB_xilinx_2eth_2ab_isdn_te_pots_wlan_usb_host_dect_63350/g" "${FIRMWARE_MOD_DIR}/var/install"
