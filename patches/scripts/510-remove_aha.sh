[ "$FREETZ_REMOVE_AHA" == "y" ] || return 0
echo1 "removing aha files"
for files in \
 	usr/bin/aha \
 	lib/libaha.so* \
	usr/share/aha/ \
	etc/init.d/S78-aha \
	; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

homelua_disable tr_smart_home

echo1 "patching rc.conf"
modsed "s/CONFIG_HOME_AUTO=.*$/CONFIG_HOME_AUTO=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_HOME_AUTO_NET=.*$/CONFIG_HOME_AUTO_NET=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_DECT_HOME=.*$/CONFIG_DECT_HOME=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
