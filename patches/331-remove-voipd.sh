[ "$FREETZ_REMOVE_VOIPD" == "y" ] || return 0

echo1 "removing VoIP files"
for files in \
	bin/showvoipdstat \
	bin/voipd \
	lib/libosip*2.so* \
	lib/librtpstream*.so* \
	lib/libsiplib.so* \
	usr/www/all/html/de/first/sip* \
	usr/www/all/html/de/fon/sip* \
	; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done
[ ! -e "${FILESYSTEM_MOD_DIR}/usr/share/telefon/libtam.so" -o "$FREETZ_REMOVE_VOIP_ISDN" == "y" ] && rm_files \
	"${FILESYSTEM_MOD_DIR}/lib/libmscodex.so*"

echo1 "patching web UI"
sed -i -e "/document.write(Sip.\{1,5\}(.*))/d" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/home/home.html"
sed -i -e "/\<Status$1\>/d" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/home/home.html"
sed -i -e "/document.write(FonDisplay()/d" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/home/home.html"
sed -i -e "/document.write(FonTitle(false))/ {
	N
	s/\n//g
	D }" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/home/home.html"

sed -i -e "/jslGoTo('fon','siplist')/d;/^<?.* sip.*?>$/d" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/menus/menu2_fon.html"

echo1 "patching rc.conf"
sed -i -e "s/CONFIG_FON_IPHONE=.*$/CONFIG_FON_IPHONE=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_FON_HD=.*$/CONFIG_FON_HD=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_T38=.*$/CONFIG_T38=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
sed -i -e "s/CONFIG_FONQUALITY=.*$/CONFIG_FONQUALITY=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

touch "${FILESYSTEM_MOD_DIR}/bin/voipd"
chmod +x "${FILESYSTEM_MOD_DIR}/bin/voipd"
