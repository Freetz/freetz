# Partially copied from sp-to-fritz by spirou & jpascher

[ "$FREETZ_TYPE_SPEEDPORT_W900V_7170" == "y" ] || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

echo1 "adapt firmware for W900V"

echo2 "copying W900V files"
cp "${DIR}/.tk/original/filesystem/etc/led.conf" "${FILESYSTEM_MOD_DIR}/etc/led.conf"
cp "${DIR}/.tk/original/filesystem/lib/modules/2.6.13.1-ohio/kernel/drivers/char/Piglet/Piglet.ko" \
	"${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ohio/kernel/drivers/char/Piglet"
cp "${DIR}/.tk/original/filesystem/lib/modules/microvoip_isdn_top.bit" "${FILESYSTEM_MOD_DIR}/lib/modules"
ln -sf  microvoip_isdn_top.bit "${FILESYSTEM_MOD_DIR}/lib/modules/microvoip_isdn_top.bit1"
#cp "${DIR}/.tk/original/filesystem/lib/modules/microvoip-dsl.bin" "${FILESYSTEM_MOD_DIR}/lib/modules"
#cp "${DIR}/.tk/original/filesystem/etc/init.d/rc.init" "${FILESYSTEM_MOD_DIR}/etc/init.d"

echo2 "Add dect sites to webmenu"
#Test if a beta-image or a labor-image is used and use another patchfile for them
if [ "$FREETZ_TYPE_LABOR_BETA" == "y" ];then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/sp2fritz-W900V_7170.patch"
elif [ "$FREETZ_TYPE_LABOR_DSL" == "y" ];then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/sp2fritz-W900V_7170_labor_dsl.patch"
elif [ "$FREETZ_TYPE_LABOR_ALL" == "y" ];then
        modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/sp2fritz-W900V_7170_labor_all.patch"
elif [ "$FREETZ_TYPE_LABOR_PHONE" == "y" ];then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/sp2fritz-W900V_7170_labor_phone.patch"
elif [ "$FREETZ_TYPE_LABOR_GAMING" == "y" ];then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/sp2fritz-W900V_7170_labor_gaming.patch"
elif [ "$FREETZ_TYPE_LABOR_MINI" == "y" ];then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/sp2fritz-W900V_7170_labor_mini.patch"
else
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/sp2fritz-W900V_7170.patch"
fi

cp "${DIR}/.tk/original/filesystem/usr/share/ctlmgr/libdect.so" "${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr"

echo2 "moving default config dir, creating tcom symlinks"
ln -sf /usr/www/all "${FILESYSTEM_MOD_DIR}/usr/www/tcom"
mv "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7170" "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_SpeedportW900V"
ln -sf avm "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_SpeedportW900V/tcom"

echo2 "patching rc.S and rc.conf"
sed -i -e "s/microvoip_top.bit/microvoip_isdn_top.bit/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
sed -i -e "s/piglet_bitfile_offset=0 /piglet_bitfile_offset=0x51 /" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
sed -i -e '/modprobe Piglet piglet_bitfile.*$/i \
 if [ "$HWRevision_BitFileCount" = "1" ] ; then \
 piglet_load_params="\$piglet_load_params piglet_enable_switch=1" \
 fi' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/rc.S-W900V_7170.patch"

sed -i -e "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"34\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Fon Speedport W900V\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_SpeedportW900V\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_DECT=.*$/CONFIG_DECT=\"y\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_DECT_ONOFF=.*$/CONFIG_DECT_ONOFF=\"y\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"ar7_8MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_usb_host_dect_37264\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"



echo2 "patching pm_info.in"
sed -i -e 's|PMINFO_MODE=2.*$|PMINFO_MODE=2,100,0,1,974|' "${FILESYSTEM_MOD_DIR}/lib/modules/pm_info.in"
sed -i -e 's|PMINFO_MODE=7.*$|PMINFO_MODE=7,200,141,10,100|' "${FILESYSTEM_MOD_DIR}/lib/modules/pm_info.in"
sed -i -e 's|PMINFO_MODE=8.*$|PMINFO_MODE=8,100,200,78,150|' "${FILESYSTEM_MOD_DIR}/lib/modules/pm_info.in"

echo2 "patching webinterface"
sed -i -e "s/<? setvariable var:showtcom 0 ?>/<? setvariable var:showtcom 1 ?>/g" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/fon/sip1.js"
sed -i -e "s/<? setvariable var:showtcom 0 ?>/<? setvariable var:showtcom 1 ?>/g" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/fon/siplist.js"
sed -i -e "s/<? setvariable var:allprovider 0 ?>/<? setvariable var:allprovider 1 ?>/g" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/internet/authform.html"
#sed -i - "s/<? setvariable var:TextMenuSoftware \"Programme\" ?>\\n//g" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/menus/menu2.inc"

echo2 "swapping info led"
#swap info led 0,1 with tr69 led
sed -i -e 's|DEF tr69,0 = 2,6,1,tr69|DEF tr69,0 = 99,32,16,tr69|' \
	-e 's|DEF info,0 = 99,32,16,info|DEF info,0 = 2,6,1,info|' \
	-e 's|DEF info,1 = 99,32,16,info|DEF info,1 = 2,6,1,info|' \
	-e 's|DEF info,2 = 99,32,16,info|DEF info,2 = 2,6,1,info|' \
	-e 's|DEF info,3 = 99,32,16,info|DEF info,3 = 2,6,1,info|' \
	-e 's|DEF info,4 = 99,32,16,info|DEF info,4 = 2,6,1,info|' "${FILESYSTEM_MOD_DIR}/etc/led.conf"

echo "DEF tam,1 = 99,32,21,tam" >> "${FILESYSTEM_MOD_DIR}/etc/led.conf"
# map tam info to power
echo "MAP tam,0 TO power,1" >> "${FILESYSTEM_MOD_DIR}/etc/led.conf"

#map stick_surf to info4, missed call to ata and adsl
echo "MAP stick_surf,0 TO info,4" >> "${FILESYSTEM_MOD_DIR}/etc/led.conf"

# Map ISDN LED to ab LED (config of original FRITZ!Box and replace it by Speedport's LED config)
if ! `cat "${FILESYSTEM_MOD_DIR}"/etc/init.d/rc.S | grep -q 'MAP isdn,0 TO ab,1'` ; then
sed -i -e 's|ln -s /dev/new_led /var/led|ln -s /dev/new_led /var/led\
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
modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_DIR}/cond/install-W900V_7170.patch" || exit 2
