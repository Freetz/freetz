[ "$FREETZ_REMOVE_LSOF" = "y" ] || return 0;

echo1 "removing lsof"
rm_files "${FILESYSTEM_MOD_DIR}/bin/lsof"
