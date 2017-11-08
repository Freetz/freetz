[ "$FREETZ_REMOVE_NLS" = "y" ] || return 0

echo1 "removing nls"
rm_files "${MODULES_DIR}/kernel/fs/nls"
