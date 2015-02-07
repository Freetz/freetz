[ "$FREETZ_REMOVE_WEBDAV" == "y" ] || return 0

echo1 "removing AVM webdav files"
for files in \
  lib/libexpat.so* \
  lib/libneon.so* \
  sbin/*mount.davfs \
  etc/onlinechanged/webdav_net \
  etc/webdav_control \
  usr/www/all/html/de/home/home_webdav.txt \
  $([ "$FREETZ_PACKAGE_DECRYPT_FRITZOS_CFG" == "y" ] || echo bin/webdavcfginfo) \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

if [ "$FREETZ_PACKAGE_DAVFS2" != "y" -o "$FREETZ_PACKAGE_DAVFS2_REMOVE_WEBIF" == "y" ]; then
	rm_files "${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libctlwebdav.so"

	# patcht Heimnetz > Speicher (NAS) > Speicher an der FRITZ!Box
	sedfile="${HTML_LANG_MOD_DIR}/storage/settings.lua"
	if [ -e "$sedfile" ]; then
		mod_del_area \
		  'id="devices_table_online"' \
		  0 \
		  'id="webdavIndexState"' \
		  2 \
		  $sedfile
		# webdav section, only visible if not disabled
		modsed 's/if not(g_webdav_enabled)/& or true/' $sedfile
		# disable value saving
		modsed '/webdavclient.settings.enabled/d' $sedfile
	fi
		
	echo1 "patching rc.conf"
	modsed "s/CONFIG_WEBDAV=.*$/CONFIG_WEBDAV=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
fi
