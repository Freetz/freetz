[ "$FREETZ_REMOVE_FTPD" != "y" -a "$FREETZ_AVM_HAS_NAS" == "y" ] || return 0
echo1 "remove banner from AVM ftpd"

perl -pi -e 's#/etc/motd#/etc/fooo#g' "${FILESYSTEM_MOD_DIR}/sbin/ftpd"

