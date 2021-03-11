[ "$FREETZ_AVM_VERSION_07_2X_MIN" == "y" ] || return 0
echo1 "removing oemcheck"

rm_files "${FILESYSTEM_MOD_DIR}/etc/boot.d/core/oemcheck"
supervisor_delete_service "oemcheck"

