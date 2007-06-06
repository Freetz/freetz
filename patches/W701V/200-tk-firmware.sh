if [ -z "$FIRMWARE2" ]
then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}removing TCOM Webinterface"
rm -rf "${FILESYSTEM_MOD_DIR}/usr/www/tcom"

[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}copying AVM Webinterface"
mkdir "${FILESYSTEM_MOD_DIR}/usr/www/all"
"$TAR" -cf - -C "${DIR}/.tk/original/filesystem/usr/www/all" --exclude=html/de/usb . | "$TAR" -xf - -C "${FILESYSTEM_MOD_DIR}/usr/www/all"
ln -sf /usr/www/all "${FILESYSTEM_MOD_DIR}/usr/www/tcom"
"$TAR" -cf - -C "${DIR}/.tk/original/filesystem/etc/default.Fritz_Box_7170/avm" . | "$TAR" -xkf - -C "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_SpeedportW701V/tcom" >/dev/null 2>&1 

[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}copying mailer to /sbin/mailer"
"$TAR" -cf - -C "${DIR}/.tk/original/filesystem/sbin" mailer | "$TAR" -xkf - -C "${FILESYSTEM_MOD_DIR}/sbin" >/dev/null 2>&1 
