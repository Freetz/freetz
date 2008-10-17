[ "$FREETZ_REMOVE_FTPD" == "y" ] || return 0
echo1 "remove ftp files"
rm_files "${FILESYSTEM_MOD_DIR}/sbin/ftpd"
