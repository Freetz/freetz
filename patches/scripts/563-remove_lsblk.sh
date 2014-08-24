[ -e "${FILESYSTEM_MOD_DIR}/bin/lsblk" ] || return 0

echo1 "removing lsblk"
rm_files "${FILESYSTEM_MOD_DIR}/bin/lsblk"
