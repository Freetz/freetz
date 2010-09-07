[ "$FREETZ_REMOVE_SMBD" == "y" -o "$FREETZ_PACKAGE_SAMBA" == "y" ] || return 0
[ "$FREETZ_REMOVE_FTPD" == "y" ] || return 0
echo1 "remove AVM-inetdctl"
rm_files "${FILESYSTEM_MOD_DIR}/bin/inetdctl"
