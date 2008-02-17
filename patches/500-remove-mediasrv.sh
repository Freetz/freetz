[ "$DS_REMOVE_MEDIASRV" == "y" ] || return 0
echo1 "remove medissrv files"
rm -f "${FILESYSTEM_MOD_DIR}/sbin/mediasrv"
rm -f "${FILESYSTEM_MOD_DIR}/sbin/start_mediasrv"
rm -f "${FILESYSTEM_MOD_DIR}/sbin/stop_mediasrv"
