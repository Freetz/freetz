if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

echo1 "removing TCOM Webinterface"
rm -rf "${FILESYSTEM_MOD_DIR}/usr/www/tcom"

echo1 "copying AVM Webinterface"
mkdir "${FILESYSTEM_MOD_DIR}/usr/www/all"
"$TAR" -c -C "${FILESYSTEM_TK_DIR}/usr/www/all" --exclude=html/de/usb . | "$TAR" -x -C "${FILESYSTEM_MOD_DIR}/usr/www/all"
ln -sf /usr/www/all "${FILESYSTEM_MOD_DIR}/usr/www/tcom"
ln -sf /usr/www/all "${FILESYSTEM_MOD_DIR}/usr/www/avm"

"$TAR" -c -C "${FILESYSTEM_TK_DIR}/etc/default.Fritz_Box_7141/avm" --exclude=*.cfg . | "$TAR" -x -C "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_SpeedportW501V/tcom"
ln -sf tcom "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_SpeedportW501V/avm"

echo1 "copying mailer"
cp -a ${FILESYSTEM_TK_DIR}/sbin/mailer "${FILESYSTEM_MOD_DIR}/sbin/"

# not working at the moment
#echo1 "copying igdd + required libs"
#cp -a ${FILESYSTEM_TK_DIR}/lib/libavmupnp.so* "${FILESYSTEM_MOD_DIR}/lib/"
#cp -a ${FILESYSTEM_TK_DIR}/lib/libmxml.so* "${FILESYSTEM_MOD_DIR}/lib/"
#cp -a ${FILESYSTEM_TK_DIR}/sbin/igdd "${FILESYSTEM_MOD_DIR}/sbin/"

#echo1 "replacing multid"
#cp -a ${FILESYSTEM_TK_DIR}/sbin/multid "${FILESYSTEM_MOD_DIR}/sbin/"

echo1 "copying ar7login"
cp -a ${FILESYSTEM_TK_DIR}/sbin/ar7login "${FILESYSTEM_MOD_DIR}/sbin/"

