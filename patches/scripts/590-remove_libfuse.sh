[ "$FREETZ_REMOVE_LIBFUSE" = "y" ] || return 0

echo1 "removing libfuse.so"
rm_files "${MODULES_DIR}/lib/libfuse.so*"
