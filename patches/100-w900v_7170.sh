# Partially copied from sp-to-fritz by spirou & jpascher

[ "$DS_TYPE_SPEEDPORT_W900V_7170" == "y" ] || return 0

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
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/sp2fritz-W900V_7170.patch"
cp "${DIR}/.tk/original/filesystem/usr/share/ctlmgr/libdect.so" "${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr"

echo2 "moving default config dir, creating tcom symlinks"
ln -sf /usr/www/all "${FILESYSTEM_MOD_DIR}/usr/www/tcom"
mv "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7170" "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_SpeedportW900V"
ln -sf avm "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_SpeedportW900V/tcom"

echo2 "patching rc.S and rc.init"
sed -i -e "s/microvoip_top.bit/microvoip_isdn_top.bit/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
sed -i -e "s/piglet_bitfile_offset=0 /piglet_bitfile_offset=0x51 /" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
sed -i -e '/modprobe Piglet piglet_bitfile.*$/i \
 if [ "$HWRevision_BitFileCount" = "1" ] ; then \
 piglet_load_params="\$piglet_load_params piglet_enable_switch=1" \
 fi' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

sed -i -e "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"34\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Fon Speedport W900V\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_SpeedportW900V\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_DECT=.*$/CONFIG_DECT=\"y\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_DECT_ONOFF=.*$/CONFIG_DECT_ONOFF=\"y\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"


echo2 "patching pm_info.in"
sed -i -e 's|PMINFO_MODE=2.*$|PMINFO_MODE=2,100,0,1,974|' "${FILESYSTEM_MOD_DIR}/lib/modules/pm_info.in"
sed -i -e 's|PMINFO_MODE=7.*$|PMINFO_MODE=7,200,141,10,100|' "${FILESYSTEM_MOD_DIR}/lib/modules/pm_info.in"
sed -i -e 's|PMINFO_MODE=8.*$|PMINFO_MODE=8,100,200,78,150|' "${FILESYSTEM_MOD_DIR}/lib/modules/pm_info.in"

echo2 "patching webinterface"
sed -i -e "s/<? setvariable var:showtcom 0 ?>/<? setvariable var:showtcom 1 ?>/g" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/fon/sip1.js"
sed -i -e "s/<? setvariable var:showtcom 0 ?>/<? setvariable var:showtcom 1 ?>/g" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/fon/siplist.js"
sed -i -e "s/<? setvariable var:allprovider 0 ?>/<? setvariable var:allprovider 1 ?>/g" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/internet/authform.html"
