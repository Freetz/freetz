[ "$FREETZ_REMOVE_CAPIOVERTCP" == "y" ] || return 0
echo1 "removing capiotcp server"

rm_files \
  "${FILESYSTEM_MOD_DIR}/etc/boot.d/capitcp" \
  "${FILESYSTEM_MOD_DIR}/etc/init.d/S73-capitcp" \
  "${FILESYSTEM_MOD_DIR}/usr/bin/capiotcp_server"
supervisor_delete_service "capitcp"

