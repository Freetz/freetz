[ "$FREETZ_REMOVE_STRACE" = "y" ] || return 0;

echo1 "removing strace"
rm_files "${FILESYSTEM_MOD_DIR}/usr/bin/strace"
