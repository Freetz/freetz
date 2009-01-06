[ "$FREETZ_REMOVE_TR069" == "y" ] || return 0

echo1 "removing tr069 stuff"
rm_files "${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libtr069.so" \
	 "${FILESYSTEM_MOD_DIR}/bin/tr069starter" \
	 "${FILESYSTEM_MOD_DIR}/sbin/tr069discover" \
	 "${FILESYSTEM_MOD_DIR}/usr/bin/tr069fwupdate"
