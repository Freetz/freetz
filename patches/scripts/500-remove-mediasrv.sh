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

# patcht USB-Geräte > USB-Speicher >  Musikbox aktivieren
sedfile="${HTML_SPEC_MOD_DIR}/usb/usbdisk.html"
if [ -e $sedfile ]; then
	echo1 "patching ${sedfile##*/}"
	sedrow=$(cat $sedfile |nl| sed -n 's/^ *\([0-9]*\).*"uiViewUseMusik".*$/\1/p')
	modsed "$((sedrow-1)),$((sedrow+2))d" $sedfile
fi

sedfile="${HTML_LANG_MOD_DIR}/storage/settings.lua"
if [ -e $sedfile ]; then
	echo1 "patching ${sedfile##*/}"
	# see http://freetz.org/ticket/1391 for details
	modsed "s/call_webusb.call_webusb_func(\"scan_info\".*)/\"\" -- &/g" $sedfile
	# patcht Heimnetz > Speicher (NAS) > Speicher (NAS) > Mediaserver
	sedrows=$(cat $sedfile |nl| sed -n 's/^ *\([0-9]*\).*<h4>{?80:609?}<.h4>$/\1/p')
	sedrowe=$(cat $sedfile |nl| sed -n 's/^ *\([0-9]*\).*<p>{?80:1383?}<.p>$/\1/p')
	modsed "$((sedrows-2)),$((sedrowe+1))d" $sedfile
fi

echo1 "patching rc.conf"
modsed "s/CONFIG_MEDIASRV=.*$/CONFIG_MEDIASRV=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
