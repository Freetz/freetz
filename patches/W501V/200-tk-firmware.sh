if [ -z "$FIRMWARE2" ]
then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

echo1 "removing TCOM Webinterface"
rm -rf "${FILESYSTEM_MOD_DIR}/usr/www/tcom"

echo1 "copying AVM Webinterface"
mkdir "${FILESYSTEM_MOD_DIR}/usr/www/all"
"$TAR" -c -C "${DIR}/.tk/original/filesystem/usr/www/all" --exclude=html/de/usb . | "$TAR" -x -C "${FILESYSTEM_MOD_DIR}/usr/www/all"
ln -sf all "${FILESYSTEM_MOD_DIR}/usr/www/tcom"
ln -sf all "${FILESYSTEM_MOD_DIR}/usr/www/avm"

"$TAR" -c -C "${DIR}/.tk/original/filesystem/etc/default.Fritz_Box_7140/avm" . | "$TAR" -x -C "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_SpeedportW501V/tcom"
ln -sf avm "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_SpeedportW501V/tcom"

echo1 "copying mailer"
cp -a ${DIR}/.tk/original/filesystem/sbin/mailer "${FILESYSTEM_MOD_DIR}/sbin/"

echo1 "copying igdd + required libs"
cp -a ${DIR}/.tk/original/filesystem/lib/libavmupnp.so* "${FILESYSTEM_MOD_DIR}/lib/"
cp -a ${DIR}/.tk/original/filesystem/lib/libmxml.so* "${FILESYSTEM_MOD_DIR}/lib/"
cp -a ${DIR}/.tk/original/filesystem/sbin/igdd "${FILESYSTEM_MOD_DIR}/sbin/"

echo1 "replacing multid"
cp -a ${DIR}/.tk/original/filesystem/sbin/multid "${FILESYSTEM_MOD_DIR}/sbin/"

echo1 "copying ar7login"
cp -a ${DIR}/.tk/original/filesystem/sbin/ar7login "${FILESYSTEM_MOD_DIR}/sbin/"

