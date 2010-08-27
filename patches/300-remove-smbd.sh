
if [ "$FREETZ_HAS_USB_HOST" != "y" -o "$FREETZ_REMOVE_SMBD" == "y" ] && [ "$FREETZ_PACKAGE_SAMBA" != "y" ]; then
	echo1 "Script rc.smbd for AVM-smbd was not integrated into image"
	rm_files "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.smbd"
fi
if [ "$FREETZ_HAS_USB_HOST" != "y" -o "$FREETZ_REMOVE_SMBD" == "y" -o "$FREETZ_PACKAGE_SAMBA" == "y" -o "$FREETZ_PACKAGE_INETD" != "y" ]; then
	echo1 "Files for inetd of AVM-smbd were not integrated into image"
	rm_files "${FILESYSTEM_MOD_DIR}/etc/default.smbd/" \
		 "${FILESYSTEM_MOD_DIR}/bin/inetdsamba"
fi


[ "$FREETZ_REMOVE_SMBD" == "y" ] || return 0
echo1 "remove AVM-smbd files"
rm_files "${FILESYSTEM_MOD_DIR}/sbin/smbd" \
	 "${FILESYSTEM_MOD_DIR}/sbin/smbpasswd" \
	 "${FILESYSTEM_MOD_DIR}/etc/samba_config.tar" \
	 "${FILESYSTEM_MOD_DIR}/etc/samba_control"

echo1 "patching rc.conf"
modsed "s/CONFIG_SAMBA=.*$/CONFIG_SAMBA=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
