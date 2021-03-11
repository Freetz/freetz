# 7170 firmware on 7113 hardware
isFreetzType 7113_7170 || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

echo1 "adapt firmware for 7113"

echo2 "deleting obsolete files"
files="fs/ext2 fs/fat fs/isofs fs/nls fs/vfat fs/mbcache.ko drivers/usb drivers/scsi"
files+=" drivers/isdn/isdn_fon4 drivers/char/Piglet"
for i in $files; do
	rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ohio/kernel/$i"
done
rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/microvoip_isdn_top.bit*"
rm_files "${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libctlusb.so"
rm_files "${FILESYSTEM_MOD_DIR}/lib/libusbcfg*"
rm_files "${FILESYSTEM_MOD_DIR}/etc/hotplug"

echo2 "copying 7113 files"
cp -a ${DIR}/.tk/original/filesystem/lib/modules/microvoip*top.bit "${FILESYSTEM_MOD_DIR}/lib/modules"
cp -a "${DIR}/.tk/original/filesystem/lib/modules/microvoip-dsl.bin" "${FILESYSTEM_MOD_DIR}/lib/modules/"
cp -a -R "${DIR}/.tk/original/filesystem/lib/modules/2.6.13.1-ohio/kernel/drivers/isdn/isdn_fon3" "${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ohio/kernel/drivers/isdn/"
cp -a -R "${DIR}/.tk/original/filesystem/lib/modules/2.6.13.1-ohio/kernel/drivers/char/Piglet_noemif" "${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ohio/kernel/drivers/char/"

echo2 "patching webmenu"
isFreetzType LANG_DE && modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/cond/intro_bar_middle_alien_7170.patch"
#modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/install/install-7113_7170.patch"

echo2 "moving default config dir"
mv "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7170" "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7113"

echo2 "patching rc.S and rc.conf"
modsed '/modprobe Piglet piglet_bitfile.*$/i \
piglet_potsbitfile=/lib/modules/microvoip_top.bit\${HWRevision_BitFileCount}\
piglet_bitfilemode=`/bin/testvalue /var/flash/telefon_misc 4 2638`' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
modsed "s/modprobe Piglet piglet_bitfile=.*$/modprobe Piglet_noemif piglet_bitfile=\$piglet_bitfile piglet_potsbitfile=\$piglet_potsbitfile piglet_bitfilemode=\$piglet_bitfilemode/g" \
	"${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

modsed "s/CONFIG_AB_COUNT=.*$/CONFIG_AB_COUNT=\"2\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_CAPI_NT=.*$/CONFIG_CAPI_NT=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"30\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Fon WLAN 7113\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_7113\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"ar7_8MB_xilinx_1eth_2ab_isdn_te_pots_wlan_01427\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/HWRevision_ATA=0$/HWRevision_ATA=1/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_WLAN_SAVEMEM=.*$/CONFIG_WLAN_SAVEMEM=\"y\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

#modsed "s/CONFIG_TR064=.*$/CONFIG_TR064=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed "s/CONFIG_VPN=.*$/CONFIG_VPN=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# patch install script to accept firmware from 7170
echo1 "applying install patch"
modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/install/install-7113_7170.patch" || exit 2

