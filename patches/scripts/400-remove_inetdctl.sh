[ "$FREETZ_REMOVE_SAMBA" == "y" -o "$FREETZ_PACKAGE_SAMBA_SMBD" == "y" ] || return 0
[ "$FREETZ_REMOVE_FTPD" == "y" ] || return 0
echo1 "remove AVM-inetdctl"
rm_files "${FILESYSTEM_MOD_DIR}/bin/inetdctl"
