isFreetzType 7340_7390 || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

echo1 "adapt firmware for 7340"

echo2 "deleting obsolete files"
rm_files ${FILESYSTEM_MOD_DIR}/lib/modules/bitfile.bit

echo2 "moving default config dir"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7390 ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7340

echo2 "copying 7340 modules"
files="bitfile_isdn.bit bitfile_pots.bit"
for i in $files; do
	cp -a "${FILESYSTEM_TK_DIR}/lib/modules/$i" "${FILESYSTEM_MOD_DIR}/lib/modules/$i"
done

echo2 "copying 7340 webif files"
files="css/default/images/kopfbalken_mitte.gif"
files+=" html/de/images/kopfbalken.gif"
files+=" html/de/images/DectFBoxIcon.png"
for i in $files; do
	cp -a "${FILESYSTEM_TK_DIR}/usr/www/avme/$i" "${FILESYSTEM_MOD_DIR}/usr/www/avme/$i"
done

echo2 "copying 7340 wlan files"
cp -a ${FILESYSTEM_TK_DIR}/etc/default.Fritz_Box_7340/avme/wlan* ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7340/avme/
#7340 difference: 2.4 OR 5 GHz Wlan

sedfile="${HTML_LANG_MOD_DIR}/wlan/wlan_settings.lua"
echo1 "patching ${sedfile##*/}"
cp -a ${FILESYSTEM_TK_DIR}/usr/www/avme/wlan/wlan_settings.lua $sedfile
modsed \
  "s/1706:98/1706:863/g; \
  s/1706:660/1706:329/g; \
  s/1706:191/1706:639/g; \
  s/1706:914/1706:786/g; \
  s/1706:913/1706:458/g; \
  s/1706:852/1706:146/g" \
  $sedfile

sedfile="${HTML_LANG_MOD_DIR}/wlan/radiochannel.lua"
echo1 "patching ${sedfile##*/}"
cp -a ${FILESYSTEM_TK_DIR}/usr/www/avme/wlan/radiochannel.lua $sedfile
modsed \
  "s/6447:231/6447:234/g; \
  s/6447:161/6447:815/g; \
  s/6447:873/6447:720/g; \
  s/6447:210/6447:454/g; \
  s/6447:284/6447:11/g; \
  s/6447:132/6447:791/g" \
  $sedfile

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

# patch ar7.cfg to include eth1
ar7path="etc/default.Fritz_Box_7340/avme/ar7.cfg"
mod_file="${FILESYSTEM_MOD_DIR}/${ar7path}"
tk_file="${FILESYSTEM_TK_DIR}/${ar7path}"
echo2 "applying ar7.cfg patch"
modsed '/interfaces =/ s/"eth0"/"eth0", "eth1"/' "${mod_file}"
awk -v eth1="$(sed -n '/name = "eth[1]"/,/} {/ p' "${tk_file}")" \
	'{if (/name = "wlan/){print eth1; print$0}else{print $0}}' \
	"${mod_file}" > "${mod_file}.tmp"
mv  "${mod_file}.tmp"	"${mod_file}"

# patch install script to accept firmware from 7390
echo2 "applying install patch"
modsed "s/iks_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_usb_host_dect_64415/iks_16MB_xilinx_2eth_2ab_isdn_te_pots_wlan_usb_host_dect_63350/g" "${FIRMWARE_MOD_DIR}/var/install"

