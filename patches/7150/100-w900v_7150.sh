# Partially copied from sp-to-fritz by spirou & jpascher

[ "$DS_TYPE_SPEEDPORT_W900V_7150" == "y" ] || return 0

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
cp "${DIR}/.tk/original/filesystem/lib/modules/microvoip-dsl.bin" "${FILESYSTEM_MOD_DIR}/lib/modules"

cp "${DIR}/.tk/original/filesystem/etc/init.d/rc.init" "${FILESYSTEM_MOD_DIR}/etc/init.d"

echo2 "deleting obsolete files"
rm -rf "${DIR}/.tk/original/filesystem/lib/modules/microvoiptop.bit"

echo2 "moving default config dir, creating tcom symlinks"
ln -sf /usr/www/all "${FILESYSTEM_MOD_DIR}/usr/www/tcom"
mv "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7150" "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_SpeedportW900V"
ln -sf avm "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_SpeedportW900V/tcom"

echo2 "patching rc.S and rc.init"
sed -i -e "s/ATA=n/ATA=y/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init"
sed -i -e "s/microvoip_top.bit/microvoip_isdn_top.bit/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
sed -i -e "s/piglet_bitfile_offset=0 /piglet_bitfile_offset=0x51 /" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
sed -i -e '/modprobe Piglet piglet_bitfile.*$/i \
 if [ "$HWRevision_BitFileCount" = "1" ] ; then \
 piglet_load_params="\$piglet_load_params piglet_enable_switch=1" \
 fi' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

sed -i -e 's|dect_hw=3|dect_hw=2|' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

sed -i -e "s/^HW=34/HW=102/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init"
sed -i -e "s/PRODUKT_NAME=.*$/PRODUKT_NAME=\"FRITZ!Box#Fon#Speedport#W#900V\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init"
sed -i -e "s/PRODUKT=.*$/PRODUKT=\"Fritz_Box_SpeedportW900V\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init"

echo2 "patching pm_info.in"
sed -i -e 's|PMINFO_MODE=2.*$|PMINFO_MODE=2,100,0,1,974|' "${FILESYSTEM_MOD_DIR}/lib/modules/pm_info.in"
sed -i -e 's|PMINFO_MODE=7.*$|PMINFO_MODE=7,200,141,10,100|' "${FILESYSTEM_MOD_DIR}/lib/modules/pm_info.in"
sed -i -e 's|PMINFO_MODE=8.*$|PMINFO_MODE=8,100,200,78,150|' "${FILESYSTEM_MOD_DIR}/lib/modules/pm_info.in"

echo2 "patching webinterface"
sed -i -e "s/<? setvariable var:showtcom 0 ?>/<? setvariable var:showtcom 1 ?>/g" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/fon/sip1.js"
sed -i -e "s/<? setvariable var:showtcom 0 ?>/<? setvariable var:showtcom 1 ?>/g" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/fon/siplist.js"
sed -i -e "s/<? setvariable var:allprovider 0 ?>/<? setvariable var:allprovider 1 ?>/g" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/internet/authform.html"

sed -i -e 's|^.*txt006 .*$|\t\t\t\t\t\t\t<td style="width:207px"><? echo $var:txt038 ?></td>\n\t\t\t\t\t\t</tr>\n\t\t\t\t\t\t<tr>\
\t\t\t\t\t\t\t<td><script type="text/javascript">document.write(StateLed("<\? query eth1:status/carrier ?>"));</script></td>\
\t\t\t\t\t\t\t<td><? echo $var:txt039 ?></td>\n\t\t\t\t\t\t</tr>\n\t\t\t\t\t\t<tr>\
\t\t\t\t\t\t\t<td><script type="text/javascript">document.write(StateLed("<? query eth2:status/carrier ?>"));</script></td>\
\t\t\t\t\t\t\t<td><? echo $var:txt040 ?></td>\n\t\t\t\t\t\t</tr>\n\t\t\t\t\t\t<tr>\
\t\t\t\t\t\t\t<td><script type="text/javascript">document.write(StateLed("<? query eth3:status/carrier ?>"));</script></td>\
\t\t\t\t\t\t\t<td><? echo $var:txt041 ?></td>|' "${HTML_LANG_MOD_DIR}/home/home.html"
sed -i -e 's|var g_mldLan1[\t]*= "LAN";|var g_mldLan1\t\t\t= "LAN 1";|' "${HTML_LANG_MOD_DIR}/internet/internet_expert.js"
sed -i -e 's|var g_mldLan2[\t]*= "";|var g_mldLan2\t\t\t= "LAN 2, LAN 3, LAN 4";|' "${HTML_LANG_MOD_DIR}/internet/internet_expert.js"
sed -i -e "s/'Internetzugang .ber LAN'/'Internetzugang .ber LAN 1'/" "${HTML_LANG_MOD_DIR}/internet/internet_expert.inc"
sed -i -e 's|"Internetzugang .ber LAN"|"Internetzugang .ber LAN 1"|' "${HTML_LANG_MOD_DIR}/internet/internet_expert.inc"
sed -i -e 's|"Internetzugang .ber LAN"|"Internetzugang .ber LAN 1"|' "${HTML_LANG_MOD_DIR}/system/netipadr.js"
sed -i -e "s/'Internetzugang .ber LAN'/'Internetzugang .ber LAN 1'/" "${HTML_LANG_MOD_DIR}/first/first_ISP_1_dual.inc"
