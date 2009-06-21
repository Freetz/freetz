[ "$FREETZ_REMOVE_CHRONYD" == "y" ] || return 0
echo1 "remove chronyd files"
rm_files "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.chrony" \
	"${FILESYSTEM_MOD_DIR}/etc/onlinechanged/chrony" \
	"${FILESYSTEM_MOD_DIR}/sbin/chronyc" \
	"${FILESYSTEM_MOD_DIR}/sbin/chronyd"
