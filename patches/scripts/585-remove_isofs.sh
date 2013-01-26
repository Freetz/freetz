[ "$FREETZ_REMOVE_ISOFS" = "y" ] || return 0

echo1 "removing isofs"
rm_files "${MODULES_DIR}/kernel/fs/isofs"
