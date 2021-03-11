# 7170 firmware on 7112 hardware
isFreetzType 7112_7170 || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

echo1 "adapt firmware for 7112"

echo2 "deleting obsolete files"
files="fs/ext2 fs/fat fs/isofs fs/nls fs/vfat fs/mbcache.ko drivers/usb drivers/scsi"
files+=" drivers/isdn/isdn_fon4 drivers/char/Piglet"
for i in $files; do
	rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ohio/kernel/$i"
done

# no internal S0
rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/microvoip_isdn_top.bit*"
# USB
for i in \
  bin/pause bin/reinit_jffs2 \
  bin/*usb* sbin/*usb* usr/bin/*usb* usr/sbin/*usb* \
  etc/hotplug etc/samba_control \
  etc/default.*/*/*usb* etc/init.d/rc.*usb* etc/*usb*.tab \
  lib/lib*usb*.so* usr/share/*/lib*usb*.so* \
  usr/www/all/*usb* usr/www/all/html/*usb* usr/www/all/html/*/*usb* usr/www/all/html/*/*/*usb* \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$i"
done

echo2 "copying 7112 files"
cp -a "${DIR}/.tk/original/filesystem/lib/modules/bitfile.bit" "${FILESYSTEM_MOD_DIR}/lib/modules/"
cp -a "${DIR}/.tk/original/filesystem/lib/modules/microvoip-dsl.bin" "${FILESYSTEM_MOD_DIR}/lib/modules/"
cp -a -R "${DIR}/.tk/original/filesystem/lib/modules/2.6.13.1-ohio/kernel/drivers/isdn/isdn_fon3" "${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ohio/kernel/drivers/isdn/"
cp -a -R "${DIR}/.tk/original/filesystem/lib/modules/2.6.13.1-ohio/kernel/drivers/char/Piglet_noemif" "${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ohio/kernel/drivers/char/"

echo2 "patching webmenu"
isFreetzType LANG_DE && modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/cond/intro_bar_middle_alien_7170.patch"

modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/patches/remove-POTS-7170-alien.patch"
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/patches/remove-FON3-7170-alien.patch"

echo2 "moving default config dir"
if isFreetzType ANNEX_A; then
	mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_717* "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7112_AnnexA" || exit 2
else
	mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_717* "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7112" || exit 2
fi

echo2 "patching rc.S and rc.conf"
modsed "s/piglet_bitfile=\/lib\/modules\/microvoip_isdn_top\.bit.*$/piglet_bitfile=\/lib\/modules\/bitfile\.bit/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
modsed "s/modprobe Piglet piglet_bitfile=.*$/modprobe Piglet_noemif piglet_bitfile=\$piglet_bitfile piglet_bitfilemode=2/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

modsed "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"87\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Fon WLAN 7112\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_7112\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"ar7_8MB_xilinx_1eth_2ab_nopstn_wlan_32713\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/HWRevision_ATA=0$/HWRevision_ATA=1/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_ETH_COUNT=.*$/CONFIG_ETH_COUNT=\"1\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

modsed "s/CONFIG_AB_COUNT=.*$/CONFIG_AB_COUNT=\"2\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_CAPI_NT=.*$/CONFIG_CAPI_NT=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_CAPI_POTS=.*$/CONFIG_CAPI_POTS=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_CAPI_TE=.*$/CONFIG_CAPI_TE=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_FON_HD=.*$/CONFIG_FON_HD=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_FONQUALITY=.*$/CONFIG_FONQUALITY=\"y\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_T38=.*$/CONFIG_T38=\"y\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

modsed "s/CONFIG_USB_HOST_AVM=.*$/CONFIG_USB_HOST_AVM=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_USB_WLAN_AUTH=.*$/CONFIG_USB_WLAN_AUTH=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_USB_STORAGE=.*$/CONFIG_USB_STORAGE=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_USB_STORAGE_SPINDOWN=.*$/CONFIG_USB_STORAGE_SPINDOWN=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# patch install script to accept firmware from 7170
echo1 "applying install patch"
if isFreetzType ANNEX_A; then
	modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/install/install-7112_7170_Annex_A.patch" || exit 2
else
	modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/install/install-7112_7170.patch" || exit 2
fi

