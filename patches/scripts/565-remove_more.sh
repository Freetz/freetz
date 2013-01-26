[ "$FREETZ_REMOVE_MORE" = "y" ] || return 0;

echo1 "removing more"
rm_files "${FILESYSTEM_MOD_DIR}/bin/more"
