# 7170 firmware on W900V hardware
# Partially copied from sp-to-fritz by spirou & jpascher

isFreetzType W900V_7170 || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

echo1 "adapt firmware for W900V"

echo2 "deleting obsolete files"
rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/microvoip_isdn_top.bit*"

echo2 "copying W900V files"
cp "${DIR}/.tk/original/filesystem/etc/led.conf" "${FILESYSTEM_MOD_DIR}/etc/led.conf"
cp "${DIR}/.tk/original/filesystem/lib/modules/2.6.13.1-ohio/kernel/drivers/char/Piglet/Piglet.ko" \
	"${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ohio/kernel/drivers/char/Piglet"
cp ${DIR}/.tk/original/filesystem/lib/modules/microvoip_isdn_top.bit* "${FILESYSTEM_MOD_DIR}/lib/modules"
#cp "${DIR}/.tk/original/filesystem/lib/modules/microvoip-dsl.bin" "${FILESYSTEM_MOD_DIR}/lib/modules"
#cp "${DIR}/.tk/original/filesystem/etc/init.d/rc.init" "${FILESYSTEM_MOD_DIR}/etc/init.d"

echo2 "patching webmenu"
isFreetzType LANG_DE && modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/cond/intro_bar_middle_alien_7170.patch"
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/patches/remove-FON3-7170-alien.patch" || exit 2

if [ ! "$FREETZ_REMOVE_DECT" == "y" ];then
	echo2 "Add dect sites to webmenu"
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/cond/sp2fritz-W900V_7170.patch" || exit 2
	cp "${DIR}/.tk/original/filesystem/usr/share/ctlmgr/libdect.so" "${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr"
fi

echo2 "moving default config dir, creating tcom symlinks"
ln -sf /usr/www/all "${FILESYSTEM_MOD_DIR}/usr/www/tcom"
mv "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7170" "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_DECT_W900V"
ln -sf avm "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_DECT_W900V/tcom"

echo2 "patching rc.S and rc.conf"
modsed "s/microvoip_top.bit/microvoip_isdn_top.bit/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
modsed "s/piglet_bitfile_offset=0 /piglet_bitfile_offset=0x51 /" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
modsed '/modprobe Piglet piglet_bitfile.*$/i \
 if [ "$HWRevision_BitFileCount" = "1" ] ; then \
 piglet_load_params="\$piglet_load_params piglet_enable_switch=1" \
 fi' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/rc.S/rc.S-W900V_7170.patch"

modsed "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"34\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Fon Speedport W 900V\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_DECT_W900V\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_DECT=.*$/CONFIG_DECT=\"y\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_DECT_ONOFF=.*$/CONFIG_DECT_ONOFF=\"y\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"ar7_8MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_usb_host_dect_37264\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"



echo2 "patching pm_info.in"
modsed 's|PMINFO_MODE=2.*$|PMINFO_MODE=2,100,0,1,974|' "${FILESYSTEM_MOD_DIR}/lib/modules/pm_info.in"
modsed 's|PMINFO_MODE=7.*$|PMINFO_MODE=7,200,141,10,100|' "${FILESYSTEM_MOD_DIR}/lib/modules/pm_info.in"
modsed 's|PMINFO_MODE=8.*$|PMINFO_MODE=8,100,200,78,150|' "${FILESYSTEM_MOD_DIR}/lib/modules/pm_info.in"

echo2 "patching webinterface"
modsed "s/<? setvariable var:showtcom 0 ?>/<? setvariable var:showtcom 1 ?>/g" "${HTML_SPEC_MOD_DIR}/fon/sip1.js"
modsed "s/<? setvariable var:showtcom 0 ?>/<? setvariable var:showtcom 1 ?>/g" "${HTML_SPEC_MOD_DIR}/fon/siplist.js"
modsed "s/<? setvariable var:allprovider 0 ?>/<? setvariable var:allprovider 1 ?>/g" "${HTML_SPEC_MOD_DIR}/internet/authform.html"
#sed -i - "s/<? setvariable var:TextMenuSoftware \"Programme\" ?>\\n//g" "${HTML_SPEC_MOD_DIR}/menus/menu2.inc"

echo2 "swapping info led"
#swap info led 0,1 with tr69 led
sed -i \
  -e 's|DEF tr69,0 = 2,6,1,tr69|DEF tr69,0 = 99,32,16,tr69|' \
  -e 's|DEF info,0 = 99,32,16,info|DEF info,0 = 2,6,1,info|' \
  -e 's|DEF info,1 = 99,32,16,info|DEF info,1 = 2,6,1,info|' \
  -e 's|DEF info,2 = 99,32,16,info|DEF info,2 = 2,6,1,info|' \
  -e 's|DEF info,3 = 99,32,16,info|DEF info,3 = 2,6,1,info|' \
  -e 's|DEF info,4 = 99,32,16,info|DEF info,4 = 2,6,1,info|' \
  "${FILESYSTEM_MOD_DIR}/etc/led.conf"

echo "DEF tam,1 = 99,32,21,tam" >> "${FILESYSTEM_MOD_DIR}/etc/led.conf"
# map tam info to power
echo "MAP tam,0 TO power,1" >> "${FILESYSTEM_MOD_DIR}/etc/led.conf"

#map stick_surf to info4, missed call to ata and adsl
echo "MAP stick_surf,0 TO info,4" >> "${FILESYSTEM_MOD_DIR}/etc/led.conf"

# Map ISDN LED to ab LED (config of original FRITZ!Box and replace it by Speedport's LED config)
if ! `cat "${FILESYSTEM_MOD_DIR}"/etc/init.d/rc.S | grep -q 'MAP isdn,0 TO ab,1'` ; then
modsed 's|ln -s /dev/new_led /var/led|ln -s /dev/new_led /var/led\
case $OEM in\
 tcom\|avm)\
 echo "STATES isdn,0 = 0 -> 2, 1 -> 4" >/dev/new_led\
 echo "MAP isdn,0 TO ab,1" >/dev/new_led\
 echo "STATES ab,1 = 1 -> 18, 0 -> 2, 4 -> 1" >/dev/new_led\
 ;;\
 avme)\
 ;;\
esac|' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
fi

# patch install script to accept firmware from FBF on Speedport
echo1 "applying install patch"
modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_COND_DIR}/100-aliens/install/install-W900V_7170.patch" || exit 2

