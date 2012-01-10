[ "$FREETZ_REMOVE_JFFS2" = "y" ] || return 0;

echo1 "removing jffs2"

rm_files "${MODULES_DIR}/kernel/fs/jffs2"
modsed ${MODULES_DIR}/modules.dep 's/.\*\+jffs2.ko:.\*//'