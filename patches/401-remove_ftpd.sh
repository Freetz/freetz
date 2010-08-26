
if [ "$FREETZ_HAS_USB_HOST" != "y" -o "$FREETZ_REMOVE_FTPD" == "y" ]; then
	echo2 "Script rc.ftpd for AVM-ftpd was not integrated into image"
	rm_files "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.ftpd"
fi
if [ "$FREETZ_HAS_USB_HOST" != "y" -o "$FREETZ_REMOVE_FTPD" == "y" -o "$FREETZ_PACKAGE_INETD" != "y" ]; then
	echo2 "Files for inetd of AVM-ftpd were not integrated into image"
	rm_files "${FILESYSTEM_MOD_DIR}/etc/default.ftpd/ftpd.inetd"
		 "${FILESYSTEM_MOD_DIR}/bin/inetdftp"
fi


[ "$FREETZ_REMOVE_FTPD" == "y" ] || return 0
echo1 "remove AVM-ftpd files"
rm_files "${FILESYSTEM_MOD_DIR}/sbin/ftpd" \
	 "${FILESYSTEM_MOD_DIR}/etc/ftpd_control"

echo1 "patching rc.conf"
modsed "s/CONFIG_FTP=.*$/CONFIG_FTP=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
