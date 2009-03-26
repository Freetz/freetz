[ "$FREETZ_TYPE_7141_7170" == "y" ] || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi
echo1 "adapt firmware for 7141"

echo2 "copying 7141 files"
cp "${DIR}/.tk/original/filesystem/lib/modules/microvoip_isdn_top.bit" "${FILESYSTEM_MOD_DIR}/lib/modules"

echo2 "deleting obsolete files"
rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/microvoip_isdn_top.bit1"

#echo2 "patching webmenu"
#modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/7141_7170.patch"

echo2 "moving default config dir, creating tcom and congstar symlinks"
mv "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7170" "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7141"

echo2 "patching rc.S and rc.conf"

sed -i -e "s/piglet_bitfile_offset=0/piglet_bitfile_offset=0x4b/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

sed -i -e "s/CONFIG_AB_COUNT=.*$/CONFIG_AB_COUNT=\"2\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_CAPI_NT=.*$/CONFIG_CAPI_NT=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_ETH_COUNT=.*$/CONFIG_ETH_COUNT=\"1\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"40\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Fon WLAN 7141\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_7141\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"ar7_8MB_xilinx_1eth_2ab_isdn_te_pots_wlan_usb_host_49780\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/HWRevision_ATA=0$/HWRevision_ATA=1/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# patch install script to accept firmware from 7170
echo1 "applying install patch"
modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_DIR}/cond/install-7141_7170.patch" || exit 2

[ "$FREETZ_TYPE_7141_7170" == "y" ] || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi
echo1 "adapt firmware for 7141"

echo2 "copying 7141 files"
#cp "${DIR}/.tk/original/filesystem/etc/led.conf" "${FILESYSTEM_MOD_DIR}/etc/led.conf"
#cp "${DIR}/.tk/original/filesystem/lib/modules/2.6.13.1-ohio/kernel/drivers/char/Piglet/Piglet.ko" \
#	"${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ohio/kernel/drivers/char/Piglet"
cp "${DIR}/.tk/original/filesystem/lib/modules/microvoip_isdn_top.bit" "${FILESYSTEM_MOD_DIR}/lib/modules"

echo2 "deleting obsolete files"
rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/microvoip_isdn_top.bit1"

#echo2 "patching webmenu"
#modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/7141_7170.patch"

echo2 "moving default config dir, creating tcom and congstar symlinks"
mv "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7170" "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7141"

echo2 "patching rc.S and rc.conf"

sed -i -e "s/piglet_bitfile_offset=0/piglet_bitfile_offset=0x4b/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

sed -i -e "s/CONFIG_AB_COUNT=.*$/CONFIG_AB_COUNT=\"2\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_CAPI_NT=.*$/CONFIG_CAPI_NT=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_ETH_COUNT=.*$/CONFIG_ETH_COUNT=\"1\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"40\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Fon WLAN 7141\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_7141\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"ar7_8MB_xilinx_1eth_2ab_isdn_te_pots_wlan_usb_host_49780\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/HWRevision_ATA=0$/HWRevision_ATA=1/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

sed -i -e "s/CONFIG_TR064=.*$/CONFIG_TR064=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_VPN=.*$/CONFIG_VPN=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"



# patch install script to accept firmware from 7170
echo1 "applying install patch"
modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_DIR}/cond/install-7141_7170.patch" || exit 2

