[ "$FREETZ_REMOVE_SHOWDSLDSTAT" == "y" ] || return 0

echo1 "removing showdsldstat file"
rm_files $(find ${FILESYSTEM_MOD_DIR}/sbin -name showdsldstat)
