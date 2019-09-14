[ "$FREETZ_REMOVE_PLCD" == "y" ] || return 0
echo1 "removing plcd files"

rm_files \
  "${FILESYSTEM_MOD_DIR}/etc/init.d/E50-plcd" \
  "${FILESYSTEM_MOD_DIR}/sbin/plcd" \
  "${FILESYSTEM_MOD_DIR}/usr/sbin/plcd" \
# "${FILESYSTEM_MOD_DIR}/lib/libmesh_plcservice.so"

