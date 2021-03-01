[ "$FREETZ_REMOVE_DTRACE" == "y" ] || return 0
[ "$FREETZ_REPLACE_DTRACE" != "y" ] && action='removing' || action='replacing'
echo1 "$action dtrace file"

rm_files "${FILESYSTEM_MOD_DIR}/usr/bin/dtrace"
[ "$FREETZ_REPLACE_DTRACE" == "y" ] && ln -s /tmp/flash/mod/dtrace "${FILESYSTEM_MOD_DIR}/usr/bin/dtrace"

