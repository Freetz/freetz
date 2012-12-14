[ "$FREETZ_REMOVE_SOCAT" = "y" ] || return 0;

echo1 "removing socat"
rm_files "${FILESYSTEM_MOD_DIR}/sbin/socat"
