[ "$FREETZ_REMOVE_DTRACE" == "y" ] || return 0

if [ "$FREETZ_REPLACE_DTRACE" != "y" ]; then
	echo1 "removing dtrace file"
else
	echo1 "replacing dtrace file"
fi

rm_files "${FILESYSTEM_MOD_DIR}/usr/bin/dtrace"
[ "$FREETZ_REPLACE_DTRACE" == "y" ] && ln -s /tmp/flash/mod/dtrace "${FILESYSTEM_MOD_DIR}/usr/bin/dtrace"
