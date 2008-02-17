[ "$DS_REMOVE_FTPD" == "y" ] || return 0
echo1 "remove ftp files"
rm -f "${FILESYSTEM_MOD_DIR}/sbin/ftpd"
