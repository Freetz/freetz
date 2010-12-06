[ "$FREETZ_REMOVE_MEDIASRV" == "y" ] || return 0
echo1 "remove mediasrv files"
for files in \
	lib/libexif.so* \
	lib/libmediasrv.so* \
	lib/libnetpbm.so* \
	lib/libpng.so* \
	lib/libsqlite3*.so* \
	sbin/mediasrv \
	sbin/start_mediasrv \
	sbin/stop_mediasrv \
	bin/playerd \
	bin/cjpeg \
	bin/djpeg \
	bin/pnm* \
	bin/rdjpgcom \
	; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

[ "$FREETZ_REMOVE_MINID" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/lib/libavmid3*.so*"

if [ -e "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/nas/einstellungen.html" ]; then
echo1 "patching Web UI"
modsed "/^<p.*uiViewUseMusik.*<\/p>$/ {
	N
	s/\n//g
	D }" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/nas/einstellungen.html"
fi

echo1 "patching rc.conf"
modsed "s/CONFIG_MEDIASRV=.*$/CONFIG_MEDIASRV=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
