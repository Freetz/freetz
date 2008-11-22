[ "$FREETZ_REMOVE_MEDIASRV" == "y" ] || return 0
echo1 "remove medissrv files"
rm_files "${FILESYSTEM_MOD_DIR}/sbin/mediasrv" \
	 "${FILESYSTEM_MOD_DIR}/sbin/start_mediasrv" \
	 "${FILESYSTEM_MOD_DIR}/sbin/stop_mediasrv"
