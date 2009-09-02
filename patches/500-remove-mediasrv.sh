[ "$FREETZ_REMOVE_MEDIASRV" == "y" ] || return 0
echo1 "remove mediasrv files"
for files in \
	lib/libsqlite3*.so* \
	lib/libexif.so* \
	lib/libpng.so* \
	sbin/mediasrv \
	sbin/start_mediasrv \
	sbin/stop_mediasrv \
	; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done
[ "$FREETZ_REMOVE_MINID" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/lib/libavmid3*.so*"

if !(isFreetzType 7140 && isFreetzType LANG_A_CH); then
echo1 "patching Web UI"
sed -i -e "/^<p.*uiViewUseMusik.*<\/p>$/ {
	N
	s/\n//g
	D }" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/nas/einstellungen.html"
fi
echo1 "patching rc.conf"
sed -i -e "s/CONFIG_MEDIASRV=.*$/CONFIG_MEDIASRV=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
