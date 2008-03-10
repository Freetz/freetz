[ "$FREETZ_REMOVE_SMBD" == "y" ] || return 0
echo1 "remove samba files"
rm -f "${FILESYSTEM_MOD_DIR}/sbin/smbd"
rm -f "${FILESYSTEM_MOD_DIR}/sbin/smbpasswd"
rm -f "${FILESYSTEM_MOD_DIR}/etc/samba_config.tar"
rm -f "${FILESYSTEM_MOD_DIR}/etc/samba_control"
