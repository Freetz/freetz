isFreetzType 7240_7270 || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

echo1 "adapt firmware for 7240"

echo2 "deleting obsolete files"
rm_files ${FILESYSTEM_MOD_DIR}/lib/modules/bitfile.bit

echo2 "copying 7240 files"
for i in bitfile_isdn.bit bitfile_pots.bit c55fw.hex wlan_eeprom_hw0.bin 2.6.19.2/kernel/drivers/char/led_module.ko; do
	cp "${DIR}/.tk/original/filesystem/lib/modules/$i" "${FILESYSTEM_MOD_DIR}/lib/modules"
done
cp "${DIR}/.tk/original/filesystem/usr/www/avm/css/default/images/kopfbalken_mitte.gif" \
	"${FILESYSTEM_MOD_DIR}/usr/www/avm/css/default/images/"

#echo2 "patching webmenu"
#modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/7240_7270.patch"

echo2 "moving default config dir"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_72* ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7240

echo2 "patching rc.S and rc.conf"
modsed "s/bitfile.bit/bitfile_isdn.bit/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
modsed '/piglet_bitfile=\/lib\/modules\/.*$/a \
piglet_potsbitfile=\/lib\/modules\/bitfile_pots\.bit\${HWRevision_BitFileCount}\
piglet_bitfilemode=`\/bin\/testvalue \/var\/flash\/telefon_misc 4 2638`' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"


modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Fon WLAN 7240\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_CAPI_POTS=.*$/CONFIG_CAPI_POTS=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_CAPI_TE=.*$/CONFIG_CAPI_TE=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_7240\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_CAPI_NT=.*$/CONFIG_CAPI_NT=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"73\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"ur8_16MB_xilinx_4eth_2ab_dect_isdn_pots_wlan_33906\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

#modsed "s/CONFIG_ATA_NOPASSTHROUGH=.*$/CONFIG_NOPASSTHROUGH=\"y\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# patch install script to accept firmware from 7270
echo2 "applying install patch"
modsed "s/ur8_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_usb_host_dect_plus_55266/ur8_16MB_xilinx_4eth_2ab_dect_isdn_pots_wlan_33906/g" "${FIRMWARE_MOD_DIR}/var/install"
# set OEM to avme for international firmware
if isFreetzType LANG_EN; then
	modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_DIR}/cond/en/install-7240_7270.patch" || exit 2
fi

