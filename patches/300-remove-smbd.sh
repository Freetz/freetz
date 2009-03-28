[ "$FREETZ_REMOVE_SMBD" == "y" ] || return 0
echo1 "remove samba files"
rm_files "${FILESYSTEM_MOD_DIR}/sbin/smbd" \
	 "${FILESYSTEM_MOD_DIR}/sbin/smbpasswd" \
	 "${FILESYSTEM_MOD_DIR}/etc/samba_config.tar" \
	 "${FILESYSTEM_MOD_DIR}/etc/samba_control"

echo1 "patching rc.conf"
sed -i -e "s/CONFIG_SAMBA=.*$/CONFIG_SAMBA=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
