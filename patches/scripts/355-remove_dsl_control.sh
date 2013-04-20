[ "$FREETZ_REMOVE_DSL_CONTROL" == "y" ] || return 0

echo1 "removing dsl_control"
rm_files "${FILESYSTEM_MOD_DIR}/usr/sbin/dsl_control"
