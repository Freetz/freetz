[ "$FREETZ_REMOVE_MEDIASRV" == "y" ] || return 0
echo1 "remove mediasrv files"
for files in \
	bin/showfritznasdbstart \
	lib/libavmdb.so* \
	lib/libpng.so* \
	lib/libmediasrv.so* \
	lib/libsqlite3*.so* \
	sbin/fritznasdb \
	sbin/mediasrv \
	sbin/start_mediasrv \
	sbin/stop_mediasrv \
	etc/init.d/rc.media \
	etc/init.d/S76-media \
	; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

[ "$FREETZ_REMOVE_MINID" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/lib/libavmid3*.so*"

if [ -e "${HTML_SPEC_MOD_DIR}/nas/einstellungen.html" ]; then
echo1 "patching Web UI"
modsed "/^<p.*uiViewUseMusik.*<\/p>$/ {
	N
	s/\n//g
	D }" "${HTML_SPEC_MOD_DIR}/nas/einstellungen.html"
fi

sedfile="${HTML_LANG_MOD_DIR}/storage/settings.lua"
if [ -e $sedfile ]; then
	echo1 "patching ${sedfile##*/}"
	# see http://freetz.org/ticket/1391 for details
	modsed "s/call_webusb.call_webusb_func(\"scan_info\".*)/\"\" -- &/g" $sedfile
fi

echo1 "patching rc.conf"
modsed "s/CONFIG_MEDIASRV=.*$/CONFIG_MEDIASRV=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
