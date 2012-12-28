[ "$FREETZ_REMOVE_AHA" == "y" ] || return 0
echo1 "removing aha files"
for files in \
 	usr/bin/aha \
 	lib/libaha.so* \
	usr/share/aha/ \
	etc/init.d/S78-aha \
	usr/www/all/net/home_auto_*.lua \
	usr/www/all/mobile/home_auto_*.lua \
	; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

homelua_disable tr_smart_home
menulua_remove home_auto_overview

sedfile="${HTML_LANG_MOD_DIR}/home/home.lua"
echo1 "patching ${sedfile##*/}"
modsed '/^<?include "net\/home_auto_func_lib.lua" ?>/d' $sedfile

sedfile="${HTML_LANG_MOD_DIR}/mobile/home.lua"
echo1 "patching ${sedfile##*/}"
modsed '/^require("libaha")/d' $sedfile
modsed '/^t_ha_list = aha.GetDeviceList()/d' $sedfile

sedfile="${HTML_LANG_MOD_DIR}/dect/dect_settings.lua"
echo1 "patching ${sedfile##*/}"
modsed '/^require("libaha")/d' $sedfile
modsed 's/^\(var ulepresent = \).*/\10;/' $sedfile
modsed '/^devicelist = aha.GetDeviceList()/d' $sedfile

sedfile="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
echo1 "patching ${sedfile##*/}"
modsed "s/CONFIG_HOME_AUTO=.*$/CONFIG_HOME_AUTO=\"n\"/g" $sedfile
modsed "s/CONFIG_HOME_AUTO_NET=.*$/CONFIG_HOME_AUTO_NET=\"n\"/g" $sedfile
modsed "s/CONFIG_DECT_HOME=.*$/CONFIG_DECT_HOME=\"n\"/g" $sedfile
