[ "$FREETZ_REMOVE_MEDIASRV" == "y" ] || \
[ "$FREETZ_AVMPLUGINS_ENABLED" -a "$FREETZ_AVMPLUGINS_MEDIASRV" != "y" ] || \
return 0

# if nas, mediaserv und samba are removed -> remove_nas deletes menu item Heimnetz > Speicher (NAS)

if [ -e "${HTML_LANG_MOD_DIR}/storage/media_settings.lua" ]; then
	# entfernt Heimnetz > Mediaserver (06.xx)
	menulua_remove storage.media_settings
	menulua_remove dect.internetradio
	menulua_remove dect.podcast
	# Heimnetz > Speicher (NAS) > Speicher an der FRITZ!Box > Speicher (NAS) aktiv > Datei-Index
	sedfile="${HTML_LANG_MOD_DIR}/storage/settings.lua"
	modsed 's!function get_scan_state.*!&\nif true then return "" end!g' $sedfile
	modsed 's/{?80:755?}//'  $sedfile
else
	sedfile="${HTML_LANG_MOD_DIR}/storage/settings.lua"
	if [ -e $sedfile ]; then
		echo1 "patching ${sedfile##*/}"
		if grep -q uiViewUseMusikBox $sedfile; then
			# patcht Heimnetz > Speicher (NAS) > Aktivierung > Musikbox aktiv (04.xx)
			mod_del_area \
			  'id="uiViewUseMusikBox"' \
			  -1 \
			  '{?80:1383?}' \
			  +2 \
			  $sedfile
		else
			# patcht Heimnetz > Speicher (NAS) > Speicher (NAS) > Mediaserver (05.xx)
			mod_del_area \
			  '<h4>{?80:609?}<.h4>' \
			  -2 \
			  '{?80:1383?}' \
			  +1 \
			  $sedfile
		fi
	fi
fi

# see http://freetz.org/ticket/1391 for details
modsed "s/call_webusb.call_webusb_func(\"scan_info\".*)/\"\" -- &/g" "${HTML_LANG_MOD_DIR}/storage/settings.lua"


echo1 "patching rc.conf"
modsed "s/CONFIG_MEDIASRV=.*$/CONFIG_MEDIASRV=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

[ "$FREETZ_REMOVE_MEDIASRV" == "y" ] || return 0

echo1 "remove mediasrv files"
for files in \
  lib/libpng.so* \
  lib/libmediasrv.so* \
  lib/libstationurl.so* \
  sbin/mediasrv \
  sbin/start_mediasrv \
  sbin/stop_mediasrv \
  etc/init.d/rc.media \
  etc/init.d/S76-media \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

# don't remove libwebusb*.so, see http://freetz.org/ticket/2020
# MEDIASRV & NAS are using this file
[ "$FREETZ_REMOVE_NAS" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/lib/libavmdb.so*"
# MEDIASRV & UPNP (started by NAS) are using this file
[ "$FREETZ_REMOVE_UPNP" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/lib/libsqlite3*.so*"
# MEDIASRV & MINID are using this file
[ "$FREETZ_REMOVE_MINID" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/lib/libavmid3*.so*"

if [ -e "${HTML_SPEC_MOD_DIR}/nas/einstellungen.html" ]; then
	echo1 "patching Web UI"
	modsed "/^<p.*uiViewUseMusik.*<\/p>$/ {
	  N
	  s/\n//g
	  D }" "${HTML_SPEC_MOD_DIR}/nas/einstellungen.html"
fi

# patcht Heimnetz > Mediaserver
menulua_remove dect.internetradio 
menulua_remove dect.podcast

# patcht Dect > Internetdienste
menulua_remove dect.radiopodcast

# patcht USB-Geraete > USB-Speicher >  Musikbox aktivieren
mod_del_area \
  '"uiViewUseMusik"' \
  -1 \
  +2 \
  "${HTML_SPEC_MOD_DIR}/usb/usbdisk.html"

