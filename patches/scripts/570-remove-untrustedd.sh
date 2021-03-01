[ "$FREETZ_REMOVE_UNTRUSTEDD" == "y" ] || return 0
echo1 "removing untrustedd"

rm_files "${FILESYSTEM_MOD_DIR}/usr/bin/untrustedd"
supervisor_delete_service "untrustedd"

