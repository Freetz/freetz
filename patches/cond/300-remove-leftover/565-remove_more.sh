[ -e "${FILESYSTEM_MOD_DIR}/bin/more" ] || return 0
echo1 "removing more"

rm_files "${FILESYSTEM_MOD_DIR}/bin/more"

