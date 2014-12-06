[ "$FREETZ_REMOVE_AHA" == "y" ] || return 0
echo1 "removing aha files"
for files in \
  usr/bin/aha \
  usr/bin/ahamailer \
  lib/libaha.so* \
  usr/share/aha/ \
  etc/init.d/S78-aha \
  usr/www/all/lua/ha_func_lib.lua \
  usr/www/all/net/home_auto_*.lua \
  usr/www/all/mobile/home_auto_*.lua \
  usr/www/all/js/ha_draw.js \
  usr/www/all/webservices/homeautoswitch.lua \
  usr/www/all/meter/ \
  usr/www.myfritz/all/areas/homeauto.lua \
  usr/www.myfritz/all/lua/ha_func_lib.lua \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

# 3272 doesn't have tr_smart_home
if ! isFreetzType 3272; then
	homelua_disable tr_smart_home
fi
menulua_remove home_auto_overview

sedfile="${HTML_LANG_MOD_DIR}/home/home.lua"
echo1 "patching ${sedfile##*/}"
modsed '/^<?include "net\/home_auto_func_lib.lua" ?>/d' $sedfile
modsed '/^require ("ha_func_lib")/d' $sedfile
modsed 's/ha_func_lib.get_device_counts.*/0/' $sedfile

for sedfile in ${HTML_LANG_MOD_DIR}/home/home.lua ${HTML_LANG_MOD_DIR}/mobile/home.lua; do
	modsed '/^require("libaha")/d' $sedfile
	modsed '/aha.GetDeviceList()/d' $sedfile
done

sedfile="${HTML_LANG_MOD_DIR}/dect/dect_settings.lua"
echo1 "patching ${sedfile##*/}"
modsed '/^require("libaha")/d' $sedfile
modsed 's/^\(var ulepresent = \).*/\10;/' $sedfile
modsed '/^devicelist = aha.GetDeviceList()/d' $sedfile

# patcht Heimnetz -> Netzwerk -> Netzwerkeinstellungen
sedfile="${HTML_LANG_MOD_DIR}/net/network_settings.lua"
echo1 "patching ${sedfile##*/}"
# modify show_smarthome_broadcast so that it always returns false
mod_del_area \
	'function show_smarthome_broadcast' \
	1 \
	'function \(show_buttons\|is_lan4_vpn\)' \
	-3 \
	$sedfile


sedfile="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
echo1 "patching ${sedfile##*/}"
modsed "s/CONFIG_HOME_AUTO=.*$/CONFIG_HOME_AUTO=\"n\"/g" $sedfile
modsed "s/CONFIG_HOME_AUTO_NET=.*$/CONFIG_HOME_AUTO_NET=\"n\"/g" $sedfile
modsed "s/CONFIG_DECT_HOME=.*$/CONFIG_DECT_HOME=\"n\"/g" $sedfile
