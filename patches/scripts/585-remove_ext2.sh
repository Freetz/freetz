[ "$FREETZ_REMOVE_EXT2" = "y" ] || return 0

echo1 "removing ext2"
rm_files "${MODULES_DIR}/kernel/fs/ext2"
