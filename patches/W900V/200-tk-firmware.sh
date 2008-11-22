if [ -z "$FIRMWARE2" ]
then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

echo1 "removing TCOM Webinterface"
rm -rf "${FILESYSTEM_MOD_DIR}/usr/www/tcom"

echo1 "copying AVM Webinterface"
mkdir "${FILESYSTEM_MOD_DIR}/usr/www/all"
"$TAR" -c -C "${DIR}/.tk/original/filesystem/usr/www/all" . | "$TAR" -x -C "${FILESYSTEM_MOD_DIR}/usr/www/all"
ln -sf /usr/www/all "${FILESYSTEM_MOD_DIR}/usr/www/tcom"
ln -sf /usr/www/all "${FILESYSTEM_MOD_DIR}/usr/www/avm"
ln -s /usr/bin/system_status "${FILESYSTEM_MOD_DIR}/usr/www/cgi-bin"

"$TAR" -c -C "${DIR}/.tk/original/filesystem/etc/default.Fritz_Box_7150/avm" --exclude=*.cfg . | "$TAR" -x -C "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_DECT_W900V/tcom" 
ln -sf tcom "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_DECT_W900V/avm"

echo1 "copying mailer"
cp -a "${DIR}/.tk/original/filesystem/sbin/mailer" "${FILESYSTEM_MOD_DIR}/sbin/"

echo1 "copying igdd + required libs"
cp -a ${DIR}/.tk/original/filesystem/lib/libmxml.so* "${FILESYSTEM_MOD_DIR}/lib/"
cp -a ${DIR}/.tk/original/filesystem/sbin/igdd "${FILESYSTEM_MOD_DIR}/sbin/"
#cp -a ${DIR}/.tk/original/filesystem/lib/libewnwlinux.so* "${FILESYSTEM_MOD_DIR}/lib/"

