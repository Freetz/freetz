if [ -z "$FIRMWARE2" ]
then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}removing TCOM Webinterface"
rm -rf "${FILESYSTEM_MOD_DIR}/usr/www/tcom"

[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}copying AVM Webinterface"
mkdir "${FILESYSTEM_MOD_DIR}/usr/www/all"
"$TAR" -cf - -C "${DIR}/.tk/original/filesystem/usr/www/all" . | "$TAR" -xf - -C "${FILESYSTEM_MOD_DIR}/usr/www/all"
ln -sf all "${FILESYSTEM_MOD_DIR}/usr/www/tcom"
ln -sf all "${FILESYSTEM_MOD_DIR}/usr/www/avm"

rm -rf "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_DECT_W900V/tcom"
"$TAR" -cf - -C "${DIR}/.tk/original/filesystem/etc/default.Fritz_Box_7150" avm | "$TAR" -xf - -C "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_DECT_W900V" 
ln -sf avm "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_DECT_W900V/tcom"

[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}copying mailer to /sbin/mailer"
"$TAR" -cf - -C "${DIR}/.tk/original/filesystem/sbin" mailer | "$TAR" -xkf - -C "${FILESYSTEM_MOD_DIR}/sbin" 
