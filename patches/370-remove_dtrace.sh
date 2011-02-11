[ "$FREETZ_REMOVE_DTRACE" == "y" ] || return 0
echo1 "removing dtrace file"
rm_files "${FILESYSTEM_MOD_DIR}/usr/bin/dtrace"

