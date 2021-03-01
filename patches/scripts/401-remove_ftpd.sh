[ "$FREETZ_REMOVE_FTPD" == "y" ] || return 0
echo1 "remove AVM-ftpd files"

rm_files \
  "${FILESYSTEM_MOD_DIR}/sbin/ftpd" \
  "${FILESYSTEM_MOD_DIR}/bin/inetdftp" \
  "${FILESYSTEM_MOD_DIR}/etc/ftpd_control"

echo1 "patching rc.conf"
modsed "s/CONFIG_FTP=.*$/CONFIG_FTP=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# patcht Heimnetz > Speicher (NAS)
sedfile="${HTML_LANG_MOD_DIR}/storage/settings.lua"
if [ -e "$sedfile" ]; then
	echo1 "patching ${sedfile##*/}"
	# entfernt "Speicher fuer Benutzer aus dem Internet freigeben" (04.xx)
	mod_del_area \
	  '<div id="uiViewInternetSharingBox"' \
	  +0 \
	  '<div id="uiViewUseMusikBox"' \
	  -2 \
	  $sedfile
fi

