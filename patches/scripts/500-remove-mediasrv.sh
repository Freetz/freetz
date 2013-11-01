[ "$FREETZ_REMOVE_MEDIASRV" == "y" ] || \
[ "$FREETZ_AVMPLUGINS_ENABLED" -a "$FREETZ_AVMPLUGINS_MEDIASRV" != "y" ] || \
return 0

# if nas, mediaserv und samba are removed -> remove_nas deletes menu item Heimnetz > Speicher (NAS)

sedfile="${HTML_LANG_MOD_DIR}/storage/media_settings.lua"
if [ -e $sedfile ]; then
	# patcht Heimnetz > MediaServer >Einstellungen > Mediaserver (ab 05.59)
	echo1 "patching ${sedfile##*/}"
	error 1 TODO
else
	sedfile="${HTML_LANG_MOD_DIR}/storage/settings.lua"
	if [ -e $sedfile ]; then
		echo1 "patching ${sedfile##*/}"
		sedrowe=$(cat $sedfile |nl| sed -n 's/^ *\([0-9]*\).*{?80:1383?}.*$/\1/p')
		if grep -q uiViewUseMusikBox $sedfile; then
			# patcht Heimnetz > Speicher (NAS) > Aktivierung > Musikbox aktiv (04.xx)
			sedrows=$(cat $sedfile |nl| sed -n 's/^ *\([0-9]*\).*id="uiViewUseMusikBox.*$/\1/p')
			modsed "$((sedrows-1)),$((sedrowe+2))d" $sedfile
		else
#TODO 7320 sed fehler (5.51?)
			# patcht Heimnetz > Speicher (NAS) > Speicher (NAS) > Mediaserver (05.xx)
			sedrows=$(cat $sedfile |nl| sed -n 's/^ *\([0-9]*\).*<h4>{?80:609?}<.h4>$/\1/p')
			modsed "$((sedrows-2)),$((sedrowe+1))d" $sedfile
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
  lib/libsqlite3*.so* \
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
# MEDIASRV & MINID are using this file
[ "$FREETZ_REMOVE_MINID" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/lib/libavmid3*.so*"

if [ -e "${HTML_SPEC_MOD_DIR}/nas/einstellungen.html" ]; then
	echo1 "patching Web UI"
	modsed "/^<p.*uiViewUseMusik.*<\/p>$/ {
	  N
	  s/\n//g
	  D }" "${HTML_SPEC_MOD_DIR}/nas/einstellungen.html"
fi


# patcht USB-Geraete > USB-Speicher >  Musikbox aktivieren
sedfile="${HTML_SPEC_MOD_DIR}/usb/usbdisk.html"
if [ -e $sedfile ]; then
	echo1 "patching ${sedfile##*/}"
	sedrow=$(cat $sedfile |nl| sed -n 's/^ *\([0-9]*\).*"uiViewUseMusik".*$/\1/p')
	modsed "$((sedrow-1)),$((sedrow+2))d" $sedfile
fi

