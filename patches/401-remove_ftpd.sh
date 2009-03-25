[ "$FREETZ_REMOVE_FTPD" == "y" ] || return 0
echo1 "remove ftp files"
rm_files "${FILESYSTEM_MOD_DIR}/sbin/ftpd"

echo1 "patching rc.conf"
sed -i -e "s/CONFIG_FTP=.*$/CONFIG_FTP=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
