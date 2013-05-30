[ "$FREETZ_REMOVE_FTPD" == "y" -o "$FREETZ_AVM_HAS_NAS" == "y" ] || return 0

if [ "$FREETZ_AVM_HAS_NAS" == "y" -a "$FREETZ_REMOVE_FTPD" != "y" ]; then
	echo1 "remove banner from AVM ftpd"
	perl -pi -e 's#/etc/motd#/etc/fooo#g' "${FILESYSTEM_MOD_DIR}/sbin/ftpd"
fi

if [ "$FREETZ_REMOVE_FTPD" == "y" ]; then
	echo1 "remove AVM-ftpd files"
	rm_files \
	  "${FILESYSTEM_MOD_DIR}/sbin/ftpd" \
	  "${FILESYSTEM_MOD_DIR}/bin/inetdftp" \
	  "${FILESYSTEM_MOD_DIR}/etc/ftpd_control"

	echo1 "patching rc.conf"
	modsed "s/CONFIG_FTP=.*$/CONFIG_FTP=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
	return 0
fi
